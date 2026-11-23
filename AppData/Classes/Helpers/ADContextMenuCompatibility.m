// iOS 26 application-shortcut compatibility.
// Keep release/package metadata independent of this implementation.
// Compile as Objective-C with ARC, separately for arm64 and arm64e.
// This source does not change or binary-patch AppData.dylib.
#if defined(AD_MENU_TEST)
#import "AppDataMenuTestUI.h"
#else
#import <UIKit/UIKit.h>
#endif
#import <objc/runtime.h>
#import <objc/message.h>
#import <dlfcn.h>
#include <mach-o/dyld.h>
#include <stdlib.h>
#include <string.h>
#include <sys/sysctl.h>

typedef void (*Activation)(id, SEL, id, id, id);
typedef void (*HookMessage)(Class, SEL, IMP, IMP *);
typedef void (*PresentPanel)(id, SEL, id, BOOL);

// Dedicated storage: never aliases AppData's original-method pointers.
static IMP savedActivation;
static Class itemClass;
static Class iconViewClass;
static Class panelClass;
static SEL panelSelector;

static HookMessage ResolveHook(void) {
    HookMessage hook = (HookMessage)dlsym(RTLD_DEFAULT, "MSHookMessageEx");
    if (hook) return hook;
    // An injector may have loaded the engine with local symbol visibility.
    // Look only in existing images; do not load an additional hook engine.
    for (uint32_t i = 0; i < _dyld_image_count(); ++i) {
        const char *path = _dyld_get_image_name(i);
        if (!path) continue;
        const char *leaf = strrchr(path, '/'); leaf = leaf ? leaf + 1 : path;
        if (strcmp(leaf, "CydiaSubstrate") && strcmp(leaf, "libsubstrate.dylib")
            && strcmp(leaf, "libellekit.dylib") && strcmp(leaf, "ElleKit")) continue;
        void *handle = dlopen(path, RTLD_LAZY | RTLD_NOLOAD);
        if (!handle) continue;
        hook = (HookMessage)dlsym(handle, "MSHookMessageEx");
        dlclose(handle);
        if (hook) return hook;
    }
    return NULL;
}

static const char *Unqualified(const char *t) {
    while (*t && strchr("rnNoORV", *t)) ++t;
    return t;
}

static BOOL HasType(Method method, unsigned index, char expected) {
    char *t = method_copyArgumentType(method, index);
    BOOL valid = t && Unqualified(t)[0] == expected;
    free(t);
    return valid;
}

static BOOL ReturnsVoid(Method method) {
    if (!method) return NO;
    char *t = method_copyReturnType(method);
    BOOL valid = t && !strcmp(Unqualified(t), "v");
    free(t);
    return valid;
}

static BOOL ActivationABI(Method method) {
    return ReturnsVoid(method) && method_getNumberOfArguments(method) == 5
        && HasType(method, 0, '@') && HasType(method, 1, ':')
        && HasType(method, 2, '@') && HasType(method, 3, '@')
        && HasType(method, 4, '@');
}

static BOOL PanelABI(Method method) {
    // This candidate supports the modern 64-bit Objective-C BOOL encoding.
    return ReturnsVoid(method) && method_getNumberOfArguments(method) == 4
        && HasType(method, 0, '@') && HasType(method, 1, ':')
        && HasType(method, 2, '@') && HasType(method, 3, 'B');
}

static void Activate(id receiver, SEL command, id item, id bundleID, id view) {
    // Runs when the provider's activation method is invoked. No original
    // AppData hook or decision method is called here.
    if ([NSThread isMainThread] && [item isKindOfClass:itemClass]
        && [item respondsToSelector:@selector(type)]) {
        id type = ((id (*)(id, SEL))objc_msgSend)(item, @selector(type));
        if ([type isKindOfClass:NSString.class]
            && [type isEqualToString:@"com.fouadraheb.appdata"]
            && [view isKindOfClass:iconViewClass]
            && ((UIView *)view).window
            && [view respondsToSelector:sel_registerName("_iconImageView")]) {
            // Guard the existing AppData presentation entry point's image
            // accessor so it cannot enter its unguarded ivar fallback.
            id imageView = ((id (*)(id, SEL))objc_msgSend)(view, sel_registerName("_iconImageView"));
            if ([imageView isKindOfClass:UIView.class]
                && [imageView respondsToSelector:sel_registerName("contentsImage")]) {
                ((PresentPanel)objc_msgSend)(panelClass, panelSelector, view, YES);
                return;
            }
        }
    }
    Activation original = (Activation)savedActivation;
    if (original) original(receiver, command, item, bundleID, view);
}

static BOOL SupportedSystem(void) {
#if defined(AD_MENU_TEST)
    return YES;
#else
        NSOperatingSystemVersion os = NSProcessInfo.processInfo.operatingSystemVersion;
        if (os.majorVersion != 26 || os.minorVersion != 0 || os.patchVersion != 1) return NO;
        char build[32] = {0}; size_t size = sizeof(build);
        return sysctlbyname("kern.osversion", build, &size, NULL, 0) == 0
            && !strcmp(build, "23A355");
#endif
}

static void Install(void) {
        static BOOL installed;
        if (![NSThread isMainThread] || installed || !SupportedSystem()) return;
        Class provider = objc_lookUpClass("SBHIconViewApplicationShortcutsContextMenuProvider");
        Class meta = provider ? object_getClass(provider) : Nil;
        SEL activate = sel_registerName("activateShortcut:withBundleIdentifier:forIconView:");
        Method method = meta ? class_getInstanceMethod(meta, activate) : NULL;
        itemClass = objc_lookUpClass("SBSApplicationShortcutItem");
        iconViewClass = objc_lookUpClass("SBIconView");
        panelClass = objc_lookUpClass("ADDataViewController");
        panelSelector = sel_registerName("presentControllerFromSBIconView:fromContextMenu:");
        Method present = panelClass ? class_getClassMethod(panelClass, panelSelector) : NULL;
        HookMessage hook = ResolveHook();
        if (!itemClass || !iconViewClass || !panelClass || !hook
            || !ActivationABI(method) || !PanelABI(present)) return;
        // Seed the current implementation before publishing a replacement.
        // The engine then updates this slot to its chain-preserving original.
        savedActivation = method_getImplementation(method);
        if (!savedActivation) return;
        installed = YES;
        // Install on the metaclass. savedActivation is unique to this dylib.
        hook(meta, activate, (IMP)Activate, &savedActivation);
}

#if !defined(AD_MENU_TEST)
__attribute__((constructor)) static void Start(void) {
    @autoreleasepool {
        if (![NSProcessInfo.processInfo.processName isEqualToString:@"SpringBoard"]) return;
        // Only install metadata hooks here; never activate a shortcut or
        // present UI. Retry after launch if dependency registration is late.
        [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidFinishLaunchingNotification
            object:nil queue:NSOperationQueue.mainQueue usingBlock:^(__unused NSNotification *n) {
                dispatch_async(dispatch_get_main_queue(), ^{ Install(); });
            }];
        dispatch_async(dispatch_get_main_queue(), ^{ Install(); });
    }
}
#endif

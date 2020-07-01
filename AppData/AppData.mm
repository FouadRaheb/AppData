#line 1 "/Users/fouad/Projects/ios/AppData/AppData/AppData.xm"
#import "ADDataViewController.h"


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SBIconImageView; @class SBUIAppIconForceTouchControllerDataProvider; @class SBUIAppIconForceTouchController; @class SBIconView; 


#line 3 "/Users/fouad/Projects/ios/AppData/AppData/AppData.xm"
static SBIconImageView * (*_logos_orig$SHARED_HOOKS$SBIconImageView$initWithFrame$)(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST, SEL, CGRect); static SBIconImageView * _logos_method$SHARED_HOOKS$SBIconImageView$initWithFrame$(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST, SEL, CGRect); static void _logos_method$SHARED_HOOKS$SBIconImageView$appDataPreferencesChanged(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST, SEL); static void _logos_method$SHARED_HOOKS$SBIconImageView$appDataDidSwipeUp$(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST, SEL, UIGestureRecognizer *); 



static char _logos_property_key$SHARED_HOOKS$SBIconImageView$adSwipeGestureRecognizer;__attribute__((used)) static UISwipeGestureRecognizer * _logos_method$SHARED_HOOKS$SBIconImageView$adSwipeGestureRecognizer$(SBIconImageView* __unused self, SEL __unused _cmd){ return objc_getAssociatedObject(self, &_logos_property_key$SHARED_HOOKS$SBIconImageView$adSwipeGestureRecognizer); }__attribute__((used)) static void _logos_method$SHARED_HOOKS$SBIconImageView$setAdSwipeGestureRecognizer$(SBIconImageView* __unused self, SEL __unused _cmd, UISwipeGestureRecognizer * arg){ objc_setAssociatedObject(self, &_logos_property_key$SHARED_HOOKS$SBIconImageView$adSwipeGestureRecognizer, arg, OBJC_ASSOCIATION_RETAIN_NONATOMIC); }

static SBIconImageView * _logos_method$SHARED_HOOKS$SBIconImageView$initWithFrame$(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, CGRect arg1) {
    HBLogDebug(@"-[<SBIconImageView: %p> initWithFrame:{{%g, %g}, {%g, %g}}]", self, arg1.origin.x, arg1.origin.y, arg1.size.width, arg1.size.height);
    SBIconImageView *r = _logos_orig$SHARED_HOOKS$SBIconImageView$initWithFrame$(self, _cmd, arg1);
    if (![r isKindOfClass:NSClassFromString(@"SBFolderIconImageView")]) {
        [[NSNotificationCenter defaultCenter] addObserver:r selector:@selector(appDataPreferencesChanged) name:kAppDataForceTouchMenuPreferencesChangedNotification object:nil];
        
        
        self.adSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:r action:@selector(appDataDidSwipeUp:)];
        self.adSwipeGestureRecognizer.direction = (UISwipeGestureRecognizerDirectionUp);
        r.userInteractionEnabled = YES;
        
        
        [self appDataPreferencesChanged];
    }
    return r;
}


static void _logos_method$SHARED_HOOKS$SBIconImageView$appDataPreferencesChanged(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    if ([ADHelper swipeUpEnabled]) {
        if (![self.gestureRecognizers containsObject:self.adSwipeGestureRecognizer]) {
            [self addGestureRecognizer:self.adSwipeGestureRecognizer];
        }
    } else {
        if ([self.gestureRecognizers containsObject:self.adSwipeGestureRecognizer]) {
            [self removeGestureRecognizer:self.adSwipeGestureRecognizer];
        }
    }
}


static void _logos_method$SHARED_HOOKS$SBIconImageView$appDataDidSwipeUp$(_LOGOS_SELF_TYPE_NORMAL SBIconImageView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIGestureRecognizer * gesture) {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [ADDataViewController presentControllerFromSBIconImageView:self];
    }
}





#pragma mark - ForceTouch Menu

static void (*_logos_orig$IOS13_AND_NEWER_HOOKS$SBIconView$setApplicationShortcutItems$)(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST, SEL, NSArray *); static void _logos_method$IOS13_AND_NEWER_HOOKS$SBIconView$setApplicationShortcutItems$(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST, SEL, NSArray *); static void (*_logos_meta_orig$IOS13_AND_NEWER_HOOKS$SBIconView$activateShortcut$withBundleIdentifier$forIconView$)(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, SBSApplicationShortcutItem *, NSString *, SBIconView *); static void _logos_meta_method$IOS13_AND_NEWER_HOOKS$SBIconView$activateShortcut$withBundleIdentifier$forIconView$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST, SEL, SBSApplicationShortcutItem *, NSString *, SBIconView *); 



static void _logos_method$IOS13_AND_NEWER_HOOKS$SBIconView$setApplicationShortcutItems$(_LOGOS_SELF_TYPE_NORMAL SBIconView* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, NSArray * items) {
    if ([ADHelper forceTouchMenuEnabled]) {
        NSMutableArray *newItems = [NSMutableArray arrayWithArray:items?:@[]];
        SBSApplicationShortcutItem *shortcutItem = [ADHelper applicationShortcutItem];
        if (shortcutItem) {
            [newItems addObject:shortcutItem];
        }
        _logos_orig$IOS13_AND_NEWER_HOOKS$SBIconView$setApplicationShortcutItems$(self, _cmd, newItems);
    } else {
        _logos_orig$IOS13_AND_NEWER_HOOKS$SBIconView$setApplicationShortcutItems$(self, _cmd, items);
    }
}

static void _logos_meta_method$IOS13_AND_NEWER_HOOKS$SBIconView$activateShortcut$withBundleIdentifier$forIconView$(_LOGOS_SELF_TYPE_NORMAL Class _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, SBSApplicationShortcutItem * item, NSString * bundleID, SBIconView * iconView) {
    if ([item.type isEqualToString:kSBApplicationShortcutItemType]) {
        [ADDataViewController presentControllerFromSBIconView:iconView];
    } else {
        _logos_meta_orig$IOS13_AND_NEWER_HOOKS$SBIconView$activateShortcut$withBundleIdentifier$forIconView$(self, _cmd, item, bundleID, iconView);
    }
}






static id (*_logos_orig$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchControllerDataProvider$applicationShortcutItems)(_LOGOS_SELF_TYPE_NORMAL SBUIAppIconForceTouchControllerDataProvider* _LOGOS_SELF_CONST, SEL); static id _logos_method$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchControllerDataProvider$applicationShortcutItems(_LOGOS_SELF_TYPE_NORMAL SBUIAppIconForceTouchControllerDataProvider* _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchController$appIconForceTouchShortcutViewController$activateApplicationShortcutItem$)(_LOGOS_SELF_TYPE_NORMAL SBUIAppIconForceTouchController* _LOGOS_SELF_CONST, SEL, id, SBSApplicationShortcutItem *); static void _logos_method$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchController$appIconForceTouchShortcutViewController$activateApplicationShortcutItem$(_LOGOS_SELF_TYPE_NORMAL SBUIAppIconForceTouchController* _LOGOS_SELF_CONST, SEL, id, SBSApplicationShortcutItem *); 



static id _logos_method$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchControllerDataProvider$applicationShortcutItems(_LOGOS_SELF_TYPE_NORMAL SBUIAppIconForceTouchControllerDataProvider* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
    if ([ADHelper forceTouchMenuEnabled]) {
        NSMutableArray *newItems = [NSMutableArray arrayWithArray:_logos_orig$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchControllerDataProvider$applicationShortcutItems(self, _cmd)?:@[]];
        [newItems addObject:[ADHelper applicationShortcutItem]];
        return newItems;
    }
    return _logos_orig$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchControllerDataProvider$applicationShortcutItems(self, _cmd);
}





static void _logos_method$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchController$appIconForceTouchShortcutViewController$activateApplicationShortcutItem$(_LOGOS_SELF_TYPE_NORMAL SBUIAppIconForceTouchController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1, SBSApplicationShortcutItem * item) {
    if ([item.type isEqualToString:kSBApplicationShortcutItemType]) {
        [self dismissAnimated:YES withCompletionHandler:nil];
        SBUIAppIconForceTouchControllerDataProvider* _dataProvider = [self valueForKey:@"_dataProvider"];
        SBIconView *iconView = (SBIconView *)_dataProvider.gestureRecognizer.view;
        [ADDataViewController presentControllerFromSBIconView:iconView];
    } else {
        _logos_orig$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchController$appIconForceTouchShortcutViewController$activateApplicationShortcutItem$(self, _cmd, arg1, item);
    }
}





static __attribute__((constructor)) void _logosLocalCtor_99c1e5cd(int __unused argc, char __unused **argv, char __unused **envp) {
    [[ADHelper sharedInstance] initialize];
    
    {Class _logos_class$SHARED_HOOKS$SBIconImageView = objc_getClass("SBIconImageView"); MSHookMessageEx(_logos_class$SHARED_HOOKS$SBIconImageView, @selector(initWithFrame:), (IMP)&_logos_method$SHARED_HOOKS$SBIconImageView$initWithFrame$, (IMP*)&_logos_orig$SHARED_HOOKS$SBIconImageView$initWithFrame$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$SHARED_HOOKS$SBIconImageView, @selector(appDataPreferencesChanged), (IMP)&_logos_method$SHARED_HOOKS$SBIconImageView$appDataPreferencesChanged, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UIGestureRecognizer *), strlen(@encode(UIGestureRecognizer *))); i += strlen(@encode(UIGestureRecognizer *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$SHARED_HOOKS$SBIconImageView, @selector(appDataDidSwipeUp:), (IMP)&_logos_method$SHARED_HOOKS$SBIconImageView$appDataDidSwipeUp$, _typeEncoding); }{ class_addMethod(_logos_class$SHARED_HOOKS$SBIconImageView, @selector(adSwipeGestureRecognizer), (IMP)&_logos_method$SHARED_HOOKS$SBIconImageView$adSwipeGestureRecognizer$, [[NSString stringWithFormat:@"%s@:", @encode(UISwipeGestureRecognizer *)] UTF8String]);class_addMethod(_logos_class$SHARED_HOOKS$SBIconImageView, @selector(setAdSwipeGestureRecognizer:), (IMP)&_logos_method$SHARED_HOOKS$SBIconImageView$setAdSwipeGestureRecognizer$, [[NSString stringWithFormat:@"v@:%s", @encode(UISwipeGestureRecognizer *)] UTF8String]);} }
    
    if (@available(iOS 13, *)) {
        {Class _logos_class$IOS13_AND_NEWER_HOOKS$SBIconView = objc_getClass("SBIconView"); Class _logos_metaclass$IOS13_AND_NEWER_HOOKS$SBIconView = object_getClass(_logos_class$IOS13_AND_NEWER_HOOKS$SBIconView); MSHookMessageEx(_logos_class$IOS13_AND_NEWER_HOOKS$SBIconView, @selector(setApplicationShortcutItems:), (IMP)&_logos_method$IOS13_AND_NEWER_HOOKS$SBIconView$setApplicationShortcutItems$, (IMP*)&_logos_orig$IOS13_AND_NEWER_HOOKS$SBIconView$setApplicationShortcutItems$);MSHookMessageEx(_logos_metaclass$IOS13_AND_NEWER_HOOKS$SBIconView, @selector(activateShortcut:withBundleIdentifier:forIconView:), (IMP)&_logos_meta_method$IOS13_AND_NEWER_HOOKS$SBIconView$activateShortcut$withBundleIdentifier$forIconView$, (IMP*)&_logos_meta_orig$IOS13_AND_NEWER_HOOKS$SBIconView$activateShortcut$withBundleIdentifier$forIconView$);}
    } else {
        {Class _logos_class$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchControllerDataProvider = objc_getClass("SBUIAppIconForceTouchControllerDataProvider"); MSHookMessageEx(_logos_class$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchControllerDataProvider, @selector(applicationShortcutItems), (IMP)&_logos_method$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchControllerDataProvider$applicationShortcutItems, (IMP*)&_logos_orig$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchControllerDataProvider$applicationShortcutItems);Class _logos_class$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchController = objc_getClass("SBUIAppIconForceTouchController"); MSHookMessageEx(_logos_class$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchController, @selector(appIconForceTouchShortcutViewController:activateApplicationShortcutItem:), (IMP)&_logos_method$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchController$appIconForceTouchShortcutViewController$activateApplicationShortcutItem$, (IMP*)&_logos_orig$IOS12_AND_OLDER_HOOKS$SBUIAppIconForceTouchController$appIconForceTouchShortcutViewController$activateApplicationShortcutItem$);}
    }
}

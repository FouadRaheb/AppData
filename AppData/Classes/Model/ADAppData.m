//
//  ADAppData.m
//  AppData
//
//  Created by Fouad Raheb on 6/28/20.
//

#import "ADAppData.h"
#import "NRFileManager.h"
#import "ADTCC.h"
#import "ADTerminator.h"
#import <dlfcn.h>
#import <Foundation/Foundation.h>


@interface ADAppData ()
@property (nonatomic, strong) SBApplication *sbApplication;

@property (nonatomic, strong) LSApplicationProxy *appProxy;
@end

@implementation ADAppData

#pragma mark - Helpers

+ (SBApplication *)sbApplicationForBundleIdentifier:(NSString *)bundleIdentifier {
    if ([[NSClassFromString(@"SBApplicationController") sharedInstance] respondsToSelector:@selector(applicationWithBundleIdentifier:)]) {
        return [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];
    }
    return nil;
}

#pragma mark - Initializers

+ (ADAppData *)appDataForBundleIdentifier:(NSString *)bundleIdentifier iconImage:(UIImage *)iconImage {
    ADAppData *data = [[ADAppData alloc] initWithBundleIdentifier:bundleIdentifier];
    data.iconImage = iconImage;
    return data;
}

- (instancetype)initWithBundleIdentifier:(NSString *)bundleIdentifier {
    if (self = [super init]) {
        self.sbApplication = [self.class sbApplicationForBundleIdentifier:bundleIdentifier];
        self.appProxy = [LSApplicationProxy applicationProxyForIdentifier:bundleIdentifier];
        [self loadData];
    }
    return self;
}

- (void)loadData {
    // Version
    self.version = @"N/A";
    if ([self.appProxy respondsToSelector:@selector(shortVersionString)]) {
        if (self.appProxy.shortVersionString) {
            self.version = self.appProxy.shortVersionString;
        } else if ([self.appProxy respondsToSelector:@selector(bundleVersion)]) {
            self.version = self.appProxy.bundleVersion;
        }
    }
    
    // Bundle ID
    if ([self.appProxy respondsToSelector:@selector(bundleIdentifier)] && self.appProxy.bundleIdentifier) {
        self.bundleIdentifier = self.appProxy.bundleIdentifier;
    } else {
        self.bundleIdentifier = @"N/A";
    }
    
    // Vendable
    if ([self.appProxy respondsToSelector:@selector(isAppStoreVendable)]) {
        self.appStoreVendable = self.appProxy.isAppStoreVendable;
    }
    
    // Bundle URL
    if ([self.appProxy respondsToSelector:@selector(bundleURL)]) {
        if (self.appProxy.bundleURL) {
            self.bundleURL = self.appProxy.bundleURL;
        } else if ([self.appProxy respondsToSelector:@selector(bundleContainerURL)]) {
            self.bundleURL = self.appProxy.bundleContainerURL;
        }
    }
    
    // Data URL
    if ([self.appProxy respondsToSelector:@selector(dataContainerURL)]) {
        self.dataContainerURL = self.appProxy.dataContainerURL;
    }
    
    if ([self.appProxy respondsToSelector:@selector(groupContainerURLs)]) {
        NSMutableArray *appGroups = [NSMutableArray new];
        NSArray *sortedKeys = [self.appProxy.groupContainerURLs.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for (NSString *key in sortedKeys) {
            NSURL *url = [self.appProxy.groupContainerURLs objectForKey:key];
            ADAppDataGroup *group = [ADAppDataGroup groupWithIdentifier:key url:url];
            [appGroups addObject:group];
        }
        self.appGroups = appGroups;
    }
    
    // Disk Usage
    if ([self.appProxy respondsToSelector:@selector(staticDiskUsage)]) {
        self.diskUsage = [self.appProxy.staticDiskUsage integerValue];
        self.diskUsageString = [NSByteCountFormatter stringFromByteCount:[self.appProxy.staticDiskUsage longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
    }
    
    // Info for more page
    [self loadMoreInfo];
}

- (void)loadMoreInfo {
    // Other Info
    self.entitlements = self.appProxy.entitlements;
    self.entitlementsIdentifiers = self.entitlements.allKeys;
    
    ASYNC({
        NSURL *infoPlistURL = [self.bundleURL URLByAppendingPathComponent:@"Info.plist"];
        NSDictionary *infoDictionary = [NSDictionary dictionaryWithContentsOfURL:infoPlistURL];
        
        if (infoDictionary) {
            // URL Schemes
            NSArray *bundleURLTypes = [infoDictionary objectForKey:@"CFBundleURLTypes"];
            if ([bundleURLTypes isKindOfClass:[NSArray class]]) {
                if (bundleURLTypes.firstObject && [bundleURLTypes.firstObject isKindOfClass:[NSDictionary class]]) {
                    id urlSchemes = [bundleURLTypes.firstObject objectForKey:@"CFBundleURLSchemes"];
                    if ([urlSchemes isKindOfClass:[NSArray class]]) {
                        self.urlSchemes = urlSchemes;
                    }
                }
            }
            
            // Queries Schemes
            id queriesSchemes = [infoDictionary objectForKey:@"LSApplicationQueriesSchemes"];
            if ([queriesSchemes isKindOfClass:[NSArray class]]) {
                self.queriesSchemes = queriesSchemes;
            }
            
            // Activity Types
            id activityTypes = [infoDictionary objectForKey:@"NSUserActivityTypes"];
            if ([activityTypes isKindOfClass:[NSArray class]]) {
                self.activityTypes = activityTypes;
            }
            
            // Background Modes
            id backgroundModes = [infoDictionary objectForKey:@"UIBackgroundModes"];
            if ([backgroundModes isKindOfClass:[NSArray class]]) {
                self.backgroundModes = backgroundModes;
            }
            
            // Versions
            self.minimumOSVersion = [infoDictionary objectForKey:@"MinimumOSVersion"];
            self.internalVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
            self.platformVersion = [infoDictionary objectForKey:@"DTPlatformVersion"];
        }
    });
}

- (NSString *)name {
    return [self.sbApplication respondsToSelector:@selector(displayName)] ? self.sbApplication.displayName : nil;
}

- (BOOL)isApplication {
    return self.sbApplication != nil;
}

#pragma mark - Icon Name

- (NSString *)customIconName {
    return [ADSettings customAppNameForBundleIdentifier:self.bundleIdentifier];
}

- (void)setCustomIconName:(NSString *)name {
    [ADSettings setCustomAppName:name forBundleIdentifier:self.bundleIdentifier];
    if (self.iconView && [self.iconView respondsToSelector:@selector(_updateLabel)]) {
        [self.iconView _updateLabel];
    }
}

#pragma mark - AppStore

- (BOOL)hasAppStoreApp {
    return [self.appProxy respondsToSelector:@selector(itemID)] && [self.appProxy.itemID integerValue] != 0;
}

- (void)openInAppStore {
    NSString *appStoreLink = [NSString stringWithFormat:@"itms-apps://apps.apple.com/app/id%@",self.appProxy.itemID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink] options:@{} completionHandler:nil];
}

#pragma mark - Caches

- (NSURL *)cacheDirectoryURL {
    
    return [self.dataContainerURL URLByAppendingPathComponent:@"/Library/Caches/"];
}

- (NSURL *)tmpDirectoryURL {
    return [self.dataContainerURL URLByAppendingPathComponent:@"/tmp/"];
}

- (NSArray *)cacheDirectoriesURLs {
    NSMutableArray *caches = [NSMutableArray new];
    
    NSURL *cacheDirectoryURL = [self cacheDirectoryURL];
    if (cacheDirectoryURL) [caches addObject:cacheDirectoryURL];
    
    NSURL *tmpDirectoryURL = [self tmpDirectoryURL];
    if (tmpDirectoryURL) [caches addObject:tmpDirectoryURL];
    
    return caches;
}

- (void)getCachesDirectorySizeWithCompletion:(void(^)(NSString *formattedSize))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        unsigned long long int totalSize = 0;
        NSArray <NSURL *> *cacheDirectoriesURLs = [self cacheDirectoriesURLs];
        for (NSURL *url in cacheDirectoriesURLs) {
            if (url && [[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
                unsigned long long int folderSize = 0;
                [[NSFileManager defaultManager] nr_getAllocatedSize:&folderSize ofDirectoryAtURL:url error:nil];
                totalSize += folderSize;
            }
        }
        NSString *formattedSize = [NSByteCountFormatter stringFromByteCount:totalSize countStyle:NSByteCountFormatterCountStyleFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(formattedSize);
        });
    });
}

- (void)clearAppCachesWithCompletion:(void(^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSArray <NSURL *> *cacheDirectoriesURLs = [self cacheDirectoriesURLs];
        for (NSURL *url in cacheDirectoriesURLs) {
            [self.class deleteContentsOfDirectoryAtURL:url];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

+ (void)deleteContentsOfDirectoryAtURL:(NSURL *)url {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *enumerator = [fm enumeratorAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
    NSURL *child;
    while ((child = [enumerator nextObject])) {
        [fm removeItemAtURL:child error:NULL];
    }
}

#pragma mark - App Badges

- (NSInteger)appBadgeCount {
    if ([self.sbApplication respondsToSelector:@selector(badgeValue)]) {
        return [[self.sbApplication badgeValue] integerValue];
    } else if ([self.sbApplication respondsToSelector:@selector(badgeNumberOrString)]) {
        return [[self.sbApplication badgeNumberOrString] integerValue];
    }
    return 0;
}

- (void)setAppBadgeCount:(NSInteger)badgeCount {
    if ([self.sbApplication respondsToSelector:@selector(setBadgeValue:)]) {
        [self.sbApplication setBadgeValue:[NSNumber numberWithInteger:badgeCount]];
    } else {
        [self.sbApplication setBadgeNumberOrString:[NSNumber numberWithInteger:badgeCount]];
    }
}

#pragma mark - Permissions

- (NSArray <NSDictionary *> *)getPermissions {
    CFBundleRef bundle = CFBundleCreate(kCFAllocatorDefault, (CFURLRef)self.appProxy.bundleURL);
    if (bundle) {
        NSArray *information = TCCAccessCopyInformationForBundle(bundle);
        CFRelease(bundle);
        return information;
    }
    return nil;
}

- (void)resetAllAppPermissions {
    SBSApplicationTerminationAssertionRef assertion = SBSApplicationTerminationAssertionCreateWithError(NULL, self.bundleIdentifier, 1, NULL);
    
    [self _resetAllAppPermissions];
    
    if (assertion) {
        SBSApplicationTerminationAssertionInvalidate(assertion);
    }
}

- (void)_resetAllAppPermissions {
    CFBundleRef bundle = CFBundleCreate(kCFAllocatorDefault, (CFURLRef)self.appProxy.bundleURL);
    if (bundle) {
        TCCAccessResetForBundle(kTCCServiceAll, bundle);
        CFRelease(bundle);
    }
    
    // Reset location permission
    [CLLocationManager setAuthorizationStatusByType:kCLAuthorizationStatusNotDetermined forBundleIdentifier:self.bundleIdentifier];
}

#pragma mark - Reset App

- (NSURL *)appLibraryDirectoryURL {
    return [self.dataContainerURL URLByAppendingPathComponent:@"/Library/"];
}

- (NSURL *)appDocumentsDirectoryURL {
    return [self.dataContainerURL URLByAppendingPathComponent:@"/Documents/"];
}

- (NSArray *)appGroupDirectoryURLs {
    NSMutableArray *appGroupDirectoryURLs = [NSMutableArray new];
    for (ADAppDataGroup *group in self.appGroups){
        [appGroupDirectoryURLs addObject:group.url];
    }
    return appGroupDirectoryURLs;
}

- (NSArray *)appUsageDirectoriesURLs {
    NSMutableArray *appUsageDir = [NSMutableArray new];
    
    NSURL *appLibraryDirectoryURL = [self appLibraryDirectoryURL];
    if (appLibraryDirectoryURL) [appUsageDir addObject:appLibraryDirectoryURL];
    
    NSURL *tmpDirectoryURL = [self tmpDirectoryURL];
    if (tmpDirectoryURL) [appUsageDir addObject:tmpDirectoryURL];
    
    NSURL *appDocumentsDirectoryURL = [self appDocumentsDirectoryURL];
    if (appDocumentsDirectoryURL) [appUsageDir addObject:appDocumentsDirectoryURL];
    
    return appUsageDir;
}

- (void)getAppUsageDirectorySizeWithCompletion:(void(^)(NSString *formattedSize))completion {
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        unsigned long long int dynamicSize = [[LSApplicationProxy applicationProxyForIdentifier:self.bundleIdentifier].dynamicDiskUsage unsignedLongLongValue];
//        NSString *formattedSize = [NSByteCountFormatter stringFromByteCount:dynamicSize countStyle:NSByteCountFormatterCountStyleFile];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            completion(formattedSize);
//        });
//    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        unsigned long long int totalSize = 0;
        NSArray <NSURL *> *appUsageDirectoriesURLs = [self appUsageDirectoriesURLs];
        for (NSURL *url in appUsageDirectoriesURLs) {
            if (url && [[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
                unsigned long long int folderSize = 0;
                [[NSFileManager defaultManager] nr_getAllocatedSize:&folderSize ofDirectoryAtURL:url error:nil];
                totalSize += folderSize;
            }
        }
        NSString *formattedSize = [NSByteCountFormatter stringFromByteCount:totalSize countStyle:NSByteCountFormatterCountStyleFile];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(formattedSize);
        });
    });
}

- (void)resetDiskContentWithCompletion:(void(^)())completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SBSApplicationTerminationAssertionRef assertion = SBSApplicationTerminationAssertionCreateWithError(NULL, self.bundleIdentifier, 1, NULL);
        
        NSArray <NSURL *> *appUsage = [self appUsageDirectoriesURLs];
        for (NSURL *url in appUsage) {
            [self.class deleteContentsOfDirectoryAtURL:url];
        }
        
        // Recreate Preferences folder
        if ([self appLibraryDirectoryURL]) {
            [[NSFileManager defaultManager] createDirectoryAtURL:[[self appLibraryDirectoryURL] URLByAppendingPathComponent:@"Preferences" isDirectory:YES] withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        
        // Reset all permissions
        if (self.appStoreVendable) {
            [self _resetAllAppPermissions];
        }

        if (assertion) {
            SBSApplicationTerminationAssertionInvalidate(assertion);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}

#pragma mark - Offload App

- (void)offloadAppWithCompletion:(void(^)())completion{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (@available(iOS 12.0, *)){
            [NSClassFromString(@"IXAppInstallCoordinator") demoteAppToPlaceholderWithBundleID:self.bundleIdentifier forReason:1 waitForDeletion:YES completion:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion();
                });
            }];
        } else {
            [NSClassFromString(@"IXAppInstallCoordinator") demoteAppToPlaceholderWithBundleID:self.bundleIdentifier forReason:1 error:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}

@end

@implementation ADAppDataGroup

+ (ADAppDataGroup *)groupWithIdentifier:(NSString *)identifier url:(NSURL *)url {
    ADAppDataGroup *group = [ADAppDataGroup new];
    group.identifier = identifier;
    group.url = url;
    return group;
}

@end

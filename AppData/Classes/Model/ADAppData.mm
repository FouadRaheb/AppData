#line 1 "/Users/udevs/Documents/tweakMS/AppData/AppData/Classes/Model/ADAppData.xm"







#import "ADAppData.h"
#import "NRFileManager.h"

typedef const struct __SBSApplicationTerminationAssertion *SBSApplicationTerminationAssertionRef;

extern "C" SBSApplicationTerminationAssertionRef SBSApplicationTerminationAssertionCreateWithError(void *unknown, NSString *bundleIdentifier, int reason, int *outError);
extern "C" void SBSApplicationTerminationAssertionInvalidate(SBSApplicationTerminationAssertionRef assertion);
extern "C" NSString *SBSApplicationTerminationAssertionErrorString(int error);

@interface ADAppData ()
@property (nonatomic, strong) LSApplicationProxy *appProxy;

@property (nonatomic, strong) SBApplication *sbApplication;
@end

@implementation ADAppData

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
    
    self.version = self.appProxy.shortVersionString ? : self.appProxy.bundleVersion;
    self.bundleIdentifier = self.appProxy.bundleIdentifier;
    
    
    self.bundleURL = self.appProxy.bundleURL ? : self.appProxy.bundleContainerURL;
    self.dataContainerURL = self.appProxy.dataContainerURL;
    NSMutableArray *appGroups = [NSMutableArray new];
    NSArray *sortedKeys = [self.appProxy.groupContainerURLs.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *key in sortedKeys) {
        NSURL *url = [self.appProxy.groupContainerURLs objectForKey:key];
        ADAppDataGroup *group = [ADAppDataGroup groupWithIdentifier:key url:url];
        [appGroups addObject:group];
    }
    self.appGroups = appGroups;
    
    
    self.diskUsage = [self.appProxy.staticDiskUsage integerValue];
    self.diskUsageString = [NSByteCountFormatter stringFromByteCount:[self.appProxy.staticDiskUsage longLongValue] countStyle:NSByteCountFormatterCountStyleFile];
        
    
    [self loadMoreInfo];
}

- (void)loadMoreInfo {
    
    self.entitlements = self.appProxy.entitlements;
    self.entitlementsIdentifiers = self.entitlements.allKeys;
    
    ASYNC({
        NSURL *infoPlistURL = [self.bundleURL URLByAppendingPathComponent:@"Info.plist"];
        NSDictionary *infoDictionary = [NSDictionary dictionaryWithContentsOfURL:infoPlistURL];
        
        if (infoDictionary) {
            
            NSArray *bundleURLTypes = [infoDictionary objectForKey:@"CFBundleURLTypes"];
            if ([bundleURLTypes isKindOfClass:[NSArray class]]) {
                if (bundleURLTypes.firstObject && [bundleURLTypes.firstObject isKindOfClass:[NSDictionary class]]) {
                    id urlSchemes = [bundleURLTypes.firstObject objectForKey:@"CFBundleURLSchemes"];
                    if ([urlSchemes isKindOfClass:[NSArray class]]) {
                        self.urlSchemes = urlSchemes;
                    }
                }
            }
            
            
            id queriesSchemes = [infoDictionary objectForKey:@"LSApplicationQueriesSchemes"];
            if ([queriesSchemes isKindOfClass:[NSArray class]]) {
                self.queriesSchemes = queriesSchemes;
            }
            
            
            id activityTypes = [infoDictionary objectForKey:@"NSUserActivityTypes"];
            if ([activityTypes isKindOfClass:[NSArray class]]) {
                self.activityTypes = activityTypes;
            }
            
            
            id backgroundModes = [infoDictionary objectForKey:@"UIBackgroundModes"];
            if ([backgroundModes isKindOfClass:[NSArray class]]) {
                self.backgroundModes = backgroundModes;
            }
            
            
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
    return [ADHelper customAppNameForBundleIdentifier:self.bundleIdentifier];
}

- (void)setCustomIconName:(NSString *)name {
    [ADHelper setCustomAppName:name forBundleIdentifier:self.bundleIdentifier];
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

#pragma mark - Reset

- (void)resetDiskContent {
    NSURL *dataContainer = self.appProxy.dataContainerURL;
    SBSApplicationTerminationAssertionRef assertion = SBSApplicationTerminationAssertionCreateWithError(NULL, self.bundleIdentifier, 1, NULL);
    [self.class deleteContentsOfDirectoryAtURL:[dataContainer URLByAppendingPathComponent:@"tmp" isDirectory:YES]];
    
    NSURL *libraryURL = [dataContainer URLByAppendingPathComponent:@"Library" isDirectory:YES];
    [self.class deleteContentsOfDirectoryAtURL:libraryURL];

    [[NSFileManager defaultManager] createDirectoryAtURL:[libraryURL URLByAppendingPathComponent:@"Preferences" isDirectory:YES] withIntermediateDirectories:YES attributes:nil error:NULL];
    
    [self.class deleteContentsOfDirectoryAtURL:[dataContainer URLByAppendingPathComponent:@"Documents" isDirectory:YES]];

    if (assertion) {
        SBSApplicationTerminationAssertionInvalidate(assertion);
    }
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

#pragma mark - Helpers

+ (SBApplication *)sbApplicationForBundleIdentifier:(NSString *)bundleIdentifier {
    if ([[NSClassFromString(@"SBApplicationController") sharedInstance] respondsToSelector:@selector(applicationWithBundleIdentifier:)]) {
        return [[NSClassFromString(@"SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];
    }
    return nil;
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

//
//  ADAppData.h
//  AppData
//
//  Created by Fouad Raheb on 6/28/20.
//

#import <Foundation/Foundation.h>

@interface ADAppDataGroup : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSURL *url;
+ (ADAppDataGroup *)groupWithIdentifier:(NSString *)identifier url:(NSURL *)url;
@end

@interface ADAppData : NSObject
@property (nonatomic, strong) LSApplicationProxy *appProxy;

@property (nonatomic, strong) SBIconView *iconView;

@property (nonatomic, strong) UIImage *iconImage;

- (NSString *)name;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *bundleIdentifier;

@property (nonatomic, strong) NSURL *bundleURL;
@property (nonatomic, strong) NSURL *dataContainerURL;
@property (nonatomic, strong) NSArray <ADAppDataGroup *> *appGroups;

@property (nonatomic, assign) NSInteger diskUsage;
@property (nonatomic, strong) NSString *diskUsageString;

// More Info
@property (nonatomic, strong) NSDictionary *entitlements;
@property (nonatomic, strong) NSArray <NSString *> *entitlementsIdentifiers;
@property (nonatomic, strong) NSString *minimumOSVersion;
@property (nonatomic, strong) NSString *internalVersion;
@property (nonatomic, strong) NSString *platformVersion;
@property (nonatomic, strong) NSArray <NSString *> *urlSchemes;
@property (nonatomic, strong) NSArray <NSString *> *queriesSchemes;
@property (nonatomic, strong) NSArray <NSString *> *activityTypes;
@property (nonatomic, strong) NSArray <NSString *> *backgroundModes;

+ (ADAppData *)appDataForBundleIdentifier:(NSString *)bundleIdentifier iconImage:(UIImage *)iconImage;

- (BOOL)isApplication;

#pragma mark - Icon Name

- (NSString *)customIconName;
- (void)setCustomIconName:(NSString *)name;

#pragma mark - AppStore

- (BOOL)hasAppStoreApp;
- (void)openInAppStore;

#pragma mark Reset Permissions

- (void)resetAllAppPermissions;

#pragma mark Reset App
- (void)getAppUsageDirectorySizeWithCompletion:(void(^)(NSString *formattedSize))completion;
- (void)resetDiskContentWithCompletion:(void(^)())completion;

#pragma mark - Caches

- (void)getCachesDirectorySizeWithCompletion:(void(^)(NSString *formattedSize))completion;
- (void)clearAppCachesWithCompletion:(void(^)())completion;

#pragma mark - App Badges

- (void)setAppBadgeCount:(NSInteger)badgeCount;
- (NSInteger)appBadgeCount;

#pragma mark Offload App

- (void)offloadAppWithCompletion:(void(^)())completion;

@end

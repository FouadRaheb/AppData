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

@property (nonatomic, strong) SBIconView *iconView;

@property (nonatomic, strong) UIImage *iconImage;

- (NSString *)name;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *bundleIdentifier;

@property (nonatomic, strong) NSURL *bundleContainerURL;
@property (nonatomic, strong) NSURL *dataContainerURL;
@property (nonatomic, strong) NSArray <ADAppDataGroup *> *appGroups;

@property (nonatomic, strong) NSDictionary *entitlements;

@property (nonatomic, assign) NSInteger diskUsage;
@property (nonatomic, strong) NSString *diskUsageString;

+ (ADAppData *)appDataForBundleIdentifier:(NSString *)bundleIdentifier iconImage:(UIImage *)iconImage;

- (BOOL)isApplication;

#pragma mark - Icon Name

- (NSString *)customIconName;
- (void)setCustomIconName:(NSString *)name;

#pragma mark - AppStore

- (BOOL)hasAppStoreApp;
- (void)openInAppStore;

#pragma mark - Caches

- (void)getCachesDirectorySizeWithCompletion:(void(^)(NSString *formattedSize))completion;
- (void)clearAppCachesWithCompletion:(void(^)())completion;

#pragma mark - App Badges

- (void)setAppBadgeCount:(NSInteger)badgeCount;
- (NSInteger)appBadgeCount;

@end

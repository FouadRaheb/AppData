//
//  ADHelper.h
//  AppData
//
//  Created by Fouad Raheb on 6/29/20.
//

#import <Foundation/Foundation.h>

#define kAppDataSwipeUpPreferencesChangedNotification    @"com.fouadraheb.appdata.swipeup-preferences-changed"

#define kSwipeUpEnabled                                         @"SwipeUpEnabled"
#define kForceTouchMenuEnabled                                  @"ForceTouchMenuEnabled"
#define kCustomAppNames                                         @"CustomAppNames"

#define kSBApplicationShortcutItemType                          @"com.fouadraheb.appdata"

@interface ADHelper : NSObject

@property (nonatomic) __weak SBFloatingDockViewController *dockViewController;

+ (instancetype)sharedInstance;

- (void)initialize;

+ (UIImage *)imageNamed:(NSString *)imageName;

+ (SBSApplicationShortcutItem *)applicationShortcutItem;

+ (BOOL)swipeUpEnabled;
+ (BOOL)forceTouchMenuEnabled;

+ (NSString *)customAppNameForBundleIdentifier:(NSString *)identifier;
+ (void)setCustomAppName:(NSString *)name forBundleIdentifier:(NSString *)bundleIdentifier;

@end

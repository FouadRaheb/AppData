//
//  ADHelper.h
//  AppData
//
//  Created by Fouad Raheb on 6/29/20.
//

#import <Foundation/Foundation.h>

#define kAppDataForceTouchMenuPreferencesChangedNotification    @"com.fouadraheb.appdata.forcetouchmenu-changed"

#define kSwipeUpEnabled                                         @"SwipeUpEnabled"
#define kForceTouchMenuEnabled                                  @"ForceTouchMenuEnabled"

#define kSBApplicationShortcutItemType                          @"com.fouadraheb.appdata"

@interface ADHelper : NSObject

+ (instancetype)sharedInstance;
- (void)initialize;

+ (BOOL)swipeUpEnabled;
+ (BOOL)forceTouchMenuEnabled;

+ (UIImage *)imageNamed:(NSString *)imageName;

+ (SBSApplicationShortcutItem *)applicationShortcutItem;

@end

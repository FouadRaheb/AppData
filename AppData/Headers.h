//
//  Headers.h
//  AppData
//
//  Created by Fouad Raheb on 6/28/20.
//

#ifndef Headers_h
#define Headers_h

// UIKit

@interface UIImage ()
+ (id)imageNamed:(id)arg1 inBundle:(id)arg2;
@end

@interface UIView (Private)
- (UIViewController *)_viewControllerForAncestor;
@end


// Core Services

@interface LSResourceProxy : NSObject
@end

@interface LSBundleProxy : LSResourceProxy
@property (nonatomic,readonly) NSString * localizedShortName;
@property (nonatomic,copy) NSArray * machOUUIDs;
@property (nonatomic,copy) NSString * sdkVersion;
@property (nonatomic,readonly) NSString * bundleIdentifier;
@property (nonatomic,readonly) NSString * bundleType;
@property (nonatomic,readonly) NSURL * bundleURL;
@property (nonatomic,readonly) NSString * bundleExecutable;
@property (nonatomic,readonly) NSString * canonicalExecutablePath;
@property (nonatomic,readonly) NSURL * containerURL;
@property (nonatomic,readonly) NSURL * dataContainerURL;
@property (nonatomic,readonly) NSURL * bundleContainerURL;
@property (nonatomic,readonly) NSURL * appStoreReceiptURL;
@property (nonatomic,readonly) NSString * bundleVersion;
@property (nonatomic,readonly) NSString * signerIdentity;
@property (nonatomic,readonly) NSDictionary * entitlements;
@property (nonatomic,readonly) NSDictionary * environmentVariables;
@property (nonatomic,readonly) NSDictionary * groupContainerURLs;
@end

@interface LSApplicationProxy : LSBundleProxy
+ (LSApplicationProxy *)applicationProxyForIdentifier:(NSString *)identifier;
@property (nonatomic,readonly) NSString *shortVersionString;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, strong) NSNumber *itemID;
@property (nonatomic,readonly) NSNumber * staticDiskUsage;
@property (nonatomic,readonly) NSNumber * dynamicDiskUsage;
@property (nonatomic,readonly) NSNumber * ODRDiskUsage;
// iOS 13
@property (nonatomic,readonly) NSSet *claimedDocumentContentTypes;
@property (nonatomic,readonly) NSSet *claimedURLSchemes;
@end


// SpringBoard

@interface SBApplicationInfo : NSObject
- (NSURL *)dataContainerURL;
@end

@interface SBApplication : NSObject
@property (nonatomic, retain) SBApplicationInfo * info;
@property (nonatomic,readonly) NSString * displayName;
-(void)purgeCaches;
@property (nonatomic,copy) id badgeValue; // iOS 12 and newer
@property (assign,nonatomic) id badgeNumberOrString; // iOS 11 and older
- (NSString *)bundleIdentifier;
@end

@interface SBApplicationController : NSObject
+ (instancetype)sharedInstance;
- (SBApplication *)applicationWithBundleIdentifier:(NSString *)identifier;
@end

@interface SBIcon : NSObject
- (NSString *)applicationBundleID;
- (SBApplication *)application;
- (NSInteger)badgeValue;
@end

@interface SBFolderIcon : SBIcon
@end

@interface SBIconView : UIView
@property (nonatomic, retain) SBIcon *icon;
@property (nonatomic, retain) SBFolderIcon * folderIcon;
- (id)_iconImageView;
- (void)_updateLabel;
- (BOOL)ad_isFolderIcon;
@end

@interface SBSApplicationShortcutIcon : NSObject
@end

@interface SBSApplicationShortcutCustomImageIcon : SBSApplicationShortcutIcon
- (id)initWithImagePNGData:(id)arg1;
@end

@interface SBSApplicationShortcutItem : NSObject
@property (nonatomic,copy) SBSApplicationShortcutIcon *icon;
@property (nonatomic,copy) NSString * type;
@property (nonatomic,copy) NSString * localizedTitle;
@end

@interface SBIconImageView : UIView
@property (nonatomic, strong) UISwipeGestureRecognizer *adSwipeGestureRecognizer;
- (UIImage *)contentsImage;
- (void)appDataPreferencesChanged;
@end


@interface SBFloatingDockViewController : UIViewController
@end

@interface SBFloatingDockController : NSObject
@property (nonatomic,readonly) SBFloatingDockViewController *floatingDockViewController;
- (BOOL)isFloatingDockPresented;
- (void)_presentFloatingDockIfDismissedAnimated:(BOOL)arg1 completionHandler:(/*^block*/id)arg2 ;
- (void)_dismissFloatingDockIfPresentedAnimated:(BOOL)arg1 completionHandler:(/*^block*/id)arg2 ;
@end

@interface SBIconController : NSObject
+ (instancetype)sharedInstance;
@property (nonatomic,readonly) SBFloatingDockController * floatingDockController;
@end

@interface SBUIAppIconForceTouchControllerDataProvider : NSObject
@property (nonatomic,readonly) NSString * applicationBundleIdentifier;
@property (nonatomic,readonly) UIGestureRecognizer *gestureRecognizer;
@end

@interface SBUIAppIconForceTouchController : NSObject
- (void)dismissAnimated:(BOOL)arg1 withCompletionHandler:(/*^block*/id)arg2;
@end

#endif /* Headers_h */

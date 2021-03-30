//
//  ADHelper.h
//  AppData
//
//  Created by Fouad Raheb on 6/29/20.
//

#import <Foundation/Foundation.h>

#define kSBApplicationShortcutItemType  @"com.fouadraheb.appdata"

@interface ADHelper : NSObject

+ (instancetype)sharedInstance;

+ (UIImage *)imageNamed:(NSString *)imageName;

+ (void)openDirectoryAtURL:(NSURL *)url fromController:(UIViewController *)controller;

+ (SBSApplicationShortcutItem *)applicationShortcutItem;

@end

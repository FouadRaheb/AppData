//
//  ADPrefsHelper.h
//  AppDataPrefs
//
//  Created by Fouad Raheb on 3/29/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ADPrefsHelper : NSObject
+ (UIImage *)imageNamed:(NSString *)imageName;
@end

// Private
@interface UIImage ()
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

//
//  ADPrefsHelper.h
//  AppDataPrefs
//
//  Created by Fouad Raheb on 3/29/21.
//

#import "ADPrefsHelper.h"
#import <UIKit/UIKit.h>

@interface ADPrefsHelper ()
@property (nonatomic, strong) NSBundle *prefsBundle;
@end

@implementation ADPrefsHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t p = 0;
    __strong static ADPrefsHelper *_sharedInstance = nil;
    dispatch_once(&p, ^{
        _sharedInstance = [[self alloc] init];
        
        _sharedInstance.prefsBundle = [NSBundle bundleForClass:self.class];
    });
    return _sharedInstance;
}

#pragma mark - Resources

+ (UIImage *)imageNamed:(NSString *)imageName {
    return [UIImage imageNamed:imageName inBundle:ADPrefsHelper.sharedInstance.prefsBundle];
}

@end

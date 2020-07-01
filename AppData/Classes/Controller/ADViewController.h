//
//  ADViewController.h
//  AppData
//
//  Created by Fouad Raheb on 6/29/20.
//

#import <UIKit/UIKit.h>
#import "ADAppData.h"

@interface ADDataViewController : UIViewController

- (instancetype)initWithAppData:(ADAppData *)data;

+ (void)presentControllerFromSBIconImageView:(SBIconImageView *)iconImageView;
+ (void)presentControllerFromSBIconView:(SBIconView *)iconView;

@end

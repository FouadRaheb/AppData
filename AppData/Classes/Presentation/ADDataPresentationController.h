//
//  ADDataPresentationController.h
//  AppData
//
//  Created by Fouad Raheb on 6/29/20.
//

#import <UIKit/UIKit.h>
#import "ADDataPresentationManager.h"

@interface ADDataPresentationController : UIPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
                                  configuration:(ADDataPresentationConfiguration *)configuration;

@end

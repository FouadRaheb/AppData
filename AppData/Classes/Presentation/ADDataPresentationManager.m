//
//  ADDataPresentationManager.m
//  AppData
//
//  Created by Fouad Raheb on 6/29/20.
//

#import "ADDataPresentationManager.h"
#import "ADDataPresentationController.h"
#import "ADDataPresentationAnimator.h"

@implementation ADDataPresentationManager

- (instancetype)initWithConfiguration:(ADDataPresentationConfiguration *)configuration {
    if (self = [super init]) {
        self.configuration = configuration ? : [[ADDataPresentationConfiguration alloc] init];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.configuration = [[ADDataPresentationConfiguration alloc] init];
    }
    return self;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[ADDataPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting configuration:self.configuration];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[ADDataPresentationAnimator alloc] initWithConfiguration:self.configuration isPresentation:YES];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[ADDataPresentationAnimator alloc] initWithConfiguration:self.configuration isPresentation:NO];
}

@end


@implementation ADDataPresentationConfiguration

- (instancetype)init {
    if (self = [super init]) {
        self.animationDuration = 0.25;
        
        self.screenPercentage = 66.66;
        
        self.direction = ADDataPresentationDirectionBottom;
        
        self.dimmingViewBackgroundColor = [UIColor colorWithWhite:0.f alpha:0.3f];
    }
    return self;
}

@end

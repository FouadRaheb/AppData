//
//  ADDataPresentationController.m
//  AppData
//
//  Created by Fouad Raheb on 6/29/20.
//

#import "ADDataPresentationController.h"
#import "ADDataViewController.h"

@interface ADDataPresentationController ()
@property (nonatomic, strong) UIView *dimmingView;
@property (nonatomic, assign) ADDataPresentationConfiguration *configuration;
@end

@implementation ADDataPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController
                                  configuration:(ADDataPresentationConfiguration *)configuration {
    if (self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController]) {
        self.configuration = configuration;
        
        self.dimmingView = [[UIView alloc] initWithFrame:CGRectZero];
        self.dimmingView.backgroundColor = configuration.dimmingViewBackgroundColor;
        self.dimmingView.alpha = 0;
        self.dimmingView.translatesAutoresizingMaskIntoConstraints = NO;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [self.dimmingView addGestureRecognizer:tapGesture];
        
        UISwipeGestureRecognizer *swipeDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [swipeDownGesture setDirection:UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp];
        [self.dimmingView addGestureRecognizer:swipeDownGesture];
        
        self.dimmingView.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dismiss {
    if ([self.presentedViewController respondsToSelector:@selector(dismiss)]) {
        [(ADDataViewController *)self.presentedViewController dismiss];
    } else {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Override

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];
    
    [self.containerView insertSubview:self.dimmingView atIndex:0];
    [self.dimmingView.topAnchor constraintEqualToAnchor:self.containerView.topAnchor].active = YES;
    [self.dimmingView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor].active = YES;
    [self.dimmingView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor].active = YES;
    [self.dimmingView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor].active = YES;
    
    if (!self.presentedViewController.transitionCoordinator) {
        self.dimmingView.alpha = 1.f;
        return;
    }
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 1.f;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    
    }];
}

- (void)dismissalTransitionWillBegin {
    [super dismissalTransitionWillBegin];
    
    if (!self.presentedViewController.transitionCoordinator) {
        self.dimmingView.alpha = 0.f;
        return;
    }
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0.f;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
    }];
}

- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGRect frame = CGRectZero;

    if (self.configuration.customFrameHandler) {
        frame = self.configuration.customFrameHandler(self.containerView);
    } else {
        frame.size = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:self.containerView.bounds.size];
        
        switch (self.configuration.direction) {
            case ADDataPresentationDirectionRight:
                frame.origin.x = self.containerView.frame.size.width * (1 - (self.configuration.screenPercentage / 100));
                break;
            case ADDataPresentationDirectionBottom:
                frame.origin.y = self.containerView.frame.size.height * (1 - (self.configuration.screenPercentage / 100));
                break;
            default:
                frame.origin = CGPointZero;
                break;
        }
    }
    
    return frame;
}

- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    if (self.configuration.customFrameHandler) {
        return self.configuration.customFrameHandler(self.containerView).size;
    }
    switch (self.configuration.direction) {
        case ADDataPresentationDirectionLeft:
        case ADDataPresentationDirectionRight:
            return CGSizeMake(parentSize.width * (self.configuration.screenPercentage / 100), parentSize.height);
        case ADDataPresentationDirectionTop:
        case ADDataPresentationDirectionBottom:
            return CGSizeMake(parentSize.width, parentSize.height * (self.configuration.screenPercentage / 100));
        default:
            return CGSizeZero;
    }
}

@end

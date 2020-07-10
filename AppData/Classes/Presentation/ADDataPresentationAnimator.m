//
//  ADDataPresentationAnimator.m
//  AppData
//
//  Created by Fouad Raheb on 6/29/20.
//

#import "ADDataPresentationAnimator.h"

@interface ADDataPresentationAnimator ()
@property (nonatomic, assign) ADDataPresentationConfiguration *configuration;
@property (nonatomic, assign) BOOL isPresentation;
@end

@implementation ADDataPresentationAnimator

- (instancetype)initWithConfiguration:(ADDataPresentationConfiguration *)configuration isPresentation:(BOOL)presentation {
    if (self = [super init]) {
        self.configuration = configuration;
        self.isPresentation = presentation;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return self.configuration.animationDuration;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
    UITransitionContextViewControllerKey key = self.isPresentation ? UITransitionContextToViewControllerKey : UITransitionContextFromViewControllerKey;
    UIViewController *controller = [transitionContext viewControllerForKey:key];
    if (!controller) return;
        
    if (self.isPresentation) {
        [transitionContext.containerView addSubview:controller.view];
    }
    
    CGRect presentedFrame = [transitionContext finalFrameForViewController:controller];
    CGRect dismissedFrame = presentedFrame;
    
    
    if (!CGRectEqualToRect(self.configuration.sourceRect, CGRectZero)) {
        dismissedFrame = self.configuration.sourceRect;
    } else {
        switch (self.configuration.direction) {
            case ADDataPresentationDirectionTop:
                dismissedFrame.origin.y = -presentedFrame.size.height;
                break;
            case ADDataPresentationDirectionBottom:
                dismissedFrame.origin.y = transitionContext.containerView.frame.size.height;
                break;
            case ADDataPresentationDirectionLeft:
                dismissedFrame.origin.x = -presentedFrame.size.width;
                break;
            case ADDataPresentationDirectionRight:
                dismissedFrame.origin.x = transitionContext.containerView.frame.size.width;
                break;
            default:
                break;
        }
    }
    
    CGRect initialFrame = self.isPresentation ? dismissedFrame : presentedFrame;
    CGRect finalFrame = self.isPresentation ? presentedFrame : dismissedFrame;
    
    CGFloat initialAlpha = self.isPresentation ? self.configuration.fadeAnimationAlpha : 1.0;
    CGFloat finalAlpha = self.isPresentation ? 1.0 : self.configuration.fadeAnimationAlpha;
    
    NSTimeInterval animationDuration = [self transitionDuration:transitionContext];
    controller.view.frame = initialFrame;
    if (self.configuration.fadeAnimation) {
        controller.view.alpha = initialAlpha;
    }
  
    [UIView animateWithDuration:animationDuration animations:^{
        controller.view.frame = finalFrame;
        if (self.configuration.fadeAnimation) {
            controller.view.alpha = finalAlpha;
        }
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

@end

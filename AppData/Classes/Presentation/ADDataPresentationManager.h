//
//  ADDataPresentationManager.h
//  AppData
//
//  Created by Fouad Raheb on 6/29/20.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ADDataPresentationDirection) {
    ADDataPresentationDirectionBottom = 0,
    ADDataPresentationDirectionTop = 1,
    ADDataPresentationDirectionLeft = 2,
    ADDataPresentationDirectionRight = 3
};

typedef CGRect(^ADDataPresentationFrameHandler)(UIView *containerView);

@interface ADDataPresentationConfiguration : NSObject

@property (nonatomic, assign) CGFloat animationDuration; // default 0.25

@property (nonatomic, strong) UIColor *dimmingViewBackgroundColor; // default [UIColor colorWithWhite:0.f alpha:0.3f]

@property (nonatomic, assign) ADDataPresentationDirection direction; // default is ADDataPresentationDirectionBottom

@property (nonatomic, assign) CGRect sourceRect; // detault CGRectZero, the view to animate the popup from

@property (nonatomic, assign) CGFloat screenPercentage; // detault value is 66.66

@property (nonatomic, assign) BOOL fadeAnimation; // default NO
@property (nonatomic, assign) CGFloat fadeAnimationAlpha; // default is 0

@property (nonatomic, strong) ADDataPresentationFrameHandler customFrameHandler;

@end

@interface ADDataPresentationManager : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) ADDataPresentationConfiguration *configuration;

- (instancetype)initWithConfiguration:(ADDataPresentationConfiguration *)configuration;

@end

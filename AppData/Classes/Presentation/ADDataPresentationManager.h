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

@interface ADDataPresentationConfiguration : NSObject

@property (nonatomic, assign) ADDataPresentationDirection direction; // default is ADDataPresentationDirectionBottom

@property (nonatomic, assign) CGFloat screenPercentage; // detault value is 66.66

@end

@interface ADDataPresentationManager : NSObject <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) ADDataPresentationConfiguration *configuration;

- (instancetype)initWithConfiguration:(ADDataPresentationConfiguration *)configuration;

@end

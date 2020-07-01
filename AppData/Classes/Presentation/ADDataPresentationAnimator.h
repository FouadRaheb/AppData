//
//  ADDataPresentationAnimator.h
//  AppData
//
//  Created by Fouad Raheb on 6/29/20.
//

#import <Foundation/Foundation.h>
#import "ADDataPresentationManager.h"

@interface ADDataPresentationAnimator : NSObject <UIViewControllerAnimatedTransitioning>

- (instancetype)initWithConfiguration:(ADDataPresentationConfiguration *)configuration isPresentation:(BOOL)presentation;

@end

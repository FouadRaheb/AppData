//
//  ADActionsBarView.h
//  AppData
//
//  Created by Fouad Raheb on 12/3/20.
//  Copyright © 2020 Fouad Raheb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ADActionBarBlock)(void);

@interface ADActionsBarView : UIStackView

- (void)addItemWithTitle:(NSString *)title detail:(NSString *)detail image:(UIImage *)image handler:(ADActionBarBlock)handler;

- (void)setTitle:(NSString *)title forItemAtIndex:(NSInteger)index;
- (void)setDetail:(NSString *)detail forItemAtIndex:(NSInteger)index;

- (void)hideLoadingIndicatorForItemAtIndex:(NSInteger)index;
- (void)showLoadingIndicatorForItemAtIndex:(NSInteger)index;

- (void)setItemEnabled:(BOOL)enabled atIndex:(NSInteger)index;

@end

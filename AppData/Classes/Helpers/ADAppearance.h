//
//  ADAppearance.h
//  AppData
//
//  Created by Fouad Raheb on 3/29/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ADAppearanceStyle) {
    ADAppearanceStyleDark = 0,
    ADAppearanceStyleLight = 1,
    ADAppearanceStyleAutomatic = 2,
};

@interface ADAppearance : NSObject

+ (instancetype)sharedInstance;

- (UIBlurEffectStyle)blurEffectStyle;

- (UIColor *)primaryTextColor;
- (UIColor *)secondaryTextColor;

- (UIColor *)actionsBarIconTintColor;

- (UIColor *)tableSeparatorColor;
- (UIColor *)tableHeaderTextColor;
- (UIView *)tableCellSelectedBackgroundView;
- (UIImageView *)tableCellChevronImageView;

- (UIActivityIndicatorView *)activityIndicatorView;

#pragma mark - Styles Helpers

+ (void)applyStylesToCell:(UITableViewCell *)cell;

@end

//
//  ADAppearance.m
//  AppData
//
//  Created by Fouad Raheb on 3/29/21.
//

#import "ADAppearance.h"

@interface ADAppearance ()
@property (nonatomic, assign) ADAppearanceStyle currentStyle;
@end

@implementation ADAppearance

+ (instancetype)sharedInstance {
    static dispatch_once_t p = 0;
    __strong static ADAppearance *_sharedInstance = nil;
    dispatch_once(&p, ^{
        _sharedInstance = [[self alloc] init];
        [_sharedInstance initialize];
    });
    return _sharedInstance;
}

- (void)initialize {
    self.currentStyle = [ADSettings appearanceStyle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDataAppearanceChanged:) name:kAppDataAppearancePreferencesChangedNotification object:nil];
}

- (void)appDataAppearanceChanged:(NSNotification *)notification {
    self.currentStyle = [ADSettings appearanceStyle];
}

- (BOOL)isDarkStyle {
    if (self.currentStyle == ADAppearanceStyleAutomatic) {
        if (@available(iOS 13.0, *)) {
            return [UITraitCollection currentTraitCollection].userInterfaceStyle == UIUserInterfaceStyleDark;
        }
    }
    return self.currentStyle == ADAppearanceStyleDark;
}

#pragma mark - Colors

- (UIBlurEffectStyle)blurEffectStyle {
    if (self.isDarkStyle) {
        return UIBlurEffectStyleDark;
    } else {
        if (@available(iOS 13.0, *)) {
            return UIBlurEffectStyleSystemThinMaterialLight;
        } else {
            return UIBlurEffectStyleLight;
        }
    }
}

- (UIColor *)primaryTextColor {
    return self.isDarkStyle ? [UIColor whiteColor] : [UIColor blackColor];
}

- (UIColor *)secondaryTextColor {
    return self.isDarkStyle
    ? [UIColor colorWithRed:0.922 green:0.922 blue:0.961 alpha:0.6]
    : [UIColor colorWithRed:0.235294 green:0.235294 blue:0.262745 alpha:0.75];
}

- (UIColor *)actionsBarIconTintColor {
    return self.isDarkStyle
    ? [UIColor colorWithRed:0.557 green:0.557 blue:0.577 alpha:1.0]
    : [UIColor colorWithRed:0.235294 green:0.235294 blue:0.262745 alpha:0.70];
}

- (UIColor *)tableSeparatorColor {
    return [UIColor colorWithRed:0.329 green:0.329 blue:0.345 alpha:0.6];
}

- (UIColor *)tableHeaderTextColor {
    return self.isDarkStyle
    ? [UIColor colorWithRed:0.557 green:0.557 blue:0.577 alpha:1.0]
    : [UIColor colorWithRed:0.39 green:0.39 blue:0.39 alpha:1.0];
}

- (UIView *)tableCellSelectedBackgroundView {
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = self.isDarkStyle ? [[UIColor grayColor] colorWithAlphaComponent:0.15] : [[UIColor grayColor] colorWithAlphaComponent:0.35];
    return backgroundView;
}

- (UIImageView *)tableCellChevronImageView {
    UIImage *image = nil;
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        image = [[ADHelper imageNamed:@"ChevronLeft"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        image = [[ADHelper imageNamed:@"ChevronRight"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, 10.5, 13.36);
    imageView.tintColor = self.isDarkStyle ? [UIColor colorWithRed:0.66 green:0.66 blue:0.66 alpha:0.5] : [[UIColor grayColor] colorWithAlphaComponent:0.6];
    return imageView;
}

- (UIActivityIndicatorView *)activityIndicatorView {
    UIActivityIndicatorView *activityIndicatorView = nil;
    if (@available(iOS 13.0, *)) {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    } else {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    activityIndicatorView.color = [self secondaryTextColor];
    return activityIndicatorView;
}

#pragma mark - Styles Helpers

+ (void)applyStylesToCell:(UITableViewCell *)cell {
    cell.textLabel.textColor = [ADAppearance.sharedInstance primaryTextColor];
    cell.detailTextLabel.textColor = [ADAppearance.sharedInstance secondaryTextColor];
    
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
        cell.selectedBackgroundView = [ADAppearance.sharedInstance tableCellSelectedBackgroundView];
    }
}

@end

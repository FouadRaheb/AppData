//
//  ADActionsBarView.m
//  AppData
//
//  Created by Fouad Raheb on 12/3/20.
//  Copyright © 2020 Fouad Raheb. All rights reserved.
//

#import "ADActionsBarView.h"

@interface ADActionsBarView ()
@property (nonatomic, strong) UIStackView *stackView;
@end

@interface ADActionButton : UIButton
@property (nonatomic, strong) ADActionBarBlock actionBlock;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIImageView *actionImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation ADActionsBarView

- (instancetype)init {
    if (self = [super init]) {
        self.axis = UILayoutConstraintAxisHorizontal;
        self.alignment = UIStackViewAlignmentFill;
        self.distribution = UIStackViewDistributionFillEqually;
        self.spacing = 1;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)addItemWithTitle:(NSString *)title detail:(NSString *)detail image:(UIImage *)image handler:(ADActionBarBlock)handler {
    ADActionButton *view = [[ADActionButton alloc] initWithFrame:CGRectZero];
    [view setActionBlock:handler];
    [view addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [view addTarget:self action:@selector(buttonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [view addTarget:self action:@selector(touchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [view addTarget:self action:@selector(buttonDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
    [view addTarget:self action:@selector(buttonDragInside:) forControlEvents:UIControlEventTouchDragInside];
        
    view.actionImageView = [[UIImageView alloc] init];
    view.actionImageView.userInteractionEnabled = NO;
    [view.actionImageView setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    view.actionImageView.contentMode = UIViewContentModeScaleAspectFill;
    view.actionImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:view.actionImageView];
    [view.actionImageView.topAnchor constraintEqualToAnchor:view.topAnchor constant:5].active = YES;
    [view.actionImageView.centerXAnchor constraintEqualToAnchor:view.centerXAnchor].active = YES;
    [view.actionImageView.widthAnchor constraintEqualToAnchor:view.actionImageView.heightAnchor].active = YES;
    [view.actionImageView.heightAnchor constraintEqualToAnchor:view.heightAnchor multiplier:0.35].active = YES;
    
    UIView *activityContainerView = [[UIView alloc] init];
    activityContainerView.userInteractionEnabled = NO;
    activityContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:activityContainerView];
    [activityContainerView.topAnchor constraintEqualToAnchor:view.actionImageView.topAnchor].active = YES;
    [activityContainerView.leadingAnchor constraintEqualToAnchor:view.actionImageView.leadingAnchor].active = YES;
    [activityContainerView.widthAnchor constraintEqualToAnchor:view.actionImageView.widthAnchor].active = YES;
    [activityContainerView.heightAnchor constraintEqualToAnchor:view.actionImageView.heightAnchor].active = YES;
    
    view.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    view.activityIndicatorView.userInteractionEnabled = NO;
    view.activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [view.activityIndicatorView hidesWhenStopped];
    [view.activityIndicatorView stopAnimating];
    [activityContainerView addSubview:view.activityIndicatorView];
    [view.activityIndicatorView.centerXAnchor constraintEqualToAnchor:activityContainerView.centerXAnchor].active = YES;
    [view.activityIndicatorView.centerYAnchor constraintEqualToAnchor:activityContainerView.centerYAnchor].active = YES;
    
    view.nameLabel = [[UILabel alloc] init];
    view.nameLabel.tag = 2;
    view.nameLabel.userInteractionEnabled = NO;
    view.nameLabel.textAlignment = NSTextAlignmentCenter;
    view.nameLabel.font = [UIFont systemFontOfSize:11];
    view.nameLabel.numberOfLines = 2;
    [view.nameLabel setText:title];
    view.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:view.nameLabel];
    [view.nameLabel.topAnchor constraintEqualToAnchor:view.actionImageView.bottomAnchor].active = YES;
    [view.nameLabel.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:2].active = YES;
    [view.nameLabel.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-2].active = YES;

    if (detail && detail.length > 0) {
        [view.nameLabel.heightAnchor constraintEqualToAnchor:view.heightAnchor multiplier:0.35].active = YES;
        
        view.detailLabel = [[UILabel alloc] init];
        view.detailLabel.tag = 3;
        view.detailLabel.userInteractionEnabled = NO;
        view.detailLabel.textAlignment = NSTextAlignmentCenter;
        view.detailLabel.font = [UIFont systemFontOfSize:11];
        [view.detailLabel setText:detail];
        view.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [view addSubview:view.detailLabel];
        [view.detailLabel.topAnchor constraintEqualToAnchor:view.nameLabel.bottomAnchor].active = YES;
        [view.detailLabel.leadingAnchor constraintEqualToAnchor:view.leadingAnchor constant:2].active = YES;
        [view.detailLabel.trailingAnchor constraintEqualToAnchor:view.trailingAnchor constant:-2].active = YES;
        [view.detailLabel.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:-5].active = YES;
    } else {
        [view.nameLabel.bottomAnchor constraintEqualToAnchor:view.bottomAnchor constant:-5].active = YES;
    }
    
    [self addArrangedSubview:view];
}

- (void)setItemEnabled:(BOOL)enabled atIndex:(NSInteger)index {
    ADActionButton *button = [self.arrangedSubviews objectAtIndex:index];
    [button setEnabled:NO];
    button.actionImageView.alpha = enabled ? 1.0 : 0.5;
    button.nameLabel.alpha = enabled ? 1.0 : 0.5;
    button.detailLabel.alpha = enabled ? 1.0 : 0.5;
}

- (void)setTitle:(NSString *)title forItemAtIndex:(NSInteger)index {
    ADActionButton *button = [self.arrangedSubviews objectAtIndex:index];
    [button.nameLabel setText:title];
}

- (void)setDetail:(NSString *)detail forItemAtIndex:(NSInteger)index {
    ADActionButton *button = [self.arrangedSubviews objectAtIndex:index];
    [button.detailLabel setText:detail];
}

- (void)showLoadingIndicatorForItemAtIndex:(NSInteger)index {
    ADActionButton *button = [self.arrangedSubviews objectAtIndex:index];
    [button.actionImageView setHidden:YES];
    [button.activityIndicatorView startAnimating];
}

- (void)hideLoadingIndicatorForItemAtIndex:(NSInteger)index {
    ADActionButton *button = [self.arrangedSubviews objectAtIndex:index];
    [button.activityIndicatorView stopAnimating];
    [button.actionImageView setHidden:NO];
}

- (void)buttonTouchUpInside:(ADActionButton *)button {
    [self setSubviewsOfButton:button highlighted:NO];
    if (button.actionBlock) {
        [[UISelectionFeedbackGenerator new] selectionChanged];
        button.actionBlock();
    }
}

- (void)buttonTouchDown:(ADActionButton *)button {
    [self setSubviewsOfButton:button highlighted:YES];
}

- (void)touchUpOutside:(ADActionButton *)button {
    [self setSubviewsOfButton:button highlighted:NO];
}

- (void)buttonDragOutside:(id)button {
    [self setSubviewsOfButton:button highlighted:NO];
}

- (void)buttonDragInside:(id)button {
    [self setSubviewsOfButton:button highlighted:YES];
}

- (void)setSubviewsOfButton:(ADActionButton *)button highlighted:(BOOL)highlighted {
    button.actionImageView.alpha = highlighted ? 0.5 : 1.0;
    button.nameLabel.alpha = highlighted ? 0.5 : 1.0;
    button.detailLabel.alpha = highlighted ? 0.5 : 1.0;
}

@end


@implementation ADActionButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (@available(iOS 13.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            self.nameLabel.textColor = [UIColor blackColor];
            self.actionImageView.tintColor = [UIColor colorWithRed:0.235294 green:0.235294 blue:0.262745 alpha:0.70];
            self.detailLabel.textColor = [UIColor colorWithRed:0.235294 green:0.235294 blue:0.262745 alpha:0.5];
        } else {
            self.nameLabel.textColor = [UIColor whiteColor];
            self.actionImageView.tintColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.577 alpha:1.0];
            self.detailLabel.textColor = [UIColor lightGrayColor];
        }
    } else {
        self.nameLabel.textColor = [UIColor whiteColor];
        self.actionImageView.tintColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.577 alpha:1.0];
        self.detailLabel.textColor = [UIColor lightGrayColor];
    }
}

@end

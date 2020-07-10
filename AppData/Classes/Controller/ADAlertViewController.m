//
//  ADAlertViewController.m
//  AppData
//
//  Created by Fouad Raheb on 7/2/20.
//

#import "ADAlertViewController.h"

#define kTopMargin              18
#define kTitleLabelHeight       25

#define kDetailLabelHeight      25
#define kDetailLabelTopMargin   10

#define kTextFieldTopMarging    15
#define kTextFieldHeight        35

#define kBottomMargin           18

#define kButtonsViewHeight      56

@interface ADAlertViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIView *textfieldContainerView;

@property (nonatomic, strong) UIView *buttonsView;
@property (nonatomic, strong) UIView *buttonsTopSeparatorView;
@property (nonatomic, strong) UIStackView *buttonsStackView;

@property (nonatomic, assign) BOOL didChangeFrame;
@property (nonatomic, assign) CGRect currentFrame;

@end

@implementation ADAlertViewController

- (instancetype)init {
    if (self = [super init]) {

        ADDataPresentationConfiguration *config = [[ADDataPresentationConfiguration alloc] init];
        self.presentationManager = [[ADDataPresentationManager alloc] initWithConfiguration:config];
        
        self.transitioningDelegate = self.presentationManager;
        self.modalPresentationStyle = UIModalPresentationCustom;
        
        [self initializeViews];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.view.layer.cornerRadius = 15;
    self.view.clipsToBounds = YES;
//    self.view.layer.borderColor = [UIColor colorWithRed:0.329 green:0.329 blue:0.345 alpha:0.6].CGColor;
//    self.view.layer.borderWidth = 0.75f;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textfield becomeFirstResponder];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (CGFloat)requiredHeight {
    CGFloat height = kTopMargin + kTitleLabelHeight;
    height += kDetailLabelTopMargin + kDetailLabelHeight;
    if (!self.textfield.hidden) {
        height += kTextFieldHeight + kTextFieldTopMarging;
    }
    height += kButtonsViewHeight + kBottomMargin;
    return height;
}

- (void)initializeViews {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *contentView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:contentView];
    [self pinView:contentView toAnchorsOfView:self.view];
    
    self.containerView = [UIView new];
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView.contentView addSubview:self.containerView];
    [self pinView:self.containerView toAnchorsOfView:contentView.contentView];

    [self addSubviewsToContainer];
}

- (void)pinView:(UIView *)view toAnchorsOfView:(UIView *)superview {
    [view.topAnchor constraintEqualToAnchor:superview.topAnchor].active = YES;
    [view.bottomAnchor constraintEqualToAnchor:superview.bottomAnchor].active = YES;
    [view.leadingAnchor constraintEqualToAnchor:superview.leadingAnchor].active = YES;
    [view.trailingAnchor constraintEqualToAnchor:superview.trailingAnchor].active = YES;
}

- (void)addSubviewsToContainer {
    // Create Title View
    [self createTopView];
    
    // Create Buttons View
    [self createButtonsView];
}

- (void)createTopView {
    // Create Top View
    self.topView = [[UIView alloc] init];
    self.topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.topView];
    [self.topView.topAnchor constraintEqualToAnchor:self.containerView.topAnchor].active = YES;
    [self.topView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor].active = YES;
    [self.topView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor].active = YES;
    [self.topView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor].active = YES;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topView addSubview:self.titleLabel];
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.topView.topAnchor constant:kTopMargin].active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.topView.leadingAnchor].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.topView.trailingAnchor].active = YES;
    [self.titleLabel.heightAnchor constraintEqualToConstant:kTitleLabelHeight].active = YES;
    
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.textColor = [UIColor whiteColor];
    self.detailLabel.font = [UIFont systemFontOfSize:13];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topView addSubview:self.detailLabel];
    [self.detailLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:kDetailLabelTopMargin].active = YES;
    [self.detailLabel.leadingAnchor constraintEqualToAnchor:self.topView.leadingAnchor].active = YES;
    [self.detailLabel.trailingAnchor constraintEqualToAnchor:self.topView.trailingAnchor].active = YES;
    [self.detailLabel.heightAnchor constraintGreaterThanOrEqualToConstant:kDetailLabelHeight].active = YES;
    
    self.textfieldContainerView = [[UIView alloc] init];
    self.textfieldContainerView.layer.cornerRadius = 5;
    self.textfieldContainerView.clipsToBounds = YES;
    self.textfieldContainerView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    self.textfieldContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.topView addSubview:self.textfieldContainerView];
    [self.textfieldContainerView.topAnchor constraintEqualToAnchor:self.detailLabel.bottomAnchor constant:kTextFieldTopMarging].active = YES;
    [self.textfieldContainerView.leadingAnchor constraintEqualToAnchor:self.topView.leadingAnchor constant:20].active = YES;
    [self.textfieldContainerView.trailingAnchor constraintEqualToAnchor:self.topView.trailingAnchor constant:-20].active = YES;
    [self.textfieldContainerView.heightAnchor constraintEqualToConstant:kTextFieldHeight].active = YES;
    
    self.textfield = [[UITextField alloc] init];
    self.textfield.textColor = [UIColor whiteColor];
    self.textfield.returnKeyType = UIReturnKeyDone;
    self.textfield.delegate = self;
    self.textfield.hidden = YES;
    self.textfield.font = [UIFont systemFontOfSize:14];
    self.textfield.clearButtonMode = UITextFieldViewModeAlways;
    self.textfield.translatesAutoresizingMaskIntoConstraints = NO;
    [self.textfieldContainerView addSubview:self.textfield];
    [self.textfield.topAnchor constraintEqualToAnchor:self.textfieldContainerView.topAnchor].active = YES;
    [self.textfield.bottomAnchor constraintEqualToAnchor:self.textfieldContainerView.bottomAnchor].active = YES;
    [self.textfield.leadingAnchor constraintEqualToAnchor:self.textfieldContainerView.leadingAnchor constant:7].active = YES;
    [self.textfield.trailingAnchor constraintEqualToAnchor:self.textfieldContainerView.trailingAnchor constant:-7].active = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)createButtonsView {
    // Create buttons View
    self.buttonsView = [[UIView alloc] init];
    self.buttonsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.containerView addSubview:self.buttonsView];
    [self.buttonsView.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor].active = YES;
    [self.buttonsView.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor].active = YES;
    [self.buttonsView.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor].active = YES;
    [self.buttonsView.heightAnchor constraintEqualToConstant:kButtonsViewHeight].active = YES;
    
    self.buttonsTopSeparatorView = [self createSeparatorView];
    self.buttonsTopSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.buttonsView addSubview:self.buttonsTopSeparatorView];
    [self.buttonsTopSeparatorView.heightAnchor constraintEqualToConstant:0.5].active = YES;
    [self.buttonsTopSeparatorView.topAnchor constraintEqualToAnchor:self.buttonsView.topAnchor].active = YES;
    [self.buttonsTopSeparatorView.leadingAnchor constraintEqualToAnchor:self.buttonsView.leadingAnchor].active = YES;
    [self.buttonsTopSeparatorView.trailingAnchor constraintEqualToAnchor:self.buttonsView.trailingAnchor].active = YES;
}

- (void)setButtons:(NSArray<ADAlertButton *> *)buttons {
    _buttons = buttons;
    
    [self.buttonsStackView removeFromSuperview];
    self.buttonsStackView = nil;
    
    // Create Stack View
    self.buttonsStackView = [[UIStackView alloc] init];
    self.buttonsStackView.axis = UILayoutConstraintAxisHorizontal;
    self.buttonsStackView.distribution = UIStackViewDistributionFillEqually;
    self.buttonsStackView.alignment = UIStackViewAlignmentLeading;
    self.buttonsStackView.spacing = 0;
    self.buttonsStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.buttonsView addSubview:self.buttonsStackView];
    [self.buttonsStackView.topAnchor constraintEqualToAnchor:self.buttonsTopSeparatorView.bottomAnchor].active = YES;
    [self.buttonsStackView.bottomAnchor constraintEqualToAnchor:self.buttonsView.bottomAnchor].active = YES;
    [self.buttonsStackView.leadingAnchor constraintEqualToAnchor:self.buttonsView.leadingAnchor].active = YES;
    [self.buttonsStackView.trailingAnchor constraintEqualToAnchor:self.buttonsView.trailingAnchor].active = YES;
    
    // Add Buttons to Stack View
    for (int i = 0; i < buttons.count; i++) {
        ADAlertButton *adButton = [buttons objectAtIndex:i];
        UIButton *button = [self buttonWithADButton:adButton tag:i];
        button.translatesAutoresizingMaskIntoConstraints = NO;
        [self.buttonsStackView addArrangedSubview:button];
        [button.heightAnchor constraintEqualToAnchor:self.buttonsStackView.heightAnchor].active = YES;
        if (i != buttons.count - 1) {
            // add separator
            UIView *buttonSeparator = [self createSeparatorView];
            buttonSeparator.translatesAutoresizingMaskIntoConstraints = NO;
            [button addSubview:buttonSeparator];
            [buttonSeparator.topAnchor constraintEqualToAnchor:button.topAnchor].active = YES;
            [buttonSeparator.bottomAnchor constraintEqualToAnchor:button.bottomAnchor].active = YES;
            [buttonSeparator.trailingAnchor constraintEqualToAnchor:button.trailingAnchor constant:0.33].active = YES;
            [buttonSeparator.widthAnchor constraintEqualToConstant:0.5].active = YES;
        }
    }
}

- (UIButton *)buttonWithADButton:(ADAlertButton *)adButton tag:(NSInteger)tag {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setBackgroundColor:[UIColor clearColor]];
    [button setTitle:adButton.title forState:UIControlStateNormal];
    if (adButton.style == ADButtonStyleDestructive) {
        // [button setTitleColor:[UIColor colorWithRed:255/255.f green:107/255.f blue:107/255.f alpha:1.0f] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    } else {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
    [button setTag:tag];
    return button;
}

- (void)didTapButton:(UIButton *)button {
    ADAlertButton *adButton = [self.buttons objectAtIndex:button.tag];
    if (adButton.actionHandler) {
        adButton.actionHandler(button);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIView *)createSeparatorView {
    UIView *separatorView = [UIView new];
    separatorView.backgroundColor = [UIColor colorWithRed:0.329 green:0.329 blue:0.345 alpha:0.6];
    return separatorView;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSValue *sizeValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    if (!sizeValue) return;
    CGRect keyboardFrame = [sizeValue CGRectValue];
  
    self.currentFrame = self.view.frame;
    CGRect frame = self.view.frame;
    
    CGFloat originYDiff = (frame.origin.y + frame.size.height) - keyboardFrame.origin.y + 15;
    if (originYDiff > 0) {
        self.didChangeFrame = YES;
        frame.origin.y = frame.origin.y - originYDiff;
        self.view.frame = frame;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (self.didChangeFrame) {
        self.view.frame = self.currentFrame;
        self.didChangeFrame = NO;
    }
}

- (void)setTitleText:(NSString *)titleText {
    _titleText = titleText;
    self.titleLabel.text = titleText;
}

- (void)setDetailText:(NSString *)detailText {
    _detailText = detailText;
    self.detailLabel.text = detailText;
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler {
    self.textfield.hidden = NO;
    if (configurationHandler) {
        configurationHandler(self.textfield);
    }
}

@end

@implementation ADAlertButton

+ (ADAlertButton *)buttonWithTitle:(NSString *)title style:(ADAlertButtonStyle)style handler:(ADAlertButtonActionHandler)handler  {
    ADAlertButton *button = [[self alloc] init];
    button.title = title;
    button.style = style;
    button.actionHandler = handler;
    return button;
}

@end

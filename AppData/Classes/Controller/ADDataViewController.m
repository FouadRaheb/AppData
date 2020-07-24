//
//  ADDataViewController.m
//  AppData
//
//  Created by Fouad Raheb on 6/29/20.
//

#import "ADDataViewController.h"
#import "ADDataPresentationManager.h"
#import "ADExpandableSectionHeaderView.h"
#import "ADTitleSectionHeaderView.h"
#import "ADMainDataSource.h"
#import "ADMoreDataSource.h"
#import <objc/runtime.h>

@interface ADDataViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) ADDataPresentationManager *presentationManager;

@property (nonatomic, strong) UIVisualEffectView *contentView;

@property (nonatomic, strong) ADAppData *appData;

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIButton *nameLabel;
@property (nonatomic, strong) UIButton *nameEditButton;
@property (nonatomic, strong) UIButton *identifierLabel;
@property (nonatomic, strong) UIButton *identifierCopyButton;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UIButton *appStoreButton;

@property (nonatomic, strong) ADMainDataSource *mainDataSource;
@property (nonatomic, strong) ADMoreDataSource *moreDataSource;

@property (nonatomic, assign) BOOL isCopyingIdentifier;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *screenEdgeGesture;

@end

@implementation ADDataViewController

- (instancetype)initWithAppData:(ADAppData *)data {
    if (self = [super init]) {
        ADDataPresentationConfiguration *config = [[ADDataPresentationConfiguration alloc] init];
        
        self.presentationManager = [[ADDataPresentationManager alloc] initWithConfiguration:config];
        
        self.transitioningDelegate = self.presentationManager;
        self.modalPresentationStyle = UIModalPresentationCustom;
        
        self.appData = data;

        self.mainDataSource = [[ADMainDataSource alloc] initWithAppData:self.appData dataViewController:self];
        self.moreDataSource = [[ADMoreDataSource alloc] initWithAppData:self.appData dataViewController:self];
        
        [self initializeViews];
        
        [self configureViewWithAppData];
    }
    return self;
}

// Used from Force Touch Menu

+ (void)presentControllerFromSBIconView:(SBIconView *)iconView fromContextMenu:(BOOL)contextMenu {
    if (!iconView) {
        [self showAlertWitle:@"AppData" message:[NSString stringWithFormat:@"Could not fetch app data.\n\nError: Empty icon view."]];
        return;
    }
    
    // Find Icon Image View
    SBIconImageView *_iconImageView = nil;
    if ([iconView respondsToSelector:@selector(_iconImageView)]) {
        _iconImageView = [iconView _iconImageView];
    } else {
        _iconImageView = object_getIvar(iconView, class_getInstanceVariable(object_getClass(iconView), [@"_iconImageView" UTF8String]));
    }
    if (!_iconImageView) {
        for (UIView *subview in iconView.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"SBIconImageView")]) {
                _iconImageView = (SBIconImageView *)subview;
                break;
            }
        }
    }
    
    if (!_iconImageView) {
        [self showAlertWitle:@"AppData" message:[NSString stringWithFormat:@"Could not fetch app data.\n\nError: could not find icon image view."]];
        return;
    }
    [self presentControllerFromSBIconImageView:_iconImageView iconView:iconView fromContextMenu:contextMenu];
}

// Used from Swipe Up

+ (void)presentControllerFromSBIconImageView:(SBIconImageView *)iconImageView fromContextMenu:(BOOL)contextMenu {
    SBIconView *iconView = (SBIconView *)[iconImageView superview];
    if (![iconView respondsToSelector:@selector(icon)]) {
        NSLog(@"iconView: %@",iconView);
        iconView = (SBIconView *)[iconView superview];
    }
    [self presentControllerFromSBIconImageView:iconImageView iconView:iconView fromContextMenu:contextMenu];
}

// Internal

+ (void)presentControllerFromSBIconImageView:(SBIconImageView *)iconImageView iconView:(SBIconView *)iconView fromContextMenu:(BOOL)contextMenu {
    NSLog(@"iconImageView: %@",iconImageView);
    
    UIViewController *rootController = [iconImageView _viewControllerForAncestor];
    NSLog(@"rootController: %@",rootController);
    
    if ([iconView respondsToSelector:@selector(icon)] && [iconView.icon respondsToSelector:@selector(applicationBundleID)] && [iconImageView respondsToSelector:@selector(contentsImage)]) {
        SBIcon *icon = iconView.icon;
        NSString *bundleID = icon.applicationBundleID;
        ADAppData *appData = [ADAppData appDataForBundleIdentifier:bundleID iconImage:iconImageView.contentsImage];
        if (appData) {
            appData.iconView = iconView;
            
            [[UISelectionFeedbackGenerator new] selectionChanged];
            
            ADDataViewController *dataViewController = [[ADDataViewController alloc] initWithAppData:appData];
            if (IS_IPAD) {
                dataViewController.contentView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
                dataViewController.presentationManager.configuration.fadeAnimationAlpha = 0;
                dataViewController.presentationManager.configuration.fadeAnimation = YES;
                dataViewController.presentationManager.configuration.customFrameHandler = ^CGRect(UIView *containerView) {
                    CGSize size = CGSizeMake(containerView.frame.size.width * 0.5, containerView.frame.size.height * 0.5);
                    return CGRectMake(containerView.frame.size.width/2 - size.width/2,
                                      containerView.frame.size.height/2 - size.height/2,
                                      size.width, size.height);
                };
                if (contextMenu) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.4 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [rootController presentViewController:dataViewController animated:YES completion:nil];
                    });
                } else {
                    [rootController presentViewController:dataViewController animated:YES completion:nil];
                }
            } else {
                [rootController presentViewController:dataViewController animated:YES completion:nil];
            }
        }
    } else {
        [self showAlertFromViewController:rootController title:@"AppData" message:[NSString stringWithFormat:@"Could not fetch app data.\n\n%@ is not a valid icon class.",[iconView class]]];
    }
}

+ (void)showAlertWitle:(NSString *)title message:(NSString *)message {
    [self showAlertFromViewController:nil title:title message:message];
}

+ (void)showAlertFromViewController:(UIViewController *)viewController title:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleCancel handler:nil]];
    [viewController?:[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
    
    UISwipeGestureRecognizer *swipeUpDownGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    swipeUpDownGesture.delegate = self;
    [swipeUpDownGesture setDirection:UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:swipeUpDownGesture];
    
    self.screenEdgeGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgeSwiped:)];
    if (self.view.semanticContentAttribute == UISemanticContentAttributeForceRightToLeft) {
        self.screenEdgeGesture.edges = UIRectEdgeRight;
    } else {
        self.screenEdgeGesture.edges = UIRectEdgeLeft;
    }
}

- (void)screenEdgeSwiped:(UIScreenEdgePanGestureRecognizer *)screenGesture {
    [self switchTableViews];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:NSClassFromString(@"UITableViewCellContentView")]) {
        return NO;
    }
    return YES;
}

- (void)configureViewWithAppData {
    self.iconImageView.image = self.appData.iconImage;
    self.appStoreButton.hidden = ![self.appData hasAppStoreApp];
    
    if ([self.appData isApplication]) {
        NSString *customIconName = self.appData.customIconName;
        [self.nameLabel setTitle:customIconName?:self.appData.name forState:UIControlStateNormal];
        [self.identifierLabel setTitle:self.appData.bundleIdentifier forState:UIControlStateNormal];
        if (self.appData.diskUsage > 0 && self.appData.diskUsageString) {
            self.versionLabel.text = [self.appData.version stringByAppendingFormat:@"  —  %@",self.appData.diskUsageString];
        } else {
            self.versionLabel.text = self.appData.version;
        }
    } else {
        [self.nameLabel setTitle:@"Not an Application" forState:UIControlStateNormal];
        [self.nameLabel setEnabled:NO];
        
        [self.identifierLabel setTitle:@"No Bundle Identifier" forState:UIControlStateNormal];
        [self.identifierLabel setEnabled:NO];
        
        [self.versionLabel setText:@"—"];
        
        self.identifierCopyButton.hidden = YES;
        self.nameEditButton.hidden = YES;
    }
}

- (void)initializeViews {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]; // UIBlurEffectStyleRegular - Auto
    self.contentView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = 15;
    self.contentView.layer.maskedCorners = kCALayerMaxXMinYCorner | kCALayerMinXMinYCorner;
    [self.view addSubview:self.contentView];
    [self pinView:self.contentView toAnchorsOfView:self.view];
    
    UIView *containerView = [UIView new];
    containerView.backgroundColor = [UIColor clearColor];
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView.contentView addSubview:containerView];
    [self pinView:containerView toAnchorsOfView:self.contentView.contentView];

    [self addSubviewsToContainer:containerView];
}

- (void)addSubviewsToContainer:(UIView *)containerView {
    
    UIColor *secondaryLabelsColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.961 alpha:0.6];
    UIColor *buttonsSymbolColor = secondaryLabelsColor; //[UIColor colorWithRed:127/255.f green:140/255.f blue:141/255.f alpha:0.6];
    
    self.appStoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.appStoreButton setImage:[[ADHelper imageNamed:@"AppStoreButton"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.appStoreButton setTintColor:buttonsSymbolColor];
    [self.appStoreButton addTarget:self action:@selector(didTapAppStoreButton:) forControlEvents:UIControlEventTouchUpInside];
    self.appStoreButton.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:self.appStoreButton];
    [self.appStoreButton.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:9].active = YES;
    [self.appStoreButton.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-9].active = YES;
    [self.appStoreButton setContentEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    [self.appStoreButton.heightAnchor constraintEqualToConstant:30].active = YES;
    [self.appStoreButton.widthAnchor constraintEqualToConstant:30].active = YES;
    
    self.iconImageView = [[UIImageView alloc] init];
    [self.iconImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [containerView addSubview:self.iconImageView];
    [self.iconImageView.leadingAnchor constraintEqualToAnchor:containerView.leadingAnchor constant:15].active = YES;
    [self.iconImageView.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:15].active = YES;
    [self.iconImageView.widthAnchor constraintEqualToConstant:58].active = YES;
    [self.iconImageView.heightAnchor constraintEqualToConstant:58].active = YES;
    
    self.nameLabel = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.nameLabel addTarget:self action:@selector(didTapNameButton:) forControlEvents:UIControlEventTouchUpInside];
    self.nameLabel.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.nameLabel.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.nameLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.nameLabel setTitle:@"-" forState:UIControlStateNormal];
    self.nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:self.nameLabel];
    [self.nameLabel.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:15].active = YES;
    [self.nameLabel.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor constant:11].active = YES;
    [self.nameLabel.heightAnchor constraintEqualToConstant:22].active = YES;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightBold];
        UIImage *image = [[UIImage systemImageNamed:@"square.and.pencil" withConfiguration:config] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.nameEditButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.nameEditButton setImage:image forState:UIControlStateNormal];
        [self.nameEditButton setTintColor:buttonsSymbolColor];
        [self.nameEditButton addTarget:self action:@selector(didTapNameButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.nameEditButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [containerView addSubview:self.nameEditButton];
        [self.nameEditButton setContentEdgeInsets:UIEdgeInsetsMake(4.75, 4.75, 4.75, 4.75)];
        [self.nameEditButton.heightAnchor constraintEqualToConstant:22].active = YES;
        [self.nameEditButton.widthAnchor constraintEqualToConstant:22].active = YES;
        [self.nameEditButton.centerYAnchor constraintEqualToAnchor:self.nameLabel.centerYAnchor].active = YES;
        [self.nameEditButton.leadingAnchor constraintEqualToAnchor:self.nameLabel.trailingAnchor constant:2].active = YES;
        
        [self.nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.appStoreButton.leadingAnchor constant:- (22 + 11)].active = YES;
    } else {
        [self.nameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.appStoreButton.trailingAnchor constant:- 11].active = YES;
    }
    
    self.identifierLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.identifierLabel addTarget:self action:@selector(didTapIdentifierButton:) forControlEvents:UIControlEventTouchUpInside];
    self.identifierLabel.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.identifierLabel setTitleColor:secondaryLabelsColor forState:UIControlStateNormal];
    [self.identifierLabel setTitle:@"-" forState:UIControlStateNormal];
    self.identifierLabel.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.identifierLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:self.identifierLabel];
    [self.identifierLabel.topAnchor constraintEqualToAnchor:self.nameLabel.bottomAnchor constant:2].active = YES;
    [self.identifierLabel.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor constant:11].active = YES;
    [self.identifierLabel.heightAnchor constraintEqualToConstant:20.16].active = YES;
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightBold];
        UIImage *image = [[UIImage systemImageNamed:@"doc.on.clipboard" withConfiguration:config] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.identifierCopyButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.identifierCopyButton setImage:image forState:UIControlStateNormal];
        [self.identifierCopyButton setTintColor:buttonsSymbolColor];
        [self.identifierCopyButton addTarget:self action:@selector(didTapIdentifierButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.identifierCopyButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [containerView addSubview:self.identifierCopyButton];
        [self.identifierCopyButton setContentEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        [self.identifierCopyButton.heightAnchor constraintEqualToConstant:22].active = YES;
        [self.identifierCopyButton.widthAnchor constraintEqualToConstant:22].active = YES;
        [self.identifierCopyButton.centerYAnchor constraintEqualToAnchor:self.identifierLabel.centerYAnchor].active = YES;
        [self.identifierCopyButton.leadingAnchor constraintEqualToAnchor:self.identifierLabel.trailingAnchor constant:1].active = YES;
        
        [self.identifierLabel.trailingAnchor constraintLessThanOrEqualToAnchor:containerView.trailingAnchor constant:- (22 + 11)].active = YES;
    } else {
        [self.identifierLabel.trailingAnchor constraintLessThanOrEqualToAnchor:containerView.trailingAnchor constant:- 11].active = YES;
    }
    
    self.versionLabel = [[UILabel alloc] init];
    self.versionLabel.font = [UIFont systemFontOfSize:13];
    self.versionLabel.textColor = secondaryLabelsColor;
    self.versionLabel.text = @"-";
    self.versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:self.versionLabel];
    [self.versionLabel.topAnchor constraintEqualToAnchor:self.identifierLabel.bottomAnchor].active = YES;
    [self.versionLabel.leadingAnchor constraintEqualToAnchor:self.iconImageView.trailingAnchor constant:11].active = YES;
    [self.versionLabel.trailingAnchor constraintEqualToAnchor:containerView.trailingAnchor constant:-11].active = YES;
    [self.versionLabel.heightAnchor constraintEqualToConstant:20.16].active = YES;
    
    // Create Table View
    self.tableView = [self createTableViewWithDataSource:self.mainDataSource];
    [containerView addSubview:self.tableView];
    
    self.moreTableView = [self createTableViewWithDataSource:self.moreDataSource];
    [self.moreTableView registerClass:ADExpandableSectionHeaderView.class forHeaderFooterViewReuseIdentifier:ADExpandableSectionHeaderView.reuseIdentifier];
    [self.moreTableView registerClass:ADTitleSectionHeaderView.class forHeaderFooterViewReuseIdentifier:ADTitleSectionHeaderView.reuseIdentifier];
    self.moreTableView.hidden = YES;
    [containerView addSubview:self.moreTableView];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutTableViews];
}

- (UITableView *)createTableViewWithDataSource:(id)dataSource {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    tableView.separatorColor = [UIColor colorWithRed:0.329 green:0.329 blue:0.345 alpha:0.6];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = dataSource;
    tableView.dataSource = dataSource;
    return tableView;
}

- (void)layoutTableViews {
    CGFloat y = self.iconImageView.frame.origin.y + self.iconImageView.frame.size.height + 15;
    CGRect frame = CGRectMake(0, y, self.tableView.superview.frame.size.width, self.tableView.superview.frame.size.height - y);
    self.tableView.frame = frame;
    self.moreTableView.frame = frame;
}

- (void)pinView:(UIView *)view toAnchorsOfView:(UIView *)superview {
    [view.topAnchor constraintEqualToAnchor:superview.topAnchor].active = YES;
    [view.bottomAnchor constraintEqualToAnchor:superview.bottomAnchor].active = YES;
    [view.leadingAnchor constraintEqualToAnchor:superview.leadingAnchor].active = YES;
    [view.trailingAnchor constraintEqualToAnchor:superview.trailingAnchor].active = YES;
}

- (void)didTapNameButton:(UIButton *)button {
    [[UISelectionFeedbackGenerator new] selectionChanged];
    [self showCustomIconNameInterface];
}

- (void)didTapIdentifierButton:(UIButton *)button {
    if (!self.isCopyingIdentifier) {
        self.isCopyingIdentifier = YES;
        
        NSString *currentTitle = self.identifierLabel.titleLabel.text;
        [[UIPasteboard generalPasteboard] setString:currentTitle?:@""];
        
        [self.identifierLabel setTitle:@"Copied to clipboard" forState:UIControlStateNormal];
        
        [[UINotificationFeedbackGenerator new] notificationOccurred:UINotificationFeedbackTypeSuccess];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.7 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.identifierLabel setTitle:currentTitle forState:UIControlStateNormal];
            self.isCopyingIdentifier = NO;
        });
    }
}

- (void)didTapAppStoreButton:(UIButton *)button {
    if (IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self.appData openInAppStore];
        }];
    } else {
        [self.appData openInAppStore];
    }
}

- (void)showCustomIconNameInterface {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Rename" message:@"Enter an app icon name" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self presentFloatingDockIfNeeded];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.appData setCustomIconName:alertController.textFields.firstObject.text];
        [self.nameLabel setTitle:self.appData.name forState:UIControlStateNormal];
        [self presentFloatingDockIfNeeded];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.appData setCustomIconName:nil];
        [self.nameLabel setTitle:self.appData.name forState:UIControlStateNormal];
        [self presentFloatingDockIfNeeded];
    }]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.placeholder = @"Icon Name";
        textField.text = self.nameLabel.titleLabel.text;
    }];
    
    if (IS_IPAD) {
        SBIconController *iconController = [NSClassFromString(@"SBIconController") sharedInstance];
        SBFloatingDockController *dockController = [iconController floatingDockController];
        [dockController _dismissFloatingDockIfPresentedAnimated:YES completionHandler:^{
            [self presentViewController:alertController animated:YES completion:nil];
        }];
    } else {
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)presentFloatingDockIfNeeded {
    if (IS_IPAD) {
        SBIconController *iconController = [NSClassFromString(@"SBIconController") sharedInstance];
        SBFloatingDockController *dockController = [iconController floatingDockController];
        if (![dockController isFloatingDockPresented]) {
            [dockController _presentFloatingDockIfDismissedAnimated:YES completionHandler:^{ }];
        }
    }
}

- (void)switchTableViews {
    UITableView *activeTableView = self.tableView.hidden ? self.moreTableView : self.tableView;
    UITableView *inactiveTableView = self.tableView.hidden ? self.tableView : self.moreTableView;
    
    BOOL isPresenting = [activeTableView isEqual:self.tableView];
    
    CGRect activeInitialFrame = activeTableView.frame;
    CGRect activeEndFrame = CGRectMake(0 - activeTableView.frame.size.width, activeTableView.frame.origin.y, activeTableView.frame.size.width, activeTableView.frame.size.height);
    
    CGRect inactiveInitialFrame = CGRectMake(activeTableView.frame.size.width, activeTableView.frame.origin.y, activeTableView.frame.size.width, activeTableView.frame.size.height);
    CGRect inactiveEndFrame = activeTableView.frame;
    
    if (isPresenting) {
        [self.view addGestureRecognizer:self.screenEdgeGesture];
    } else {
        [self.view removeGestureRecognizer:self.screenEdgeGesture];
        CGRect tmp = activeEndFrame;
        activeEndFrame = inactiveInitialFrame;
        inactiveInitialFrame = tmp;
    }
    
    activeTableView.frame = activeInitialFrame;
    inactiveTableView.frame = inactiveInitialFrame;

    activeTableView.hidden = NO;
    inactiveTableView.hidden = NO;
    
    activeTableView.alpha = 1.0;
    inactiveTableView.alpha = 0.0;
    
    [UIView animateWithDuration:0.25 animations:^{
        activeTableView.frame = activeEndFrame;
        inactiveTableView.frame = inactiveEndFrame;
        
        activeTableView.alpha = 0.0;
        inactiveTableView.alpha = 1.0;
    } completion:^(BOOL finished) {
        activeTableView.hidden = YES;
    }];
}

@end

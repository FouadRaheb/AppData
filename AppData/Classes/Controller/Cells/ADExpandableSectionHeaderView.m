//
//  ADExpandableSectionHeaderView.m
//  AppData
//
//  Created by Fouad Raheb on 7/19/20.
//

#import "ADExpandableSectionHeaderView.h"

@interface ADExpandableSectionHeaderView ()
@property (nonatomic, strong) UIImageView *chevronImageView;

@property (nonatomic, strong) UIImage *chevronUp;
@property (nonatomic, strong) UIImage *chevronDown;
@end

@implementation ADExpandableSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

+ (NSString *)reuseIdentifier {
    return @"ADExpandableSectionHeaderViewIdentifier";
}

+ (CGFloat)headerHeight {
    return 30;
}

- (void)initialize {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapHeaderView:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:gestureRecognizer];
    
    self.chevronDown = [[ADHelper imageNamed:@"ChevronDown"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.chevronUp = [[ADHelper imageNamed:@"ChevronUp"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.chevronImageView = [[UIImageView alloc] initWithImage:self.chevronDown];
    [self addSubview:self.chevronImageView];
    self.chevronImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.chevronImageView.widthAnchor constraintEqualToConstant:19].active = YES;
    [self.chevronImageView.heightAnchor constraintEqualToConstant:10].active = YES;
    [self.chevronImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    [self.chevronImageView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-15].active = YES;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:self.titleLabel];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15].active = YES;
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
    [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.chevronImageView.leadingAnchor].active = YES;
}

- (void)didTapHeaderView:(UITapGestureRecognizer *)gesture {
    self.isExpanded = !self.isExpanded;
    [self.delegate expandableSectionHeaderViewDidChange:self];
}

- (void)setIsExpanded:(BOOL)isExpanded {
    _isExpanded = isExpanded;
    self.chevronImageView.image = isExpanded ? self.chevronUp : self.chevronDown;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 13.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            self.titleLabel.textColor = [UIColor colorWithRed:0.427 green:0.427 blue:0.427 alpha:1.0];
        } else {
            self.titleLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.577 alpha:1.0];
        }
    } else {
        self.titleLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.577 alpha:1.0];
    }
    self.chevronImageView.tintColor = self.titleLabel.textColor;
}

@end

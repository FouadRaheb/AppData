//
//  ADExpandableSectionHeaderView.m
//  AppData
//
//  Created by Fouad Raheb on 7/19/20.
//

#import "ADTitleSectionHeaderView.h"

@interface ADTitleSectionHeaderView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *backImageView;

@property (nonatomic, strong) NSLayoutConstraint *titleLabelHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *titleLabelTopConstraint;
@end

@implementation ADTitleSectionHeaderView

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
    return @"ADTitleSectionHeaderViewIdentifier";
}

- (void)initialize {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapHeaderView:)];
    gestureRecognizer.numberOfTapsRequired = 1;
    [self addGestureRecognizer:gestureRecognizer];
    
    UIImage *landscapeImage = [ADHelper imageNamed:@"ChevronDown"];
    UIImage *portraitImage = [[UIImage alloc] initWithCGImage:landscapeImage.CGImage scale:1.0 orientation: UIImageOrientationRight];
    UIImage *image = [[self makeThumbnailOfSize:CGSizeMake(10, 18) ofImage:portraitImage] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.backImageView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:self.backImageView];
    self.backImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15].active = YES;
    [self.backImageView.heightAnchor constraintEqualToConstant:image.size.height].active = YES;
    [self.backImageView.widthAnchor constraintEqualToConstant:image.size.width].active = YES;
    [self.backImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];

    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabelTopConstraint = [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:1.33];
    self.titleLabelTopConstraint.active = YES;
    self.titleLabelHeightConstraint = [self.titleLabel.heightAnchor constraintEqualToConstant:18];
    self.titleLabelHeightConstraint.active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16].active = YES;
}

- (UIImage *)makeThumbnailOfSize:(CGSize)size ofImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newThumbnail;
}

- (void)didTapHeaderView:(UITapGestureRecognizer *)gesture {
    if (self.delegate) {
        [self.delegate titleSectionHeaderViewDidTapBackButton];
    }
}

- (void)configureHeaderWithTitle:(NSString *)title {
    self.backImageView.hidden = YES;
    self.titleLabel.text = title;
    self.titleLabel.textAlignment = NSTextAlignmentNatural;
    self.titleLabelTopConstraint.constant = 1.33;
    self.titleLabelHeightConstraint.constant = 18;
}

- (void)configureBackHeaderWithTitle:(NSString *)title {
    self.backImageView.hidden = NO;
    self.titleLabel.text = title;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabelTopConstraint.constant = 0;
    self.titleLabelHeightConstraint.constant = 35;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.titleLabel.textColor = [ADAppearance.sharedInstance tableHeaderTextColor];
    self.backImageView.tintColor = self.titleLabel.textColor;
}

@end

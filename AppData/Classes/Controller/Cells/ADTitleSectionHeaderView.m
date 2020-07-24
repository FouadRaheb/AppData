//
//  ADExpandableSectionHeaderView.m
//  AppData
//
//  Created by Fouad Raheb on 7/19/20.
//

#import "ADTitleSectionHeaderView.h"

@interface ADTitleSectionHeaderView ()
@property (nonatomic, strong) UIImageView *backImageView;
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
    self.backImageView.tintColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.577 alpha:1.0];
    [self addSubview:self.backImageView];
    self.backImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15].active = YES;
    [self.backImageView.heightAnchor constraintEqualToConstant:image.size.height].active = YES;
    [self.backImageView.widthAnchor constraintEqualToConstant:image.size.width].active = YES;
    [self.backImageView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.557 alpha:1.0];
    self.titleLabel.text = @"MORE INFO";
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.titleLabel];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor].active = YES;
    [self.titleLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active = YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active = YES;
}

- (UIImage *)makeThumbnailOfSize:(CGSize)size ofImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newThumbnail;
}

- (void)didTapHeaderView:(UITapGestureRecognizer *)gesture {
    [self.delegate titleSectionHeaderViewDidTapBackButton];
}

@end

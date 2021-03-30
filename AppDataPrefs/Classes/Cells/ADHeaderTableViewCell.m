//
//  ADHeaderTableViewCell.h
//  AppDataPrefs
//
//  Created by Fouad Raheb on 3/29/21.
//

#import "ADHeaderTableViewCell.h"

@implementation ADHeaderTableViewCell

+ (NSString *)reuseIdentifier {
    return @"ADHeaderTableViewCellIdentifier";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.separatorInset = UIEdgeInsetsMake(0, CGFLOAT_MAX, 0, 0);
    self.backgroundColor = [UIColor clearColor];
    
    // Title Label
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:28];
    [self.contentView addSubview:self.titleLabel];
    
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:15].active =  YES;
    [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor].active =  YES;
    [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor].active =  YES;
    [self.titleLabel.heightAnchor constraintEqualToConstant:30].active = YES;
    
    // Detail Label
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.textAlignment = NSTextAlignmentCenter;
    self.detailLabel.font = [UIFont systemFontOfSize:15];
    if (@available(iOS 13.0, *)) {
        self.detailLabel.textColor = [UIColor secondaryLabelColor];
    } else {
        self.detailLabel.textColor = [UIColor grayColor];
    }
    [self.contentView addSubview:self.detailLabel];
    
    self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.detailLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:5].active =  YES;
    [self.detailLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15].active =  YES;
    [self.detailLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15].active =  YES;
    [self.detailLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-15].active = YES;
    [self.detailLabel.heightAnchor constraintGreaterThanOrEqualToConstant:20].active = YES;
}

- (void)addSubview:(UIView *)view {
    // The separator has a height of 0.5pt on a retina display and 1pt on non-retina.
    // Prevent subviews with this height from being added.
    if (CGRectGetHeight(view.frame) * [UIScreen mainScreen].scale == 1) {
        return;
    }
    [super addSubview:view];
}

@end

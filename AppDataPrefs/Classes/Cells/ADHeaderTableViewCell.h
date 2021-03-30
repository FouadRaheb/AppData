//
//  ADHeaderTableViewCell.h
//  AppDataPrefs
//
//  Created by Fouad Raheb on 3/29/21.
//

#import <UIKit/UIKit.h>

@interface ADHeaderTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;

+ (NSString *)reuseIdentifier;

@end

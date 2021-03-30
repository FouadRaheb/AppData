//
//  ADSwitchTableViewCell.h
//  AppDataPrefs
//
//  Created by Fouad Raheb on 3/29/21.
//

#import <UIKit/UIKit.h>

@interface ADSwitchTableViewCell : UITableViewCell

+ (NSString *)reuseIdentifier;
+ (CGFloat)height;

- (void)configureWithTitle:(NSString *)title switchKey:(NSString *)key;

@end

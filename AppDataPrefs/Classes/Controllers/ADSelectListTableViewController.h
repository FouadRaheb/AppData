//
//  ADSelectListTableViewController.m
//  AppDataPrefs
//
//  Created by Fouad Raheb on 3/29/21.
//

#import <UIKit/UIKit.h>

typedef void (^ADListItemChange)(NSString *value);

@interface ADSelectListTableViewController : UITableViewController

@property (nonatomic, strong) NSString *footerText;

- (instancetype)initWithStyle:(UITableViewStyle)style title:(NSString *)title items:(NSArray *)items values:(NSArray *)values currentValue:(NSString *)value popViewOnSelect:(BOOL)back changeBlock:(ADListItemChange)block;

@end

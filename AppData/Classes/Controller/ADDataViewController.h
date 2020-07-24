//
//  ADDataViewController.h
//  AppData
//
//  Created by Fouad Raheb on 6/29/20.
//

#import <UIKit/UIKit.h>
#import "ADAppData.h"

@interface ADDataViewController : UIViewController

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *moreTableView;

- (instancetype)initWithAppData:(ADAppData *)data;

+ (void)presentControllerFromSBIconView:(SBIconView *)iconView fromContextMenu:(BOOL)contextMenu;
+ (void)presentControllerFromSBIconImageView:(SBIconImageView *)iconImageView fromContextMenu:(BOOL)contextMenu;

- (void)switchTableViews;

@end

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

@property (nonatomic, assign) BOOL dockDismissed;

- (instancetype)initWithAppData:(ADAppData *)data;

+ (void)presentControllerFromSBIconView:(SBIconView *)iconView fromContextMenu:(BOOL)contextMenu;
+ (void)presentControllerFromSBIconImageView:(SBIconImageView *)iconImageView fromContextMenu:(BOOL)contextMenu;

- (void)switchTableViews;

- (void)dismiss;

+ (BOOL)dismissFloatingDockIfNeededWithCompletion:(void(^)())completion;
+ (void)presentFloatingDockIfNeeded;

@end

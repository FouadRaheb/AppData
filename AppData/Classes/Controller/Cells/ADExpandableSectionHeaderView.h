//
//  ADExpandableSectionHeaderView.h
//  AppData
//
//  Created by Fouad Raheb on 7/19/20.
//

#import <UIKit/UIKit.h>

@class ADExpandableSectionHeaderView;

@protocol ADExpandableSectionHeaderViewDelegate <NSObject>

@required
- (void)expandableSectionHeaderViewDidChange:(ADExpandableSectionHeaderView *)headerView;

@end

@interface ADExpandableSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) BOOL isExpanded;

@property (nonatomic, assign) NSInteger section;

@property (nonatomic) __weak id <ADExpandableSectionHeaderViewDelegate> delegate;

+ (NSString *)reuseIdentifier;
+ (CGFloat)headerHeight;

@end

//
//  ADTitleSectionHeaderView.h
//  AppData
//
//  Created by Fouad Raheb on 7/19/20.
//

#import <UIKit/UIKit.h>

@protocol ADTitleSectionHeaderViewDelegate <NSObject>

@required
- (void)titleSectionHeaderViewDidTapBackButton;

@end

@interface ADTitleSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic) __weak id <ADTitleSectionHeaderViewDelegate> delegate;

+ (NSString *)reuseIdentifier;

- (void)configureBackHeaderWithTitle:(NSString *)title;
- (void)configureHeaderWithTitle:(NSString *)title;

@end

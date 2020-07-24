//
//  ADMoreDataSource.h
//  AppData
//
//  Created by Fouad Raheb on 7/15/20.
//

#import <Foundation/Foundation.h>
#import "ADExpandableSectionHeaderView.h"
#import "ADTitleSectionHeaderView.h"

@class ADDataViewController;
@class ADAppData;

@interface ADMoreDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, ADExpandableSectionHeaderViewDelegate, ADTitleSectionHeaderViewDelegate>

@property (nonatomic, strong) ADAppData *appData;
@property (nonatomic, strong) ADDataViewController *dataViewController;

- (instancetype)initWithAppData:(ADAppData *)data dataViewController:(ADDataViewController *)dataViewController;

@end

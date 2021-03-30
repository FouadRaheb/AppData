//
//  ADSelectListTableViewController.m
//  AppDataPrefs
//
//  Created by Fouad Raheb on 3/29/21.
//

#import "ADSelectListTableViewController.h"

@interface ADSelectListTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) ADListItemChange itemChangedBlock;
@property (nonatomic, strong) NSArray *listValues;
@property (nonatomic, strong) NSArray *listItems;
@property (nonatomic, strong) NSString *currentValue;
@property (nonatomic, assign) BOOL popView;

@end

@implementation ADSelectListTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style title:(NSString *)title items:(NSArray *)items values:(NSArray *)values currentValue:(NSString *)value popViewOnSelect:(BOOL)back changeBlock:(ADListItemChange)block {
    self.title = title;
    self.listItems = items;
    self.listValues = values;
    self.currentValue = value;
    self.popView = back;
    self.itemChangedBlock = block;
    return [self initWithStyle:style];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section {
    return self.listItems.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return self.footerText;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ADListCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.listItems objectAtIndex:[indexPath row]];
    if ([[self.listValues objectAtIndex:indexPath.row] isEqualToString:self.currentValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.itemChangedBlock) self.itemChangedBlock([self.listValues objectAtIndex:[indexPath row]]);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for (UITableViewCell *cell in tableView.visibleCells) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    
    if (self.popView) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end

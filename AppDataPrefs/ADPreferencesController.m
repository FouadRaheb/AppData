//
//  ADPreferencesController.m
//  AppDataPrefs
//
//  Created by Fouad Raheb on 3/29/21.
//

#import "ADPreferencesController.h"
#import "ADSettings.h"

#import "ADSwitchTableViewCell.h"
#import "ADHeaderTableViewCell.h"
#import "ADSelectListTableViewController.h"

@interface ADPreferencesInfoViewController : UITableViewController
@end

@interface ADPreferencesController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation ADPreferencesController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active =  YES;
    [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active =  YES;
    [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active =  YES;
    [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active =  YES;
    
    [self.tableView registerClass:[ADHeaderTableViewCell class] forCellReuseIdentifier:ADHeaderTableViewCell.reuseIdentifier];
    [self.tableView registerClass:[ADSwitchTableViewCell class] forCellReuseIdentifier:ADSwitchTableViewCell.reuseIdentifier];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 1;
        case 1: return 2;
        case 2: return 1;
        case 3: return 1;
        case 4: return 2;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ADHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ADHeaderTableViewCell.reuseIdentifier];
        cell.titleLabel.text = @"AppData";
        cell.detailLabel.text = @"View & Manage Apps Data from Homescreen";
        return cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            ADSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ADSwitchTableViewCell.reuseIdentifier];
            [cell configureWithTitle:@"Swipe Up" switchKey:kSwipeUpEnabled];
            return cell;
        } else if (indexPath.row == 1) {
            ADSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ADSwitchTableViewCell.reuseIdentifier];
            [cell configureWithTitle:@"Force Touch Menu" switchKey:kForceTouchMenuEnabled];
            return cell;
        }
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppearanceCellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AppearanceCellIdentifier"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Appearance";
        }
        cell.detailTextLabel.text = [ADSettings titleForAppearanceStyle:[ADSettings integerForKey:kAppearance]];
        return cell;
    } else if (indexPath.section == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"InfoCellIdentifier"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Info";
        }
        return cell;
    } else if (indexPath.section == 4) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeveloperCellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"DeveloperCellIdentifier"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Fouad Raheb";
            cell.detailTextLabel.text = @"Twitter";
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Source Code";
            cell.detailTextLabel.text = @"GitHub";
        }
        return cell;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 1: return @"Activation";
        case 2: return nil;
        case 4: return @"Developer";
        default: return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    switch (section) {
        case 1: return @"The popup can be activated by either swiping up on the app icon or through a button in the force touch menu";
        default: return nil;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1: return ADSwitchTableViewCell.height;
        default: return UITableViewAutomaticDimension;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        ADSelectListTableViewController *listController = [[ADSelectListTableViewController alloc] initWithStyle:UITableViewStyleGrouped
                                                                                                           title:@"Appearance"
                                                                                                           items:[ADSettings appearanceTitles]
                                                                                                          values:[ADSettings appearanceValues]
                                                                                                    currentValue:[NSString stringWithFormat:@"%td",[ADSettings appearanceStyle]]
                                                                                                 popViewOnSelect:YES
                                                                                                     changeBlock:^(NSString *value) {
            [ADSettings setInteger:[value integerValue] forKey:kAppearance];
            cell.detailTextLabel.text = [ADSettings titleForAppearanceStyle:[value integerValue]];
        }];
        [self.navigationController pushViewController:listController animated:YES];
    } else if (indexPath.section == 3) {
        [self.navigationController pushViewController:[ADPreferencesInfoViewController new] animated:YES];
    } else if (indexPath.section == 4) {
        if (indexPath.item == 0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/FouadRaheb"] options:@{} completionHandler:nil];
        } else if (indexPath.item == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/FouadRaheb/AppData"] options:@{} completionHandler:nil];
        }
    }
}

@end

@implementation ADPreferencesInfoViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.title = @"Info";
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"- Copy the app bundle Identifier by tapping it\n\
- Edit app icon name by tapping it\n\
- Filza is required to open folders\n\
- Clearing Caches will delete the app's \"Caches\" and \"Tmp\" folders\n\
- Clearing app data will delete Library/Documents/Tmp folders and reset permissions";
}

@end

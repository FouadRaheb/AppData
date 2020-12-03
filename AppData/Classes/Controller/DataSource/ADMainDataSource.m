//
//  ADMainDataSource.m
//  AppData
//
//  Created by Fouad Raheb on 7/15/20.
//

#import "ADMainDataSource.h"
#import "ADAppData.h"
#import "ADDataViewController.h"

@implementation ADMainDataSource

- (instancetype)initWithAppData:(ADAppData *)data dataViewController:(ADDataViewController *)dataViewController {
    if (self = [super init]) {
        self.appData = data;
        self.dataViewController = dataViewController;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.appData) {
        return 0;
    }
    return 3;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isContainersSection:section]) {
        NSInteger rows = 0;
        if (self.appData.bundleURL) rows++;
        if (self.appData.dataContainerURL) rows++;
        return rows;
    } else if ([self isAppGroupsSection:section]) {
        return self.appData.appGroups.count;
    } else if ([self isManageSection:section]) {
        return 6;
    }
    return 0;
}

- (BOOL)isManageSection:(NSInteger)section {
    return section == 0;
}
- (BOOL)isContainersSection:(NSInteger)section {
    return section == 1;
}
- (BOOL)isAppGroupsSection:(NSInteger)section {
    return section == 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isContainersSection:indexPath.section] || [self isAppGroupsSection:indexPath.section]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"InfoCellIdentifier"];
            [self.class applySharedStylesToCell:cell];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
            cell.detailTextLabel.textColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.961 alpha:0.6];
        }
        if ([self isContainersSection:indexPath.section]) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Bundle";
                cell.detailTextLabel.text = self.appData.bundleURL.path;
            } else if (indexPath.row == 1) {
                cell.textLabel.text = @"Data";
                cell.detailTextLabel.text = self.appData.dataContainerURL.path;
            }
        } else if ([self isAppGroupsSection:indexPath.section]) {
            ADAppDataGroup *group = [self.appData.appGroups objectAtIndex:indexPath.row];
            cell.textLabel.text = group.identifier;
            cell.detailTextLabel.text = group.url.path;
        }
        return cell;
    } else if ([self isManageSection:indexPath.section]) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CachesCellIdentifier"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CachesCellIdentifier"];
                [self.class applySharedStylesToCell:cell];
                UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                [activityIndicatorView startAnimating];
                cell.accessoryView = activityIndicatorView;
                [self.appData getCachesDirectorySizeWithCompletion:^(NSString *formattedSize) {
                    cell.detailTextLabel.text = formattedSize;
                    [activityIndicatorView stopAnimating];
                    [activityIndicatorView removeFromSuperview];
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }];
            }
            cell.textLabel.text = @"Clear Caches";
            return cell;
        }else if (indexPath.row == 3) { //Offload App
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OffloadCellIdentifier"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"OffloadCellIdentifier"];
                [self.class applySharedStylesToCell:cell];
            }
            cell.textLabel.text = @"Offload App";
            
            //Disable for non-vendable app
            if (!self.appData.appProxy.appStoreVendable){
                cell.selectionStyle  = UITableViewCellSelectionStyleNone;
                cell.textLabel.enabled = NO;
            }
            return cell;
        } else if (indexPath.row == 4) { //Reset App
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResetCellIdentifier"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ResetCellIdentifier"];
                [self.class applySharedStylesToCell:cell];
                UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                [activityIndicatorView startAnimating];
                cell.accessoryView = activityIndicatorView;
                [self.appData getAppUsageDirectorySizeWithCompletion:^(NSString *formattedSize) {
                    cell.detailTextLabel.text = formattedSize;
                    [activityIndicatorView stopAnimating];
                    [activityIndicatorView removeFromSuperview];
                    cell.accessoryView = nil;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }];
            }
            cell.textLabel.text = @"Reset App";
            
            //Disable for non-vendable app
            if (!self.appData.appProxy.appStoreVendable){
                cell.selectionStyle  = UITableViewCellSelectionStyleNone;
                cell.textLabel.enabled = NO;
            }
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ManageCellIdentifier"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ManageCellIdentifier"];
                [self.class applySharedStylesToCell:cell];
            }
            if (indexPath.row == 1) {
                cell.textLabel.text = @"Clear Badge";
                NSInteger badgeCount = [self.appData appBadgeCount];
                cell.detailTextLabel.text = badgeCount == 0 ? @"" : [NSString stringWithFormat:@"%td",badgeCount];
            } else if (indexPath.row == 2) { //Reset Permissions
                //Disable for non-vendable app
                cell.textLabel.text = @"Clear Permissions";
                if (!self.appData.appProxy.appStoreVendable){
                    cell.selectionStyle  = UITableViewCellSelectionStyleNone;
                    cell.textLabel.enabled = NO;
                }
            } else if (indexPath.row == 5) {
                cell.textLabel.text = @"More Info";
            }
            return cell;
        }
    }
    return nil;
}

+ (void)applySharedStylesToCell:(UITableViewCell *)cell {
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.557 green:0.557 blue:0.576 alpha:1.0];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.15];
    cell.selectedBackgroundView = selectedBackgroundView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self isContainersSection:section]) {
        return self.appData.isApplication ? @"Containers" : nil;
    } else if ([self isAppGroupsSection:section]) {
        return !self.appData.appGroups || self.appData.appGroups.count == 0 ? nil : @"App Groups";
    } else if ([self isManageSection:section]) {
        return @"Manage";
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isManageSection:indexPath.section]) {
        return 45;
    }
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self isContainersSection:indexPath.section] || [self isAppGroupsSection:indexPath.section]) {
        [self didSelectContainerOrAppGroupSectionAtIndexPath:indexPath];
    } else if ([self isManageSection:indexPath.section]) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (indexPath.row == 0) {
            UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [activityIndicatorView startAnimating];
            cell.accessoryView = activityIndicatorView;
            [self.appData clearAppCachesWithCompletion:^() {
                [self.appData getCachesDirectorySizeWithCompletion:^(NSString *formattedSize) {
                    cell.detailTextLabel.text = formattedSize;
                    cell.accessoryView = nil;
                }];
            }];
        } else if (indexPath.row == 1) {
            [self.appData setAppBadgeCount:0];
            cell.detailTextLabel.text = @"";
        } else if (indexPath.row == 2) { //Reset Permissions
            //Disable for non-vendable app
            if (self.appData.appProxy.appStoreVendable){
                [self.appData resetAllAppPermissions];
            }
        } else if (indexPath.row == 3) { //Offload App
            //Disable for non-vendable app
            if (self.appData.appProxy.appStoreVendable){
                UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                [activityIndicatorView startAnimating];
                cell.accessoryView = activityIndicatorView;
                [self.appData offloadAppWithCompletion:^() {
                    cell.accessoryView = nil;
                }];
            }
        } else if (indexPath.row == 4) { //Reset App
            //Disable for non-vendable app
            if (self.appData.appProxy.appStoreVendable){
                UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
                [activityIndicatorView startAnimating];
                cell.accessoryView = activityIndicatorView;
                [self.appData resetDiskContentWithCompletion:^() {
                    [self.appData getAppUsageDirectorySizeWithCompletion:^(NSString *formattedSize) {
                        cell.detailTextLabel.text = formattedSize;
                        cell.accessoryView = nil;
                    }];
                }];
            }
        } else if (indexPath.row == 5) {
            [self.dataViewController switchTableViews];
        }
    }
}

- (void)didSelectContainerOrAppGroupSectionAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isContainersSection:indexPath.section]) {
        if (indexPath.row == 0) {
            if (self.appData.bundleURL) {
                [ADHelper openDirectoryAtURL:self.appData.bundleURL fromController:self.dataViewController];
            }
        } else if (indexPath.row == 1) {
            if (self.appData.dataContainerURL) {
                [ADHelper openDirectoryAtURL:self.appData.dataContainerURL fromController:self.dataViewController];
            }
        }
    } else if ([self isAppGroupsSection:indexPath.section]) {
        ADAppDataGroup *group = [self.appData.appGroups objectAtIndex:indexPath.row];
        if (group.url) {
            [ADHelper openDirectoryAtURL:group.url fromController:self.dataViewController];
        }
    }
}

#pragma mark - UITableViewDelegate / Copy Action

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        if ([self isContainersSection:indexPath.section] || [self isAppGroupsSection:indexPath.section]) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (cell.detailTextLabel.text) [[UIPasteboard generalPasteboard] setString:cell.detailTextLabel.text];
        }
    }
}

#pragma mark - UITableViewDelegate / Context Menu

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point  API_AVAILABLE(ios(13.0)) {
    if ([self isContainersSection:indexPath.section] || [self isAppGroupsSection:indexPath.section]) {
        UIContextMenuConfiguration *configuration = [UIContextMenuConfiguration configurationWithIdentifier:indexPath
                                                                                            previewProvider:nil
                                                                                             actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
            NSMutableArray *actions = [NSMutableArray new];
            [actions addObject:[UIAction actionWithTitle:@"Open in Filza" image:nil identifier:@"open-action" handler:^(__kindof UIAction * _Nonnull action) {
                [self didSelectContainerOrAppGroupSectionAtIndexPath:indexPath];
            }]];
            [actions addObject:[UIAction actionWithTitle:@"Copy Path" image:nil identifier:@"copy-action" handler:^(__kindof UIAction * _Nonnull action) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                if (cell.detailTextLabel.text) [[UIPasteboard generalPasteboard] setString:cell.detailTextLabel.text];
            }]];
            if ([self isAppGroupsSection:indexPath.section]) {
                [actions addObject:[UIAction actionWithTitle:@"Copy Identifier" image:nil identifier:@"copy-action" handler:^(__kindof UIAction * _Nonnull action) {
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    if (cell.textLabel.text) [[UIPasteboard generalPasteboard] setString:cell.textLabel.text];
                }]];
            }
            NSString *title = @"";
            if ([self isContainersSection:indexPath.section]) {
                if (indexPath.row == 0) title = @"Bundle";
                else if (indexPath.row == 1) title = @"Data";
            } else if ([self isAppGroupsSection:indexPath.section]) {
                title = @"App Group";
            }
            return [UIMenu menuWithTitle:title children:actions];
        }];
        return configuration;
    }
    return nil;
}

- (UITargetedPreview *)tableView:(UITableView *)tableView previewForHighlightingContextMenuWithConfiguration:(UIContextMenuConfiguration *)configuration API_AVAILABLE(ios(13.0)) {
    NSIndexPath *indexPath = (NSIndexPath *)[configuration identifier];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIPreviewParameters *parameters = [UIPreviewParameters new];
    parameters.backgroundColor = [UIColor clearColor];
    if ([self isAppGroupsSection:indexPath.section]) {
        return [[UITargetedPreview alloc] initWithView:cell parameters:parameters];
    } else {
        return [[UITargetedPreview alloc] initWithView:cell.detailTextLabel parameters:parameters];
    }
}

- (nullable UITargetedPreview *)tableView:(UITableView *)tableView previewForDismissingContextMenuWithConfiguration:(UIContextMenuConfiguration *)configuration API_AVAILABLE(ios(13.0)) {
    return [self tableView:tableView previewForHighlightingContextMenuWithConfiguration:configuration];
}

@end

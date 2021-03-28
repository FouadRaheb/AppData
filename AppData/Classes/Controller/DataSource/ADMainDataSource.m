//
//  ADMainDataSource.m
//  AppData
//
//  Created by Fouad Raheb on 7/15/20.
//

#import "ADMainDataSource.h"
#import "ADAppData.h"
#import "ADDataViewController.h"
#import "ADActionsBarView.h"

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
        //return 6;
        return 2;
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
            cell.backgroundColor = [UIColor clearColor];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        }
        [self.class applyStylesToCell:cell];
        
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
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ManageCellIdentifier"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ManageCellIdentifier"];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                ADActionsBarView *actionsBar = [[ADActionsBarView alloc] init];
                actionsBar.translatesAutoresizingMaskIntoConstraints = NO;
                [cell.contentView addSubview:actionsBar];
                [actionsBar.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor].active = YES;
                [actionsBar.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor].active = YES;
                [actionsBar.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor].active = YES;
                [actionsBar.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor].active = YES;

                __weak ADActionsBarView *weakActionsBar = actionsBar;
                
                // Clear Badge
                [actionsBar addItemWithTitle:@"Update\nBadge"
                                      detail:[NSString stringWithFormat:@"%td",[self.appData appBadgeCount]]
                                       image:[ADHelper imageNamed:@"ClearBadge"]
                                     handler:^{
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Badges"
                                                                                             message:[NSString stringWithFormat:@"Update or clear the app badges count"]
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                        textField.text = [NSString stringWithFormat:@"%td",self.appData.appBadgeCount];
                        textField.placeholder = @"Badge Count";
                        textField.textAlignment = NSTextAlignmentCenter;
                        textField.enabled = NO;
                    }];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Update" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        UITextField *field = alertController.textFields.firstObject;
                        NSInteger count = [field.text integerValue];
                        [self.appData setAppBadgeCount:count];
                        [weakActionsBar setDetail:@"Updated!" forItemAtIndex:0];
                        DISPATCH_AFTER(0.5, { [weakActionsBar setDetail:[NSString stringWithFormat:@"%td",count] forItemAtIndex:0]; });
                        if (self.dataViewController.dockDismissed && IS_IPAD) [ADDataViewController presentFloatingDockIfNeeded];
                    }]];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Clear" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self.appData setAppBadgeCount:0];
                        [weakActionsBar setDetail:@"Cleared!" forItemAtIndex:0];
                        DISPATCH_AFTER(0.5, { [weakActionsBar setDetail:@"0" forItemAtIndex:0]; });
                        if (self.dataViewController.dockDismissed && IS_IPAD) [ADDataViewController presentFloatingDockIfNeeded];
                    }]];
                    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        if (self.dataViewController.dockDismissed && IS_IPAD) [ADDataViewController presentFloatingDockIfNeeded];
                    }]];
                    
                    if (IS_IPAD) {
                        self.dataViewController.dockDismissed = [ADDataViewController dismissFloatingDockIfNeededWithCompletion:^{
                            [self.dataViewController presentViewController:alertController animated:YES completion:^{
                                alertController.textFields.firstObject.enabled = true;
                            }];
                        }];
                    } else {
                        [self.dataViewController presentViewController:alertController animated:YES completion:^{
                            alertController.textFields.firstObject.enabled = true;
                        }];
                    }
                }];
                
                // Clear Caches
                [actionsBar addItemWithTitle:@"Clear\nCaches"
                                detail:@"Loading..."
                                 image:[ADHelper imageNamed:@"ClearCache"]
                                     handler:^{
                    NSInteger itemIndex = 1;
                    [weakActionsBar showLoadingIndicatorForItemAtIndex:itemIndex];
                    [weakActionsBar setDetail:@"Clearing..." forItemAtIndex:itemIndex];
                    DISPATCH_AFTER(0.5, {
                        [self.appData clearAppCachesWithCompletion:^{
                            [weakActionsBar hideLoadingIndicatorForItemAtIndex:itemIndex];
                            [weakActionsBar setDetail:@"Cleared!" forItemAtIndex:itemIndex];
                            [[UINotificationFeedbackGenerator new] notificationOccurred:UINotificationFeedbackTypeSuccess];
                            DISPATCH_AFTER(0.5, {
                                [self.appData getCachesDirectorySizeWithCompletion:^(NSString *formattedSize) {
                                    [weakActionsBar setDetail:formattedSize forItemAtIndex:itemIndex];
                                }];
                            });
                        }];
                    });
                }];
                
                // Clear App Data
                [actionsBar addItemWithTitle:@"Clear App Data"
                                      detail:@"Loading..."
                                       image:[ADHelper imageNamed:@"ClearData"]
                                     handler:^{
                    if (self.appData.appStoreVendable) {
                        [self showDestructiveConfirmationAlertWithTitle:@"Clear App Data" message:@"Clearing App data will only delete the app's \"Library\" and \"Documents\" folders inside Data bundle and not the App Groups." confirmTitle:@"Clear" confirmHandler:^{
                            NSInteger itemIndex = 2;
                            [weakActionsBar showLoadingIndicatorForItemAtIndex:itemIndex];
                            [weakActionsBar setDetail:@"Clearing..." forItemAtIndex:itemIndex];
                            DISPATCH_AFTER(0.5, {
                                [self.appData resetDiskContentWithCompletion:^{
                                    [weakActionsBar hideLoadingIndicatorForItemAtIndex:itemIndex];
                                    [weakActionsBar setDetail:@"Cleared!" forItemAtIndex:itemIndex];
                                    [[UINotificationFeedbackGenerator new] notificationOccurred:UINotificationFeedbackTypeSuccess];
                                    DISPATCH_AFTER(0.5, {
                                        [self.appData getAppUsageDirectorySizeWithCompletion:^(NSString *formattedSize) {
                                            [weakActionsBar setDetail:formattedSize forItemAtIndex:itemIndex];
                                        }];
                                    });
                                }];
                            });
                        }];
                    }
                }];
                
                // Reset Permissions
                [actionsBar addItemWithTitle:@"Reset Permissions"
                                      detail:[NSString stringWithFormat:@"%td",[self.appData getPermissions].count]
                                       image:[ADHelper imageNamed:@"ResetPermissions"]
                                     handler:^{
                    if (self.appData.appStoreVendable) {
                        [self showDestructiveConfirmationAlertWithTitle:@"Reset Permissions" message:@"This will clear all the app permissions to access your Contacts, Photos, Camera, etc.\nNext time you use the app it will ask you again to grant permissions." confirmTitle:@"Reset" confirmHandler:^{
                            NSInteger itemIndex = 3;
                            [self.appData resetAllAppPermissions];
                            [weakActionsBar setDetail:@"Reset!" forItemAtIndex:itemIndex];
                            [[UINotificationFeedbackGenerator new] notificationOccurred:UINotificationFeedbackTypeSuccess];
                            DISPATCH_AFTER(0.5, {
                               [weakActionsBar setDetail:[NSString stringWithFormat:@"%td",[self.appData getPermissions].count] forItemAtIndex:itemIndex];
                            });
                        }];
                    }
                }];
                
                // Offload App
                [actionsBar addItemWithTitle:@"Offload\nApp"
                                      detail:nil
                                       image:[ADHelper imageNamed:@"OffloadApp"]
                                     handler:^{
                    if (self.appData.appStoreVendable) {
                        [self showDestructiveConfirmationAlertWithTitle:@"Offload App" message:@"This will free up storage used by the app, but keep its documents and data. Reinstalling the app will reinstate your data if the app is still available in the AppStore." confirmTitle:@"Offload" confirmHandler:^{
                            NSInteger itemIndex = 4;
                            [weakActionsBar showLoadingIndicatorForItemAtIndex:itemIndex];
                            [self.appData offloadAppWithCompletion:^{
                                [weakActionsBar hideLoadingIndicatorForItemAtIndex:itemIndex];
                                [[UINotificationFeedbackGenerator new] notificationOccurred:UINotificationFeedbackTypeSuccess];
                            }];
                        }];
                    }
                }];
                
                if (!self.appData.appStoreVendable) {
                    [actionsBar setItemEnabled:NO atIndex:2];
                    [actionsBar setItemEnabled:NO atIndex:3];
                    [actionsBar setItemEnabled:NO atIndex:4];
                }
                
                // Set Cache Size
                [actionsBar showLoadingIndicatorForItemAtIndex:1];
                [self.appData getCachesDirectorySizeWithCompletion:^(NSString *formattedSize) {
                    [actionsBar setDetail:formattedSize forItemAtIndex:1];
                    [actionsBar hideLoadingIndicatorForItemAtIndex:1];
                }];
                
                // Set App Data Size
                [actionsBar showLoadingIndicatorForItemAtIndex:2];
                [self.appData getAppUsageDirectorySizeWithCompletion:^(NSString *formattedSize) {
                    [actionsBar setDetail:formattedSize forItemAtIndex:2];
                    [actionsBar hideLoadingIndicatorForItemAtIndex:2];
                }];
            }
            return cell;
        } else if (indexPath.row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MoreInfoCellIdentifier"];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MoreInfoCellIdentifier"];
                cell.backgroundColor = [UIColor clearColor];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            [self.class applyStylesToCell:cell];
            cell.textLabel.text = @"More Info";
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isManageSection:indexPath.section] && indexPath.row == 0) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
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
        if (indexPath.row == 0) {
            return 90;
        }
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
    if ([self isManageSection:indexPath.section]) {
        if (indexPath.row == 1) {
            [self.dataViewController switchTableViews];
        }
    } else if ([self isContainersSection:indexPath.section] || [self isAppGroupsSection:indexPath.section]) {
        [self didSelectContainerOrAppGroupSectionAtIndexPath:indexPath];
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

#pragma mark - Styles

+ (void)applyStylesToCell:(UITableViewCell *)cell {
    if (@available(iOS 13.0, *)) {
        if (cell.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
            [self applyLightStylesToCell:cell];
        } else {
            [self applyDarkStylesToCell:cell];
        }
    } else {
        [self applyDarkStylesToCell:cell];
    }
}

+ (void)applyLightStylesToCell:(UITableViewCell *)cell {
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.235294 green:0.235294 blue:0.262745 alpha:0.70];
    cell.textLabel.textColor = [UIColor blackColor];
    
    if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.35];
        cell.selectedBackgroundView = backgroundView;
    }
}

+ (void)applyDarkStylesToCell:(UITableViewCell *)cell {
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.961 alpha:0.6];
    cell.textLabel.textColor = [UIColor whiteColor];

    if (cell.selectionStyle != UITableViewCellSelectionStyleNone) {
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.15];
        cell.selectedBackgroundView = backgroundView;
    }
}

#pragma mark - Helpers

- (void)showDestructiveConfirmationAlertWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle confirmHandler:(void(^)())confirmHandler {
    return [self showConfirmationAlertWithTitle:title message:message confirmTitle:confirmTitle confirmStyle:UIAlertActionStyleDestructive confirmHandler:confirmHandler];
}

- (void)showConfirmationAlertWithTitle:(NSString *)title message:(NSString *)message confirmTitle:(NSString *)confirmTitle confirmStyle:(UIAlertActionStyle)style confirmHandler:(void(^)())confirmHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:confirmTitle style:style handler:^(UIAlertAction * _Nonnull action) {
        if (confirmHandler) confirmHandler();
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self.dataViewController presentViewController:alertController animated:YES completion:nil];
}

@end

//
//  ADMoreDataSource.m
//  AppData
//
//  Created by Fouad Raheb on 7/15/20.
//

#import "ADMoreDataSource.h"
#import "ADMainDataSource.h"
#import "ADAppData.h"
#import "ADDataViewController.h"

@interface ADMoreDataSource ()
@property (nonatomic, assign) NSInteger expandedSection;
@end

@implementation ADMoreDataSource

- (instancetype)initWithAppData:(ADAppData *)data dataViewController:(ADDataViewController *)dataViewController {
    if (self = [super init]) {
        self.appData = data;
        self.dataViewController = dataViewController;
        self.expandedSection = -1;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return self.appData.urlSchemes.count;
    } else if (section == 2) {
        return self.appData.queriesSchemes.count;
    } else if (section == 3) {
        return self.appData.activityTypes.count;
    } else if (section == 4) {
        return self.appData.backgroundModes.count;
    } else if (section == 5) {
        return self.appData.entitlementsIdentifiers.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        return self.expandedSection == section ? [self numberOfRowsInSection:section] : 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TextCellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TextCellIdentifier"];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        }
        [ADAppearance applyStylesToCell:cell];
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Internal Version";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.appData.internalVersion];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Minimum iOS Version";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.appData.minimumOSVersion];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Platform Build Version";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",self.appData.platformVersion];
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExpandableTextCellIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ExpandableTextCellIdentifier"];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        }
        [ADAppearance applyStylesToCell:cell];
        if (indexPath.section == 1) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.appData.urlSchemes objectAtIndex:indexPath.row]];
        } else if (indexPath.section == 2) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.appData.queriesSchemes objectAtIndex:indexPath.row]];
        } else if (indexPath.section == 3) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.appData.activityTypes objectAtIndex:indexPath.row]];
        } else if (indexPath.section == 4) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.appData.backgroundModes objectAtIndex:indexPath.row]];
        } else if (indexPath.section == 5) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@",[self.appData.entitlementsIdentifiers objectAtIndex:indexPath.row]];
        }
        return cell;
    }
    return nil;
}

- (UIImage *)makeThumbnailOfSize:(CGSize)size ofImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newThumbnail;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 35 : 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 5) {
        NSString *entitlementIdentifier = [self.appData.entitlementsIdentifiers objectAtIndex:indexPath.row];
        NSString *detailText = [NSString stringWithFormat:@"%@",[self.appData.entitlements objectForKey:entitlementIdentifier]];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:entitlementIdentifier message:detailText preferredStyle:IS_IPAD ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (detailText) [[UIPasteboard generalPasteboard] setString:detailText];
        }]];
        [self.dataViewController presentViewController:alertController animated:YES completion:nil];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        ADTitleSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ADTitleSectionHeaderView.reuseIdentifier];
        [header configureBackHeaderWithTitle:@"MORE INFO"];
        header.delegate = self;
        return header;
    } else {
        ADExpandableSectionHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ADExpandableSectionHeaderView.reuseIdentifier];
        header.section = section;
        header.delegate = self;
        if (section == 1) {
            header.titleLabel.text = [NSString stringWithFormat:@"URL SCHEMES (%td)",self.appData.urlSchemes.count];
        } else if (section == 2) {
            header.titleLabel.text = [NSString stringWithFormat:@"QUERIES SCHEMES (%td)",self.appData.queriesSchemes.count];
        } else if (section == 3) {
            header.titleLabel.text = [NSString stringWithFormat:@"ACTIVITY TYPES (%td)",self.appData.activityTypes.count];
        } else if (section == 4) {
            header.titleLabel.text = [NSString stringWithFormat:@"BACKGROUND MODES (%td)",self.appData.backgroundModes.count];
        } else if (section == 5) {
            header.titleLabel.text = [NSString stringWithFormat:@"ENTITLEMENTS (%td)",self.appData.entitlementsIdentifiers.count];
        }
        return header;
    }
}

#pragma mark - ADTitleSectionHeaderViewDelegate

- (void)titleSectionHeaderViewDidTapBackButton {
    [self.dataViewController switchTableViews];
}

#pragma mark - ADExpandableSectionHeaderViewDelegate

- (void)expandableSectionHeaderViewDidChange:(ADExpandableSectionHeaderView *)headerView {
    UITableView *tableView = self.dataViewController.moreTableView;
    
    NSInteger currentSection = self.expandedSection;
    
    [tableView beginUpdates];
    if (self.expandedSection == -1) {
        self.expandedSection = headerView.section;
        [self showRowsOfSection:headerView.section inTableView:tableView];
    } else if (self.expandedSection == headerView.section) {
        self.expandedSection = -1;
        [self hideRowsOfSection:currentSection inTableView:tableView];
    } else {
        self.expandedSection = headerView.section;
        
        ADExpandableSectionHeaderView *currentHeaderView = (ADExpandableSectionHeaderView *)([tableView headerViewForSection:currentSection]);
        currentHeaderView.isExpanded = NO;
        
        [self hideRowsOfSection:currentSection inTableView:tableView];
        [self showRowsOfSection:headerView.section inTableView:tableView];
    }
    [tableView endUpdates];
}

- (void)hideRowsOfSection:(NSInteger)section inTableView:(UITableView *)tableView {
    NSArray *indexPaths = [self indexPathsForRowsinSection:section tableView:tableView];
    [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

- (void)showRowsOfSection:(NSInteger)section inTableView:(UITableView *)tableView {
    NSArray *indexPaths = [self indexPathsForRowsinSection:section tableView:tableView];
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSArray *)indexPathsForRowsinSection:(NSInteger)section tableView:(UITableView *)tableView {
    NSInteger numberOfRowsInSection = [self numberOfRowsInSection:section];
    NSMutableArray *indexPaths = [NSMutableArray new];
    for (NSInteger i = 0; i < numberOfRowsInSection; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    return indexPaths;
}

#pragma mark - UITableViewDelegate / Context Menu

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point  API_AVAILABLE(ios(13.0)) {
    UIContextMenuConfiguration *configuration = [UIContextMenuConfiguration configurationWithIdentifier:indexPath
                                                                                        previewProvider:nil
                                                                                         actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
        NSMutableArray *actions = [NSMutableArray new];
        [actions addObject:[UIAction actionWithTitle:@"Copy" image:nil identifier:@"copy-action" handler:^(__kindof UIAction * _Nonnull action) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (indexPath.section == 1) {
                if (cell.detailTextLabel.text) [[UIPasteboard generalPasteboard] setString:cell.detailTextLabel.text];
            } else {
                if (cell.textLabel.text) [[UIPasteboard generalPasteboard] setString:cell.textLabel.text];
            }
        }]];
        return [UIMenu menuWithTitle:@"" children:actions];
    }];
    return configuration;

}

- (UITargetedPreview *)tableView:(UITableView *)tableView previewForHighlightingContextMenuWithConfiguration:(UIContextMenuConfiguration *)configuration API_AVAILABLE(ios(13.0)) {
    NSIndexPath *indexPath = (NSIndexPath *)[configuration identifier];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIPreviewParameters *parameters = [UIPreviewParameters new];
    parameters.backgroundColor = [UIColor clearColor];
    return [[UITargetedPreview alloc] initWithView:cell parameters:parameters];
}

- (nullable UITargetedPreview *)tableView:(UITableView *)tableView previewForDismissingContextMenuWithConfiguration:(UIContextMenuConfiguration *)configuration API_AVAILABLE(ios(13.0)) {
    return [self tableView:tableView previewForHighlightingContextMenuWithConfiguration:configuration];
}

@end

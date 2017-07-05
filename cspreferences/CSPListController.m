/**
 * @Author: Dana Buehre <creaturesurvive>
 * @Date:   01-07-2017 10:49:52
 * @Email:  dbuehre@me.com
 * @Project: motuumLS
 * @Filename: CSPListController.m
 * @Last modified by:   creaturesurvive
 * @Last modified time: 05-07-2017 12:34:54
 * @Copyright: Copyright © 2014-2017 CreatureSurvive
 */


#include "CSPListController.h"


@implementation CSPListController {

    NSMutableDictionary *_settings;
    NSMutableArray *_disabledCells;
    NSArray *_toggleGroups;
}

#pragma mark Initialize
// Initialize the settings dictionary
- (id)init {
    if ((self = [super init]) != nil) {
        _settings = [NSMutableDictionary dictionaryWithContentsOfFile:_plistfile] ? : [NSMutableDictionary dictionary];
        _disabledCells = [NSMutableArray array];
        _toggleGroups = @[@"enabled",
                          @"enabled1"];
    }

    return self;
}

// return the specifiers from .plist
- (id)specifiers {
    if (_specifiers == nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }

    return _specifiers;
}

#pragma mark Load View

// tint the view after it loads
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setTintEnabled:YES];
    [self setupHeader];
}

// remove tint wen leaving the view
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setTintEnabled:NO];
}

// sets the tint colors for the view
- (void)setTintEnabled:(BOOL)enabled {
    if (enabled) {
        // Color the navbar
        self.navigationController.navigationController.navigationBar.tintColor = _accentTintColor;
        self.navigationController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : _accentTintColor};

        // set cell control colors
        [UISwitch appearanceWhenContainedInInstancesOfClasses:@[[self.class class]]].onTintColor = _accentTintColor;
        [UITableView appearanceWhenContainedInInstancesOfClasses:@[[self.class class]]].tintColor = _accentTintColor;
        [UITextField appearanceWhenContainedInInstancesOfClasses:@[[self.class class]]].textColor = _accentTintColor;
        [UISegmentedControl appearanceWhenContainedInInstancesOfClasses:@[[self.class class]]].tintColor = _accentTintColor;
        [self setSegmentedSliderTrackColor:_accentTintColor];

        // set the view tint
        self.view.tintColor = _accentTintColor;
    } else {
        // Un-Color the navbar when leaving the view
        self.navigationController.navigationController.navigationBar.tintColor = nil;
        self.navigationController.navigationController.navigationBar.titleTextAttributes = nil;

    }
}

// adds the header to the view
- (void)setupHeader {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.table.bounds.size.width, 126)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UILabel *subHeaderLabel = [[UILabel alloc] initWithFrame:CGRectZero];

    headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [headerLabel setNumberOfLines:1];
    [headerLabel setFont:[UIFont systemFontOfSize:36]];
    [headerLabel setText:_titleString];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setTextColor:_accentTintColor];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    [header addSubview:headerLabel];
    [headerLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [header addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:header attribute:NSLayoutAttributeBottom multiplier:0.2 constant:0]];
    [header addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:header attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    subHeaderLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [subHeaderLabel setNumberOfLines:1];
    [subHeaderLabel setFont:[UIFont systemFontOfSize:17]];
    [subHeaderLabel setText:_subString];
    [subHeaderLabel setBackgroundColor:[UIColor clearColor]];
    [subHeaderLabel setTextColor:_accentTintColor];
    [subHeaderLabel setTextAlignment:NSTextAlignmentCenter];
    [header addSubview:subHeaderLabel];
    [subHeaderLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [header addConstraint:[NSLayoutConstraint constraintWithItem:subHeaderLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:5]];
    [header addConstraint:[NSLayoutConstraint constraintWithItem:subHeaderLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:header attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

    self.table.tableHeaderView = header;
}

#pragma mark PSListController
// dismiss keyboard when pressing return key
- (void)_returnKeyPressed:(id)sender {
    [self.view endEditing:NO];
}

#pragma mark UITableView

// Adjust labels when loading the cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    [cell.detailTextLabel setAdjustsFontSizeToFitWidth:YES];
    cell.textLabel.textColor = _accentTintColor;

    return cell;
}

// make sure that the control for the cell is enabled/disabled when the cell is enabled/disabled
- (void)setCellForRowAtIndexPath:(NSIndexPath *)indexPath enabled:(BOOL)enabled {
    UITableViewCell *cell = [self tableView:self.table cellForRowAtIndexPath:indexPath];
    if (cell) {
        cell.userInteractionEnabled = enabled;
        cell.textLabel.enabled = enabled;
        cell.detailTextLabel.enabled = enabled;
        cell.hidden = !enabled;

        if ([cell isKindOfClass:[PSControlTableCell class]]) {
            PSControlTableCell *controlCell = (PSControlTableCell *)cell;
            if (controlCell.control) {
                controlCell.control.enabled = enabled;
            }
        }
    }
}

// dismiss keyboard when scrolling begins
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:NO];
}

#pragma mark Preferences

// writes the preferences to disk after setting additionally posts a notification
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:PSKeyNameKey];
    _settings = ([NSMutableDictionary dictionaryWithContentsOfFile:_plistfile] ? : [NSMutableDictionary dictionary]);
    [_settings setObject:value forKey:[specifier propertyForKey:PSKeyNameKey]];
    [_settings writeToFile:_plistfile atomically:YES];

    [self setSpecifiersInGroupOfSpecifier:specifier enabled:[value boolValue] animated:YES];

    NSString *post = [specifier propertyForKey:@"PostNotification"];
    if (post) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)post, NULL, NULL, TRUE);
    }
}

// returns the settings from disk when loading else reads default
- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = [specifier propertyForKey:PSKeyNameKey];
    id defaultValue = [specifier propertyForKey:PSDefaultValueKey];
    id plistValue = [_settings objectForKey:key];
    if (!plistValue) plistValue = defaultValue;

    [self setSpecifiersInGroupOfSpecifier:specifier enabled:[plistValue boolValue] animated:NO];

    return plistValue;
}

#pragma mark PSSpecifier Actions
// respring action
- (void)respring {
    UIAlertAction *cancelAction, *confirmAction;
    UIAlertController *alertController;
    alertController = [UIAlertController alertControllerWithTitle:@"CSPreferences"
                                                          message:@"Are you sure you want to respring?"
                                                   preferredStyle:UIAlertControllerStyleActionSheet];

    cancelAction = [UIAlertAction
                    actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                            handler:nil];

    confirmAction = [UIAlertAction
                     actionWithTitle:@"Respring"
                               style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction *action) {
        pid_t pid;
        int status;
        const char *args[] = {"killall", "SpringBoard", NULL};
        posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char *const *)args, NULL);
        waitpid(pid, &status, WEXITED);
    }];

    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

// email action
- (void)contact {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:support@creaturecoding.com?subject=CSPreferences%20v0.0.1"]];
}

// launch github
- (void)github {
    [self openURLInBrowser:@"https://github.com/CreatureSurvive/CSPreferences"];
}

// launch paypal
- (void)paypal {
    [self openURLInBrowser:@"https://paypal.me/creaturesurvive"];
}

// launch twitter
- (void)twitter {
    [self openURLInBrowser:@"https://mobile.twitter.com/creaturesurvive"];
}

#pragma mark Extentions

// toggles all cells in the the group the given specifier is in
// does not remove PSGroupCell or the cell of the given specifier
- (void)setSpecifiersInGroupOfSpecifier:(PSSpecifier *)specifier enabled:(BOOL)enabled animated:(BOOL)animated {
    NSString *key = [specifier propertyForKey:PSKeyNameKey];
    if (![_toggleGroups containsObject:key]) return;

    [self applyChanges:^{
        for (PSSpecifier *currentSpecifier in [self specifiersInGroup:[self indexPathForSpecifier:specifier].section]) {
            if ([currentSpecifier isEqualToSpecifier:specifier] || currentSpecifier.cellType == PSGroupCell) continue;
            [self setSpecifier:currentSpecifier enabled:enabled];
        }
    } animated:animated];
}

// sets the height for the specifier when enabled/disabled and updates the cell
- (void)setSpecifier:(PSSpecifier *)specifier enabled:(BOOL)enabled {
    [specifier setProperty:@(enabled ? 44 : 0) forKey:PSTableCellHeightKey];
    [self setCellForRowAtIndexPath:[self indexPathForSpecifier:specifier] enabled:enabled];
}

// calls setSpecifiers: enabled: on an array of specifiers
- (void)setSpecifiers:(NSArray *)specifiers enabled:(BOOL)enabled {
    for (PSSpecifier *specifier in specifiers) {
        [self setSpecifier:specifier enabled:enabled];
    }
}

// returns a block to apply changes either animated or not
- (void)applyChanges:(void (^)(void))changes animated:(BOOL)animated {
    if (animated) {
        [self beginUpdates];
        changes();
        [self endUpdates];
    } else {
        changes();
    }
}

#pragma mark Utility

// opens the specified url in SFSafariViewController
- (void)openURLInBrowser:(NSString *)url {
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url] entersReaderIfAvailable:NO];
    // using this method for coloring because it supports ios 9 as well
    safari.view.tintColor = _accentTintColor;
    [self presentViewController:safari animated:YES completion:nil];
}

@end

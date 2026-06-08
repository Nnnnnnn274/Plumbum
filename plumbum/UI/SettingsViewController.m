//
//  SettingsViewController.m
//  plumbum
//
//  Created by seo on 6/8/26.
//

#import "SettingsViewController.h"
#import "SileoColors.h"
#import "../PackageManager/Repository.h"

@interface SettingsViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *settingsSections;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Settings";
    
    [self setupTableView];
    [self loadSettings];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [SileoColors background];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:_tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)loadSettings {
    _settingsSections = @[
        @{
            @"title": @"About",
            @"items": @[
                @{@"title": @"Version", @"value": @"1.0.0", @"type": @"info"},
                @{@"title": @"Build", @"value": @"Release", @"type": @"info"},
                @{@"title": @"Developer", @"value": @"seo", @"type": @"info"}
            ]
        },
        @{
            @"title": @"Repositories",
            @"items": @[
                @{@"title": @"Manage Repositories", @"type": @"navigation"},
                @{@"title": @"Refresh All", @"type": @"action"}
            ]
        },
        @{
            @"title": @"Appearance",
            @"items": @[
                @{@"title": @"Dark Mode", @"type": @"toggle", @"value": @YES},
                @{@"title": @"Accent Color", @"type": @"navigation"}
            ]
        },
        @{
            @"title": @"Advanced",
            @"items": @[
                @{@"title": @"Clear Cache", @"type": @"action"},
                @{@"title": @"Reset Settings", @"type": @"destructive"}
            ]
        }
    ];
    
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _settingsSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_settingsSections[section][@"items"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _settingsSections[section][@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SettingsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [SileoColors secondaryBackground];
        cell.textLabel.textColor = [SileoColors primaryText];
        cell.detailTextLabel.textColor = [SileoColors tertiaryText];
        cell.selectedBackgroundView = [[UIView alloc] init];
        cell.selectedBackgroundView.backgroundColor = [SileoColors tertiaryBackground];
    }
    
    NSDictionary *item = _settingsSections[indexPath.section][@"items"][indexPath.row];
    cell.textLabel.text = item[@"title"];
    
    NSString *type = item[@"type"];
    if ([type isEqualToString:@"info"]) {
        cell.detailTextLabel.text = item[@"value"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([type isEqualToString:@"navigation"]) {
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if ([type isEqualToString:@"action"]) {
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    } else if ([type isEqualToString:@"toggle"]) {
        cell.detailTextLabel.text = nil;
        UISwitch *toggle = [[UISwitch alloc] init];
        toggle.onTintColor = [SileoColors sileoBlue];
        [toggle setOn:[item[@"value"] boolValue] animated:NO];
        toggle.tag = indexPath.row;
        [toggle addTarget:self action:@selector(toggleChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = toggle;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else if ([type isEqualToString:@"destructive"]) {
        cell.detailTextLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor redColor];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *item = _settingsSections[indexPath.section][@"items"][indexPath.row];
    NSString *type = item[@"type"];
    
    if ([type isEqualToString:@"action"]) {
        NSString *title = item[@"title"];
        if ([title isEqualToString:@"Refresh All"]) {
            [self refreshAllRepositories];
        } else if ([title isEqualToString:@"Clear Cache"]) {
            [self clearCache];
        } else if ([title isEqualToString:@"Reset Settings"]) {
            [self resetSettings];
        }
    }
}

- (void)toggleChanged:(UISwitch *)sender {
    // Handle toggle changes
    NSLog(@"Toggle changed: %ld", (long)sender.tag);
}

- (void)refreshAllRepositories {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Refresh All"
                                                                   message:@"Refreshing all repositories..."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:^{
        RepositoryManager *manager = [RepositoryManager sharedManager];
        [manager refreshAllRepositories:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:^{
                    if (success) {
                        UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                                           message:@"All repositories refreshed"
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                        [successAlert addAction:action];
                        [self presentViewController:successAlert animated:YES completion:nil];
                    } else {
                        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                          message:error.localizedDescription
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                        [errorAlert addAction:action];
                        [self presentViewController:errorAlert animated:YES completion:nil];
                    }
                }];
            });
        }];
    }];
}

- (void)clearCache {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Clear Cache"
                                                                   message:@"Cache cleared"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)resetSettings {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Reset Settings"
                                                                   message:@"Are you sure you want to reset all settings?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Reset Complete"
                                                                              message:@"Settings have been reset"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [successAlert addAction:okAction];
        [self presentViewController:successAlert animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:confirmAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end

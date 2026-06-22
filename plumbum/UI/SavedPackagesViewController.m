//
//  SavedPackagesViewController.m
//  plumbum
//
//  Created by seo on 6/22/26.
//

#import "SavedPackagesViewController.h"
#import "PackageDetailViewController.h"
#import "SileoColors.h"
#import "../PackageManager/PackageManager.h"

@interface SavedPackagesViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<PlumbumPackage *> *savedPackages;
@end

@implementation SavedPackagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Saved";
    [self setupTableView];
    [self configureNavigationBar];
    [self loadSavedPackages];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.backgroundColor = [SileoColors background];
    _tableView.separatorColor = [SileoColors separatorColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];

    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)configureNavigationBar {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [SileoColors background];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors primaryText]};
        appearance.shadowColor = [SileoColors separatorColor];
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    self.navigationController.navigationBar.tintColor = [SileoColors sileoBlue];
}

- (void)loadSavedPackages {
    PackageManager *manager = [PackageManager sharedManager];
    _savedPackages = [manager savedPackages];
    [_tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _savedPackages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SavedPackageCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [SileoColors secondaryBackground];
        cell.textLabel.textColor = [SileoColors primaryText];
        cell.detailTextLabel.textColor = [SileoColors secondaryText];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    PlumbumPackage *package = _savedPackages[indexPath.row];
    cell.textLabel.text = package.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ by %@", package.version ?: @"Unknown", package.author ?: @"Unknown"];
    
    // Add apply button
    UIButton *applyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [applyButton setTitle:@"Apply" forState:UIControlStateNormal];
    applyButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    [applyButton setTitleColor:[SileoColors sileoBlue] forState:UIControlStateNormal];
    applyButton.backgroundColor = [[SileoColors sileoBlue] colorWithAlphaComponent:0.12];
    applyButton.layer.cornerRadius = 8;
    applyButton.layer.masksToBounds = YES;
    applyButton.tag = indexPath.row;
    [applyButton addTarget:self action:@selector(applyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    applyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:applyButton];
    
    // Remove existing button if any
    for (UIView *subview in cell.contentView.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [subview removeFromSuperview];
        }
    }
    
    [cell.contentView addSubview:applyButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [applyButton.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
        [applyButton.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
        [applyButton.widthAnchor constraintEqualToConstant:70],
        [applyButton.heightAnchor constraintEqualToConstant:32],
    ]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PlumbumPackage *package = _savedPackages[indexPath.row];
    PackageDetailViewController *detailVC = [[PackageDetailViewController alloc] initWithPackage:package];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PlumbumPackage *package = _savedPackages[indexPath.row];
        PackageManager *manager = [PackageManager sharedManager];
        [manager removeSavedPackage:package];
        
        NSMutableArray *mutablePackages = [_savedPackages mutableCopy];
        [mutablePackages removeObjectAtIndex:indexPath.row];
        _savedPackages = [mutablePackages copy];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Actions

- (void)applyButtonTapped:(UIButton *)sender {
    NSInteger index = sender.tag;
    PlumbumPackage *package = _savedPackages[index];
    
    PackageManager *manager = [PackageManager sharedManager];
    NSError *error = nil;
    
    if ([manager installPackage:package error:&error]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                       message:[NSString stringWithFormat:@"%@ applied successfully", package.name]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:error.localizedDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end

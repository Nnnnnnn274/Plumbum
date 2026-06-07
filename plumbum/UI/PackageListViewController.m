//
//  PackageListViewController.m
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import "PackageListViewController.h"
#import "SileoColors.h"
#import "PackageDetailViewController.h"
#import "../PackageManager/PackageManager.h"
#import "../PackageManager/Repository.h"

@interface PackageListViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray<PlumbumPackage *> *filteredPackages;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation PackageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Packages";
    
    [self setupTableView];
    [self setupSearchBar];
    [self loadPackages];
    
    // Configure navigation bar
    [self configureNavigationBar];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [SileoColors background];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_tableView registerClass:[PackageCell class] forCellReuseIdentifier:@"PackageCell"];
    
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [SileoColors sileoBlue];
    [_refreshControl addTarget:self action:@selector(refreshPackages) forControlEvents:UIControlEventValueChanged];
    _tableView.refreshControl = _refreshControl;
    
    [self.view addSubview:_tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)setupSearchBar {
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.barTintColor = [SileoColors background];
    _searchBar.backgroundColor = [SileoColors background];
    _searchBar.tintColor = [SileoColors sileoBlue];
    
    if (@available(iOS 13.0, *)) {
        UITextField *searchTextField = [_searchBar valueForKey:@"searchField"];
        if (searchTextField) {
            searchTextField.backgroundColor = [SileoColors secondaryBackground];
            searchTextField.textColor = [SileoColors primaryText];
            searchTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search packages" attributes:@{NSForegroundColorAttributeName: [SileoColors tertiaryText]}];
        }
    }
    
    _tableView.tableHeaderView = _searchBar;
}

- (void)configureNavigationBar {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [SileoColors background];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors primaryText]};
        appearance.largeTitleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors primaryText]};
        
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
        self.navigationController.navigationBar.compactAppearance = appearance;
    } else {
        self.navigationController.navigationBar.barTintColor = [SileoColors background];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors primaryText]};
    }
    
    self.navigationController.navigationBar.tintColor = [SileoColors sileoBlue];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)loadPackages {
    // Load packages from PackageManager
    PackageManager *manager = [PackageManager sharedManager];
    
    // Try to load from Documents/Packages directory
    NSString *packagesDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    packagesDir = [packagesDir stringByAppendingPathComponent:@"Packages"];
    
    NSError *error = nil;
    NSArray *loadedPackages = [manager loadPackagesFromDirectory:packagesDir error:&error];
    
    if (loadedPackages.count > 0) {
        self.packages = loadedPackages;
        self.filteredPackages = self.packages;
        [_tableView reloadData];
    } else {
        // Load sample packages if no .plumbum files found
        [self loadSamplePackages];
    }
}

- (void)loadSamplePackages {
    NSArray *packageData = @[
        @{
            @"Package": @"com.example.springtoolz",
            @"Name": @"SpringToolz",
            @"Description": @"Powerful SpringBoard customization with many features",
            @"Version": @"2.1.0",
            @"Author": @"CoolDev",
            @"Section": @"Tweaks"
        },
        @{
            @"Package": @"com.example.noctis12",
            @"Name": @"Noctis12",
            @"Description": @"Beautiful dark mode for iOS",
            @"Version": @"3.0.1",
            @"Author": @"Guilherme Rambo",
            @"Section": @"Themes"
        },
        @{
            @"Package": @"com.example.cercube",
            @"Name": @"Cercube",
            @"Description": @"YouTube enhancement tweak",
            @"Version": @"5.0.0",
            @"Author": @"iCraze",
            @"Section": @"Tweaks"
        },
        @{
            @"Package": @"com.example.filza",
            @"Name": @"Filza",
            @"Description": @"File manager for iOS",
            @"Version": @"4.0.0",
            @"Author": @"Tig0",
            @"Section": @"Utilities"
        },
        @{
            @"Package": @"com.example.safaripuls",
            @"Name": @"Safari Plus",
            @"Description": @"Enhance Safari with new features",
            @"Version": @"1.5.0",
            @"Author": @"CP Digital Darkroom",
            @"Section": @"Tweaks"
        }
    ];
    
    NSMutableArray *packages = [NSMutableArray array];
    for (NSDictionary *dict in packageData) {
        PlumbumPackage *package = [[PlumbumPackage alloc] initWithDictionary:dict];
        
        // Check if installed
        PackageManager *manager = [PackageManager sharedManager];
        PlumbumPackage *installed = [manager packageWithID:package.packageID];
        if (installed) {
            package.installStatus = PackageInstallStatusInstalled;
            package.installedVersion = installed.installedVersion;
        }
        
        [packages addObject:package];
    }
    
    self.packages = [packages copy];
    self.filteredPackages = self.packages;
    
    [_tableView reloadData];
}

- (void)refreshPackages {
    [self loadPackages];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_refreshControl endRefreshing];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredPackages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PackageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PackageCell" forIndexPath:indexPath];
    PlumbumPackage *package = self.filteredPackages[indexPath.row];
    [cell configureWithPackage:package];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlumbumPackage *package = self.filteredPackages[indexPath.row];
    PackageDetailViewController *detailVC = [[PackageDetailViewController alloc] initWithPackage:package];
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.filteredPackages = self.packages;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR description CONTAINS[cd] %@", searchText, searchText];
        self.filteredPackages = [self.packages filteredArrayUsingPredicate:predicate];
    }
    [_tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end

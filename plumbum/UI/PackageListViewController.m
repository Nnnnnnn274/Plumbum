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
#import "../kexploit/kexploit_opa334.h"

@import UniformTypeIdentifiers;

@interface PackageListViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSArray<PlumbumPackage *> *filteredPackages;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL exploitRunning;
@property (nonatomic, assign) BOOL isLoadingPackages;
@property (nonatomic, strong) RepositoryManager *repoManager;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UILabel *loadingLabel;
@end

@implementation PackageListViewController

- (instancetype)initWithRepository:(Repository *)repository {
    self = [super init];
    if (self) {
        _repository = repository;
        _repoManager = [RepositoryManager sharedManager];
    }
    return self;
}

- (instancetype)init {
    return [self initWithRepository:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [SileoColors background];
    self.title = _repository ? _repository.name : @"Packages";
    _exploitRunning = NO;
    _isLoadingPackages = NO;
    
    [self setupTableView];
    [self setupSearchBar];
    [self setupLoadingView];
    
    // Don't load packages in viewDidLoad - wait for viewDidAppear to ensure exploit has run
    
    // Configure navigation bar
    [self configureNavigationBar];
    
    // Listen for package updates from repositories
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packagesUpdated:) name:@"PackagesUpdated" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Load packages when view appears (after exploit has completed)
    [self loadPackages];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)packagesUpdated:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self && self.tableView) {
            [self loadPackages];
            
            // Show alert if packages were loaded
            if (self.packages.count > 0) {
                NSLog(@"Loaded %ld packages from repositories", (long)self.packages.count);
            }
        }
    });
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

- (void)setupLoadingView {
    // Loading indicator
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    _loadingIndicator.color = [SileoColors sileoBlue];
    _loadingIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    _loadingIndicator.hidesWhenStopped = YES;
    [self.view addSubview:_loadingIndicator];
    
    // Loading label
    _loadingLabel = [[UILabel alloc] init];
    _loadingLabel.text = @"Loading packages...";
    _loadingLabel.textColor = [SileoColors primaryText];
    _loadingLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    _loadingLabel.textAlignment = NSTextAlignmentCenter;
    _loadingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _loadingLabel.hidden = YES;
    [self.view addSubview:_loadingLabel];
    
    // Layout
    [NSLayoutConstraint activateConstraints:@[
        [_loadingIndicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [_loadingIndicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        
        [_loadingLabel.topAnchor constraintEqualToAnchor:_loadingIndicator.bottomAnchor constant:20],
        [_loadingLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
    ]];
}

- (void)configureNavigationBar {
    UIBarButtonItem *runExploitButton = [[UIBarButtonItem alloc] initWithTitle:@"Run Exploit" style:UIBarButtonItemStylePlain target:self action:@selector(runExploit)];
    self.navigationItem.rightBarButtonItem = runExploitButton;
    
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
    // Prevent multiple simultaneous loads to avoid overload
    if (_isLoadingPackages) {
        return;
    }
    _isLoadingPackages = YES;
    
    // Show loading indicator on main thread first
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showLoadingView];
        
        // Then do the actual loading on background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (self->_repository) {
                // Load packages from specific repository
                NSError *error = nil;
                NSArray *repoPackages = [self->_repoManager packagesFromRepository:self->_repository error:&error];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.isLoadingPackages = NO;
                    [self hideLoadingView];
                    if (repoPackages) {
                        self.packages = repoPackages;
                        self.filteredPackages = self.packages;
                        [self.tableView reloadData];
                    } else {
                        [self showErrorAlert:error];
                    }
                });
            } else {
                // Load all packages from all repositories
                NSError *error = nil;
                NSArray *allPackages = [self->_repoManager allPackagesFromRepositories:&error];
                
                NSMutableArray *packages = [NSMutableArray array];
                if (allPackages && allPackages.count > 0) {
                    [packages addObjectsFromArray:allPackages];
                }
                
                // Also load packages from local Packages directory
                NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
                NSString *packagesDir = [documentsDir stringByAppendingPathComponent:@"Packages"];
                
                PackageManager *pm = [PackageManager sharedManager];
                NSArray *localPackages = [pm loadPackagesFromDirectory:packagesDir error:nil];
                if (localPackages && localPackages.count > 0) {
                    [packages addObjectsFromArray:localPackages];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.isLoadingPackages = NO;
                    [self hideLoadingView];
                    if (packages.count > 0) {
                        self.packages = [packages copy];
                        self.filteredPackages = self.packages;
                        [self.tableView reloadData];
                    } else {
                        // No packages found - show empty state instead of sample packages
                        self.packages = @[];
                        self.filteredPackages = @[];
                        [self.tableView reloadData];
                    }
                });
            }
        });
    });
}

- (void)showLoadingView {
    [self.loadingIndicator startAnimating];
    self.loadingLabel.hidden = NO;
    self.tableView.hidden = YES;
}

- (void)hideLoadingView {
    [self.loadingIndicator stopAnimating];
    self.loadingLabel.hidden = YES;
    self.tableView.hidden = NO;
}

- (void)refreshPackages {
    [self loadPackages];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_refreshControl endRefreshing];
    });
}

- (void)runExploit {
    if (_exploitRunning) {
        return;
    }
    _exploitRunning = YES;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Running Exploit"
                                                                   message:@"Please wait while the exploit runs..."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [self presentViewController:alert animated:YES completion:^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            kexploit_opa334();
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissViewControllerAnimated:YES completion:^{
                    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPackage)];
                    self.navigationItem.rightBarButtonItem = addButton;
                    
                    UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Exploit Successful"
                                                                                          message:@"You can now add packages"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                    [successAlert addAction:action];
                    [self presentViewController:successAlert animated:YES completion:nil];
                }];
            });
        });
    }];
}

- (void)addPackage {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Package"
                                                                   message:@"Select package type"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *plumbumAction = [UIAlertAction actionWithTitle:@"Add .plumbum file" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showFilePickerForType:@"plumbum"];
    }];
    
    UIAlertAction *misakaAction = [UIAlertAction actionWithTitle:@"Add .misaka file" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showFilePickerForType:@"misaka"];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:plumbumAction];
    [alert addAction:misakaAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showFilePickerForType:(NSString *)type {
    if (@available(iOS 14.0, *)) {
        UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[[UTType typeWithFilenameExtension:type]]];
        picker.delegate = self;
        picker.allowsMultipleSelection = NO;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not Supported"
                                                                       message:@"File picker requires iOS 14.0 or later"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSURL *url = urls.firstObject;
    if (!url) return;
    
    // Start accessing security-scoped resource
    [url startAccessingSecurityScopedResource];
    
    NSError *error = nil;
    
    // Copy to Documents/Packages directory
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *packagesDir = [documentsDir stringByAppendingPathComponent:@"Packages"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:packagesDir]) {
        [fm createDirectoryAtPath:packagesDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *destinationPath = [packagesDir stringByAppendingPathComponent:url.lastPathComponent];
    
    if ([fm fileExistsAtPath:destinationPath]) {
        [fm removeItemAtPath:destinationPath error:nil];
    }
    
    [fm copyItemAtPath:url.path toPath:destinationPath error:&error];
    
    [url stopAccessingSecurityScopedResource];
    
    if (error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:error.localizedDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        // Reload packages
        [self loadPackages];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                       message:@"Package added successfully"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
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

- (void)showErrorAlert:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

@end


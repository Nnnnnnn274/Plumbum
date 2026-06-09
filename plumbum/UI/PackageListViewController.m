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
@property (nonatomic, strong) RepositoryManager *repoManager;
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
    
    [self setupTableView];
    [self setupSearchBar];
    
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
    if (_repository) {
        // Load packages from specific repository
        NSError *error = nil;
        NSArray *repoPackages = [_repoManager packagesFromRepository:_repository error:&error];
        
        if (repoPackages) {
            self.packages = repoPackages;
            self.filteredPackages = self.packages;
            [_tableView reloadData];
        } else {
            [self showErrorAlert:error];
        }
    } else {
        // Load all packages from all repositories
        NSError *error = nil;
        NSArray *allPackages = [_repoManager allPackagesFromRepositories:&error];
        
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
        
        if (packages.count > 0) {
            self.packages = [packages copy];
            self.filteredPackages = self.packages;
            [_tableView reloadData];
        } else {
            // Load sample packages if no packages found
            [self loadSamplePackages];
        }
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
            @"Section": @"Apps"
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
            @"Section": @"Apps"
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


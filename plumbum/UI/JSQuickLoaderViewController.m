//
//  JSQuickLoaderViewController.m
//  plumbum
//
//

#import "JSQuickLoaderViewController.h"
#import "SileoColors.h"
#import "../JSExecutor/JSExecutor.h"
#import "../PackageManager/JSRepository.h"
#import "../PackageManager/JSBuiltInTweaks.h"

@interface JSQuickLoaderViewController () <UITableViewDataSource, UITableViewDelegate, UIDocumentPickerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *availableScripts;
@property (nonatomic, strong) NSArray<JSBuiltInTweak *> *builtInTweaks;
@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) UIButton *addRepoButton;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, assign) BOOL exploitRun;
@property (nonatomic, assign) BOOL showingBuiltIn;
@end

@implementation JSQuickLoaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SileoColors background];
    self.title = @"JS QuickLoader";
    _availableScripts = [NSMutableArray array];
    _builtInTweaks = [[JSBuiltInTweaks sharedTweaks] allTweaks];
    _showingBuiltIn = YES;
    
    [self setupViews];
    [self configureNavigationBar];
    [self loadScripts];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(exploitCompleted:)
                                                 name:@"ExploitCompleted"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)exploitCompleted:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_exploitRun = YES;
        self->_loadButton.enabled = YES;
        self->_loadButton.alpha = 1.0;
    });
}

- (void)setupViews {
    CGFloat pad = 20.0;
    
    // Segmented control for switching between Built-in and Repo scripts
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Built-in Tweaks", @"Repo Scripts"]];
    _segmentedControl.selectedSegmentIndex = 0;
    [_segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_segmentedControl];
    
    // Add repo button (only shown for repo scripts)
    _addRepoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_addRepoButton setTitle:@"Add JS Repository" forState:UIControlStateNormal];
    _addRepoButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    _addRepoButton.layer.cornerRadius = 14;
    _addRepoButton.layer.masksToBounds = YES;
    _addRepoButton.backgroundColor = [SileoColors sileoBlue];
    [_addRepoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_addRepoButton addTarget:self action:@selector(addRepository) forControlEvents:UIControlEventTouchUpInside];
    _addRepoButton.translatesAutoresizingMaskIntoConstraints = NO;
    _addRepoButton.hidden = YES;
    [self.view addSubview:_addRepoButton];
    
    // Load button
    _loadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_loadButton setTitle:@"Load Selected Script" forState:UIControlStateNormal];
    _loadButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    _loadButton.layer.cornerRadius = 14;
    _loadButton.layer.masksToBounds = YES;
    _loadButton.backgroundColor = [SileoColors sileoGreen];
    [_loadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_loadButton addTarget:self action:@selector(loadSelectedScript) forControlEvents:UIControlEventTouchUpInside];
    _loadButton.translatesAutoresizingMaskIntoConstraints = NO;
    _loadButton.enabled = NO;
    _loadButton.alpha = 0.5;
    [self.view addSubview:_loadButton];
    
    // Table view
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [SileoColors background];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ScriptCell"];
    [self.view addSubview:_tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [_segmentedControl.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [_segmentedControl.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:pad],
        [_segmentedControl.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-pad],
        [_segmentedControl.heightAnchor constraintEqualToConstant:32],
        
        [_addRepoButton.topAnchor constraintEqualToAnchor:_segmentedControl.bottomAnchor constant:8],
        [_addRepoButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:pad],
        [_addRepoButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-pad],
        [_addRepoButton.heightAnchor constraintEqualToConstant:50],
        
        [_loadButton.topAnchor constraintEqualToAnchor:_addRepoButton.bottomAnchor constant:8],
        [_loadButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:pad],
        [_loadButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-pad],
        [_loadButton.heightAnchor constraintEqualToConstant:50],
        
        [_tableView.topAnchor constraintEqualToAnchor:_loadButton.bottomAnchor constant:8],
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

- (void)segmentChanged:(UISegmentedControl *)sender {
    _showingBuiltIn = (sender.selectedSegmentIndex == 0);
    _addRepoButton.hidden = _showingBuiltIn;
    
    if (_showingBuiltIn) {
        _loadButton.enabled = _exploitRun;
        _loadButton.alpha = _exploitRun ? 1.0 : 0.5;
    } else {
        _loadButton.enabled = NO;
        _loadButton.alpha = 0.5;
    }
    
    [_tableView reloadData];
}

- (void)loadScripts {
    [[JSRepositoryManager sharedManager] allScriptsFromRepositories:^(NSArray<NSDictionary *> *scripts, NSError *error) {
        if (scripts) {
            self->_availableScripts = [scripts mutableCopy];
            [self->_tableView reloadData];
        }
    }];
}

- (void)addRepository {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add JS Repository"
                                                                   message:@"Enter repository URL"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"https://example.com/scripts.json";
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *url = alert.textFields.firstObject.text;
        if (url.length > 0) {
            JSRepository *repo = [[JSRepository alloc] init];
            repo.name = @"Custom Repository";
            repo.url = url;
            repo.repoDescription = @"User-added repository";
            
            NSError *error = nil;
            if ([[JSRepositoryManager sharedManager] addRepository:repo error:&error]) {
                [self loadScripts];
            } else {
                [self showAlert:@"Error" message:error.localizedDescription ?: @"Failed to add repository"];
            }
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadSelectedScript {
    NSIndexPath *selectedRow = [_tableView indexPathForSelectedRow];
    if (!selectedRow) {
        [self showAlert:@"Error" message:@"Please select a script first"];
        return;
    }
    
    if (!_exploitRun) {
        [self showAlert:@"Error" message:@"Please run the exploit first"];
        return;
    }
    
    if (_showingBuiltIn) {
        // Execute built-in tweak
        JSBuiltInTweak *tweak = _builtInTweaks[selectedRow.row];
        NSString *scriptContent = [[JSBuiltInTweaks sharedTweaks] scriptContentForTweak:tweak];
        
        if (!scriptContent || scriptContent.length == 0) {
            [self showAlert:@"Error" message:@"Failed to load built-in tweak script"];
            return;
        }
        
        NSError *execError = nil;
        if ([[JSExecutor sharedExecutor] executeJavaScriptFromString:scriptContent error:&execError]) {
            [self showAlert:@"Success" message:[NSString stringWithFormat:@"%@ executed successfully", tweak.name]];
        } else {
            [self showAlert:@"Error" message:execError.localizedDescription ?: @"Failed to execute tweak"];
        }
    } else {
        // Execute repo script
        NSDictionary *script = _availableScripts[selectedRow.row];
        NSString *scriptURL = script[@"url"];
        
        if (!scriptURL || scriptURL.length == 0) {
            [self showAlert:@"Error" message:@"Script URL is missing"];
            return;
        }
        
        // Download and execute the script
        NSURL *url = [NSURL URLWithString:scriptURL];
        if (!url) {
            [self showAlert:@"Error" message:@"Invalid script URL"];
            return;
        }
        
        UIAlertController *loadingAlert = [UIAlertController alertControllerWithTitle:@"Loading"
                                                                             message:@"Downloading and executing script..."
                                                                      preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:loadingAlert animated:YES completion:nil];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [loadingAlert dismissViewControllerAnimated:YES completion:nil];
                
                if (error || !data) {
                    [self showAlert:@"Error" message:@"Failed to download script"];
                    return;
                }
                
                // Save to temp file and execute
                NSString *tempDir = NSTemporaryDirectory();
                NSString *tempPath = [tempDir stringByAppendingPathComponent:@"script.js"];
                [data writeToFile:tempPath atomically:YES];
                
                NSError *execError = nil;
                if ([[JSExecutor sharedExecutor] executeJavaScriptFromFile:tempPath error:&execError]) {
                    [self showAlert:@"Success" message:@"Script executed successfully"];
                } else {
                    [self showAlert:@"Error" message:execError.localizedDescription ?: @"Failed to execute script"];
                }
            });
        }];
        
        [task resume];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_showingBuiltIn) {
        // Group built-in tweaks by category
        NSSet *categories = [NSSet setWithArray:[_builtInTweaks valueForKey:@"category"]];
        return categories.count;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (_showingBuiltIn) {
        NSSet *categories = [NSSet setWithArray:[_builtInTweaks valueForKey:@"category"]];
        NSArray *sortedCategories = [categories sortedArrayUsingSelector:@selector(compare:)];
        return sortedCategories[section];
    }
    return @"Repository Scripts";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_showingBuiltIn) {
        NSSet *categories = [NSSet setWithArray:[_builtInTweaks valueForKey:@"category"]];
        NSArray *sortedCategories = [categories sortedArrayUsingSelector:@selector(compare:)];
        NSString *category = sortedCategories[section];
        return [[_builtInTweaks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category == %@", category]] count];
    }
    return _availableScripts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScriptCell" forIndexPath:indexPath];
    
    if (_showingBuiltIn) {
        NSSet *categories = [NSSet setWithArray:[_builtInTweaks valueForKey:@"category"]];
        NSArray *sortedCategories = [categories sortedArrayUsingSelector:@selector(compare:)];
        NSString *category = sortedCategories[indexPath.section];
        NSArray *tweaksInCategory = [_builtInTweaks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category == %@", category]];
        JSBuiltInTweak *tweak = tweaksInCategory[indexPath.row];
        
        cell.textLabel.text = tweak.name;
        cell.detailTextLabel.text = tweak.description;
        
        // Add badges for beta/experimental
        NSString *badge = @"";
        if (tweak.isExperimental) {
            badge = @"⚠︎ Experimental";
        } else if (tweak.isBeta) {
            badge = @"β Beta";
        }
        
        if (badge.length > 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@ [%@]", tweak.name, badge];
        }
    } else {
        NSDictionary *script = _availableScripts[indexPath.row];
        cell.textLabel.text = script[@"name"] ?: script[@"id"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ by %@", script[@"description"] ?: @"", script[@"author"] ?: @"Unknown"];
    }
    
    cell.backgroundColor = [SileoColors secondaryBackground];
    cell.textLabel.textColor = [SileoColors primaryText];
    cell.detailTextLabel.textColor = [SileoColors secondaryText];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    _loadButton.enabled = YES;
    _loadButton.alpha = 1.0;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.indexPathsForSelectedRows.count == 0) {
        _loadButton.enabled = NO;
        _loadButton.alpha = 0.5;
    }
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

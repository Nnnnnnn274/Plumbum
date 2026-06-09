//
//  TweaksViewController.m
//  plumbum
//
//  Created by seo on 6/9/26.
//

#import "TweaksViewController.h"
#import "SileoColors.h"
#import "PackageManager.h"
#import "MisakaPackage.h"

@interface TweaksViewController () <UIDocumentPickerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *installedTweaks;
@property (nonatomic, strong) UIButton *addTweakButton;
@property (nonatomic, strong) UILabel *noExploitLabel;
@property (nonatomic, assign) BOOL exploitRun;
@end

@implementation TweaksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Tweaks";
    
    [self setupViews];
    [self configureNavigationBar];
    [self loadInstalledTweaks];
    
    // Listen for exploit completion
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exploitCompleted:) name:@"ExploitCompleted" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)exploitCompleted:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        _exploitRun = YES;
        [self updateAddTweakButtonVisibility];
    });
}

- (void)setupViews {
    // Add tweak button
    _addTweakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_addTweakButton setTitle:@"Add Tweak" forState:UIControlStateNormal];
    _addTweakButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    _addTweakButton.layer.cornerRadius = 12;
    _addTweakButton.backgroundColor = [SileoColors sileoBlue];
    [_addTweakButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_addTweakButton addTarget:self action:@selector(addTweak) forControlEvents:UIControlEventTouchUpInside];
    _addTweakButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_addTweakButton];
    
    // Table view
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [SileoColors background];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [_addTweakButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [_addTweakButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [_addTweakButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [_addTweakButton.heightAnchor constraintEqualToConstant:50],
        
        [_tableView.topAnchor constraintEqualToAnchor:_addTweakButton.bottomAnchor constant:20],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)configureNavigationBar {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [SileoColors background];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors primaryText]};
        
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        self.navigationController.navigationBar.barTintColor = [SileoColors background];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors primaryText]};
    }
    
    self.navigationController.navigationBar.tintColor = [SileoColors sileoBlue];
}

- (void)loadInstalledTweaks {
    _installedTweaks = [NSMutableArray array];
    // Load installed tweaks from PackageManager
    // This will be populated later with built-in tweaks
    [_tableView reloadData];
}

- (void)updateAddTweakButtonVisibility {
    BOOL exploitRun = [[NSUserDefaults standardUserDefaults] boolForKey:@"ExploitRun"];
    
    if (exploitRun) {
        _addTweakButton.hidden = NO;
        _noExploitLabel.hidden = YES;
    } else {
        _addTweakButton.hidden = YES;
        _noExploitLabel.hidden = NO;
    }
}

- (void)addTweak {
    NSArray *documentTypes = @[@"public.data"];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) return;
    
    NSURL *url = urls.firstObject;
    NSString *extension = url.pathExtension.lowercaseString;
    
    if ([extension isEqualToString:@"misaka"] || [extension isEqualToString:@"plumbum"]) {
        [self importTweakFromURL:url];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid File"
                                                                       message:@"Please select a .misaka or .plumbum file"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    // User cancelled, do nothing
}

- (void)importTweakFromURL:(NSURL *)url {
    // Start accessing security-scoped resource
    BOOL accessing = [url startAccessingSecurityScopedResource];
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    
    if (accessing) {
        [url stopAccessingSecurityScopedResource];
    }
    
    if (error || !data) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Import Failed"
                                                                       message:@"Failed to read the tweak file"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    // Copy file to app documents directory
    NSString *fileName = url.lastPathComponent;
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *destinationPath = [documentsPath stringByAppendingPathComponent:fileName];
    
    if ([data writeToFile:destinationPath options:NSDataWritingAtomic error:&error]) {
        // Add to installed tweaks
        NSDictionary *tweakInfo = @{
            @"name": [fileName stringByDeletingPathExtension],
            @"path": destinationPath,
            @"type": url.pathExtension.lowercaseString
        };
        [_installedTweaks addObject:tweakInfo];
        [_tableView reloadData];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Import Successful"
                                                                       message:@"Tweak has been imported successfully"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Import Failed"
                                                                       message:@"Failed to save the tweak file"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _installedTweaks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TweakCell"];
    cell.backgroundColor = [SileoColors cellBackgroundColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *tweak = _installedTweaks[indexPath.row];
    cell.textLabel.text = tweak[@"name"];
    cell.textLabel.textColor = [SileoColors primaryText];
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    
    // Add install button
    UIButton *installButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [installButton setTitle:@"Install" forState:UIControlStateNormal];
    installButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    installButton.layer.cornerRadius = 8;
    installButton.backgroundColor = [SileoColors sileoBlue];
    [installButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    installButton.tag = indexPath.row;
    [installButton addTarget:self action:@selector(installTweak:) forControlEvents:UIControlEventTouchUpInside];
    installButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:installButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [installButton.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
        [installButton.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],
        [installButton.widthAnchor constraintEqualToConstant:80],
        [installButton.heightAnchor constraintEqualToConstant:32]
    ]];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)installTweak:(UIButton *)sender {
    NSInteger index = sender.tag;
    NSDictionary *tweak = _installedTweaks[index];
    NSString *tweakPath = tweak[@"path"];
    
    // Install the tweak
    NSError *error = nil;
    PackageManager *packageManager = [[PackageManager alloc] init];
    
    if ([tweak[@"type"] isEqualToString:@"misaka"]) {
        MisakaPackageManager *misakaManager = [[MisakaPackageManager alloc] init];
        BOOL success = [misakaManager installMisakaPackage:tweakPath error:&error];
        
        if (success) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                           message:@"Tweak installed successfully"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Installation Failed"
                                                                           message:error.localizedDescription
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else {
        // Install .plumbum file
        PlumbumPackage *package = [packageManager loadPackageFromPath:tweakPath error:&error];
        if (package) {
            BOOL success = [packageManager installPackage:package error:&error];
            
            if (success) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                               message:@"Tweak installed successfully"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Installation Failed"
                                                                               message:error.localizedDescription
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                [self presentViewController:alert animated:YES completion:nil];
            }
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Installation Failed"
                                                                           message:@"Failed to load package"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

@end

//
//  TweaksViewController.m
//  plumbum
//

#import "TweaksViewController.h"
#import "SileoColors.h"
#import "PackageManager.h"
#import "MisakaPackage.h"

static NSString * const kTweakCellID = @"TweakCell";

@interface TweakCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) UIButton *installButton;
@end

@implementation TweakCell {
    UIView *_cardView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = [SileoColors secondaryBackground];
        _cardView.layer.cornerRadius = 14;
        _cardView.layer.borderWidth = 0.5;
        _cardView.layer.borderColor = [SileoColors borderColor].CGColor;
        _cardView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_cardView];

        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"puzzlepiece.extension.fill"]];
        icon.tintColor = [SileoColors sileoBlue];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        icon.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:icon];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        _nameLabel.textColor = [SileoColors primaryText];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:_nameLabel];

        _typeLabel = [[UILabel alloc] init];
        _typeLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
        _typeLabel.textColor = [SileoColors tertiaryText];
        _typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:_typeLabel];

        _installButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_installButton setTitle:@"Install" forState:UIControlStateNormal];
        _installButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
        _installButton.layer.cornerRadius = 8;
        _installButton.layer.masksToBounds = YES;
        [_installButton setTitleColor:[SileoColors sileoBlue] forState:UIControlStateNormal];
        _installButton.backgroundColor = [[SileoColors sileoBlue] colorWithAlphaComponent:0.1];
        _installButton.layer.borderWidth = 0.5;
        _installButton.layer.borderColor = [[SileoColors sileoBlue] colorWithAlphaComponent:0.3].CGColor;
        _installButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:_installButton];

        [NSLayoutConstraint activateConstraints:@[
            [_cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:4],
            [_cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-4],
            [_cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12],
            [_cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12],

            [icon.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:14],
            [icon.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor],
            [icon.widthAnchor constraintEqualToConstant:24],
            [icon.heightAnchor constraintEqualToConstant:24],

            [_nameLabel.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:12],
            [_nameLabel.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:14],
            [_nameLabel.trailingAnchor constraintEqualToAnchor:_installButton.leadingAnchor constant:-12],

            [_typeLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
            [_typeLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:3],
            [_typeLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-14],

            [_installButton.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-12],
            [_installButton.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor],
            [_installButton.widthAnchor constraintEqualToConstant:74],
            [_installButton.heightAnchor constraintEqualToConstant:30],
        ]];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [UIView animateWithDuration:0.1 animations:^{
        self->_cardView.alpha = highlighted ? 0.6 : 1.0;
    }];
}

@end

// ─────────────────────────────────────────────

@interface TweaksViewController () <UIDocumentPickerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *installedTweaks;
@property (nonatomic, strong) UIButton *addTweakButton;
@property (nonatomic, assign) BOOL exploitRun;
@end

@implementation TweaksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Tweaks";
    _installedTweaks = [NSMutableArray array];

    [self setupViews];
    [self configureNavigationBar];
    [self loadInstalledTweaks];

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
        self->_addTweakButton.hidden = NO;
    });
}

- (void)setupViews {
    // Add tweak button (hidden until exploit runs)
    _addTweakButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_addTweakButton setTitle:@"Add Tweak" forState:UIControlStateNormal];
    _addTweakButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    _addTweakButton.layer.cornerRadius = 14;
    _addTweakButton.layer.masksToBounds = YES;
    _addTweakButton.backgroundColor = [SileoColors sileoBlue];
    [_addTweakButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_addTweakButton addTarget:self action:@selector(addTweak) forControlEvents:UIControlEventTouchUpInside];
    _addTweakButton.translatesAutoresizingMaskIntoConstraints = NO;
    _addTweakButton.hidden = ![[NSUserDefaults standardUserDefaults] boolForKey:@"ExploitRun"];
    [self.view addSubview:_addTweakButton];

    // Table view
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [SileoColors background];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 16, 0);
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[TweakCell class] forCellReuseIdentifier:kTweakCellID];
    [self.view addSubview:_tableView];

    [NSLayoutConstraint activateConstraints:@[
        [_addTweakButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [_addTweakButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:12],
        [_addTweakButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-12],
        [_addTweakButton.heightAnchor constraintEqualToConstant:50],

        [_tableView.topAnchor constraintEqualToAnchor:_addTweakButton.bottomAnchor constant:8],
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

- (void)loadInstalledTweaks {
    [_tableView reloadData];
}

- (void)addTweak {
    NSArray *documentTypes = @[@"public.data"];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc]
        initWithDocumentTypes:documentTypes
                       inMode:UIDocumentPickerModeImport];
    picker.delegate = self;
    picker.allowsMultipleSelection = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count == 0) return;
    NSURL *url = urls.firstObject;
    NSString *ext = url.pathExtension.lowercaseString;

    if (![ext isEqualToString:@"misaka"] && ![ext isEqualToString:@"plumbum"]) {
        [self showAlert:@"Invalid File" message:@"Please select a .misaka or .plumbum file"];
        return;
    }
    [self importTweakFromURL:url];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {}

- (void)importTweakFromURL:(NSURL *)url {
    BOOL accessing = [url startAccessingSecurityScopedResource];
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
    if (accessing) [url stopAccessingSecurityScopedResource];

    if (error || !data) {
        [self showAlert:@"Import Failed" message:@"Could not read the tweak file"];
        return;
    }

    NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dest = [docs stringByAppendingPathComponent:url.lastPathComponent];
    if ([data writeToFile:dest options:NSDataWritingAtomic error:&error]) {
        NSDictionary *info = @{
            @"name": [url.lastPathComponent stringByDeletingPathExtension],
            @"path": dest,
            @"type": url.pathExtension.lowercaseString
        };
        [_installedTweaks addObject:info];
        [_tableView reloadData];
        [self showAlert:@"Imported" message:@"Tweak is ready to install"];
    } else {
        [self showAlert:@"Import Failed" message:error.localizedDescription ?: @"Unknown error"];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _installedTweaks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweakCell *cell = [tableView dequeueReusableCellWithIdentifier:kTweakCellID forIndexPath:indexPath];
    NSDictionary *tweak = _installedTweaks[indexPath.row];
    cell.nameLabel.text = tweak[@"name"];
    cell.typeLabel.text = [NSString stringWithFormat:@".%@", tweak[@"type"]];
    cell.installButton.tag = indexPath.row;
    [cell.installButton addTarget:self action:@selector(installTweak:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (void)installTweak:(UIButton *)sender {
    NSInteger idx = sender.tag;
    if (idx >= (NSInteger)_installedTweaks.count) return;
    NSDictionary *tweak = _installedTweaks[idx];

    // Check if exploit has been run
    if (!_exploitRun && ![[NSUserDefaults standardUserDefaults] boolForKey:@"ExploitRun"]) {
        [self showAlert:@"Error" message:@"Please run the exploit first before installing tweaks"];
        return;
    }

    NSError *error = nil;
    BOOL success = NO;

    if ([tweak[@"type"] isEqualToString:@"misaka"]) {
        MisakaPackageManager *mm = [[MisakaPackageManager alloc] init];
        success = [mm installMisakaPackage:tweak[@"path"] error:&error];
    } else {
        PackageManager *pm = [PackageManager sharedManager];
        [pm createDirectoriesIfNeeded];
        [pm loadInstalledPackages];
        
        PlumbumPackage *pkg = [pm loadPackageFromPath:tweak[@"path"] error:&error];
        if (pkg) {
            success = [pm installPackage:pkg error:&error];
        } else {
            success = NO;
        }
    }

    if (success) {
        [self showAlert:@"Installed" message:@"Tweak installed successfully"];
    } else {
        [self showAlert:@"Install Failed" message:error.localizedDescription ?: @"Unknown error"];
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

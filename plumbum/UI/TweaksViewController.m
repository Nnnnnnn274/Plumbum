//
//  TweaksViewController.m
//  plumbum
//

#import "TweaksViewController.h"
#import "SileoColors.h"
#import "../Tweaks/BuiltInTweaks.h"
#import "../LogTextView.h"
#import "LogsViewController.h"

static NSString * const kTweakCellID = @"TweakCell";

@interface TweakCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIButton *applyButton;
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

        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _descriptionLabel.textColor = [SileoColors secondaryText];
        _descriptionLabel.numberOfLines = 2;
        _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:_descriptionLabel];

        _applyButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_applyButton setTitle:@"Apply" forState:UIControlStateNormal];
        _applyButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
        _applyButton.layer.cornerRadius = 8;
        _applyButton.layer.masksToBounds = YES;
        [_applyButton setTitleColor:[SileoColors sileoGreen] forState:UIControlStateNormal];
        _applyButton.backgroundColor = [[SileoColors sileoGreen] colorWithAlphaComponent:0.1];
        _applyButton.layer.borderWidth = 0.5;
        _applyButton.layer.borderColor = [[SileoColors sileoGreen] colorWithAlphaComponent:0.3].CGColor;
        _applyButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:_applyButton];

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
            [_nameLabel.trailingAnchor constraintEqualToAnchor:_applyButton.leadingAnchor constant:-12],

            [_descriptionLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
            [_descriptionLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:3],
            [_descriptionLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-14],

            [_applyButton.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-12],
            [_applyButton.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor],
            [_applyButton.widthAnchor constraintEqualToConstant:74],
            [_applyButton.heightAnchor constraintEqualToConstant:30],
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

@interface TweaksViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<BuiltInTweak *> *builtInTweaks;
@property (nonatomic, assign) BOOL exploitRun;
@property (nonatomic, strong) BuiltInTweak *pendingTweak;
@end

@implementation TweaksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Tweaks";
    _builtInTweaks = [[BuiltInTweaks sharedTweaks] allTweaks];
    _exploitRun = [[NSUserDefaults standardUserDefaults] boolForKey:@"ExploitRun"];

    [self setupViews];
    [self configureNavigationBar];

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
        [self->_tableView reloadData];
    });
}

- (void)setupViews {
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
        [_tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSSet *categories = [NSSet setWithArray:[_builtInTweaks valueForKey:@"category"]];
    return categories.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSSet *categories = [NSSet setWithArray:[_builtInTweaks valueForKey:@"category"]];
    NSArray *sortedCategories = [[categories allObjects] sortedArrayUsingSelector:@selector(compare:)];
    return sortedCategories[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSSet *categories = [NSSet setWithArray:[_builtInTweaks valueForKey:@"category"]];
    NSArray *sortedCategories = [[categories allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSString *category = sortedCategories[section];
    return [[_builtInTweaks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category == %@", category]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweakCell *cell = [tableView dequeueReusableCellWithIdentifier:kTweakCellID forIndexPath:indexPath];
    
    NSSet *categories = [NSSet setWithArray:[_builtInTweaks valueForKey:@"category"]];
    NSArray *sortedCategories = [[categories allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSString *category = sortedCategories[indexPath.section];
    NSArray *tweaksInCategory = [_builtInTweaks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category == %@", category]];
    BuiltInTweak *tweak = tweaksInCategory[indexPath.row];
    
    cell.nameLabel.text = tweak.name;
    cell.descriptionLabel.text = tweak.description;
    cell.applyButton.tag = indexPath.section * 1000 + indexPath.row;
    [cell.applyButton addTarget:self action:@selector(applyTweak:) forControlEvents:UIControlEventTouchUpInside];
    
    // Disable button if exploit hasn't run
    cell.applyButton.enabled = _exploitRun;
    cell.applyButton.alpha = _exploitRun ? 1.0 : 0.5;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72;
}

- (void)applyTweak:(UIButton *)sender {
    NSInteger section = sender.tag / 1000;
    NSInteger row = sender.tag % 1000;
    
    NSSet *categories = [NSSet setWithArray:[_builtInTweaks valueForKey:@"category"]];
    NSArray *sortedCategories = [[categories allObjects] sortedArrayUsingSelector:@selector(compare:)];
    NSString *category = sortedCategories[section];
    NSArray *tweaksInCategory = [_builtInTweaks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category == %@", category]];
    
    if (row >= (NSInteger)tweaksInCategory.count) return;
    BuiltInTweak *tweak = tweaksInCategory[row];
    
    // Check if exploit has been run in this session
    if (!_exploitRun) {
        // Store the pending tweak and run exploit first
        _pendingTweak = tweak;
        LogsViewController *logsVC = [[LogsViewController alloc] initWithCompletion:^{
            // After exploit completes, continue with tweak application
            [self applyPendingTweak];
        }];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logsVC];
        [self presentViewController:nav animated:YES completion:nil];
        return;
    }
    
    // Exploit already run, apply tweak directly
    [self applyTweakWithIdentifier:tweak.identifier name:tweak.name];
}

- (void)applyPendingTweak {
    if (_pendingTweak) {
        [self applyTweakWithIdentifier:_pendingTweak.identifier name:_pendingTweak.name];
        _pendingTweak = nil;
    }
}

- (void)applyTweakWithIdentifier:(NSString *)identifier name:(NSString *)name {
    printf("[TWEAK] Applying tweak: %s (%s)\n", [name UTF8String], [identifier UTF8String]);
    
    // TODO: Implement actual tweak function calls
    // Each tweak has its own apply function, e.g.:
    // if ([identifier isEqualToString:@"statbar"]) return statbar_apply(...);
    // if ([identifier isEqualToString:@"nsbar"]) return nsbar_apply(...);
    // etc.
    
    // For now, just log success
    printf("[TWEAK] Successfully applied: %s\n", [name UTF8String]);
    
    [self showAlert:@"Success" message:[NSString stringWithFormat:@"%@ applied successfully", name]];
}

- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

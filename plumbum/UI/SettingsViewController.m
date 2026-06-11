//
//  SettingsViewController.m
//  plumbum
//

#import "SettingsViewController.h"
#import "SileoColors.h"

static NSString * const kSettingsCellID = @"SettingsCell";

@interface SettingsCell : UITableViewCell
@end

@implementation SettingsCell {
    UILabel *_titleLabel;
    UIImageView *_chevron;
    UISwitch *_toggle;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [SileoColors secondaryBackground];
        self.contentView.backgroundColor = [SileoColors secondaryBackground];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        _titleLabel.textColor = [SileoColors primaryText];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_titleLabel];

        _chevron = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
        _chevron.tintColor = [SileoColors tertiaryText];
        _chevron.contentMode = UIViewContentModeScaleAspectFit;
        _chevron.hidden = YES;
        _chevron.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_chevron];

        _toggle = [[UISwitch alloc] init];
        _toggle.onTintColor = [SileoColors sileoBlue];
        _toggle.hidden = YES;
        _toggle.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_toggle];

        [NSLayoutConstraint activateConstraints:@[
            [_titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
            [_titleLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],

            [_chevron.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_chevron.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
            [_chevron.widthAnchor constraintEqualToConstant:12],
            [_chevron.heightAnchor constraintEqualToConstant:16],

            [_toggle.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
            [_toggle.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        ]];
    }
    return self;
}

- (void)configureWithItem:(NSDictionary *)item isFirst:(BOOL)isFirst isLast:(BOOL)isLast {
    if (!item) return;
    
    _titleLabel.text = item[@"title"] ?: @"";
    _chevron.hidden = YES;
    _toggle.hidden = YES;

    NSString *type = item[@"type"];
    if ([type isEqualToString:@"navigation"]) {
        _chevron.hidden = NO;
        _titleLabel.textColor = [SileoColors primaryText];
    } else if ([type isEqualToString:@"action"]) {
        _titleLabel.textColor = [SileoColors sileoBlue];
    } else if ([type isEqualToString:@"destructive"]) {
        _titleLabel.textColor = [SileoColors errorColor];
    } else if ([type isEqualToString:@"toggle"]) {
        _toggle.hidden = NO;
        _toggle.on = [item[@"value"] boolValue];
    } else {
        // info
        _titleLabel.textColor = [SileoColors primaryText];
    }
}

@end

// ─────────────────────────────────────────────

@interface SettingsViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *settingsSections;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Settings";
    [self loadSettings];
    [self setupTableView];
    [self configureNavigationBar];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [SileoColors background];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[SettingsCell class] forCellReuseIdentifier:kSettingsCellID];

    [self.view addSubview:_tableView];
    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor],
    ]];
}

- (void)loadSettings {
    _settingsSections = @[
        @{ @"title": @"About", @"items": @[
            @{@"title": @"Version", @"value": @"1.0.0", @"type": @"info"},
            @{@"title": @"Build",   @"value": @"Release", @"type": @"info"},
            @{@"title": @"Developer", @"value": @"seo",   @"type": @"info"},
        ]},
        @{ @"title": @"Repositories", @"items": @[
            @{@"title": @"Manage Repositories", @"type": @"navigation"},
            @{@"title": @"Refresh All",          @"type": @"action"},
        ]},
        @{ @"title": @"Appearance", @"items": @[
            @{@"title": @"Dark Mode",    @"type": @"toggle", @"value": @YES},
            @{@"title": @"Accent Color", @"type": @"navigation"},
        ]},
        @{ @"title": @"Advanced", @"items": @[
            @{@"title": @"Clear Cache",    @"type": @"action"},
            @{@"title": @"Reset Settings", @"type": @"destructive"},
        ]},
    ];
}

- (void)configureNavigationBar {
    if (!self.navigationController) return;
    
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
    return _settingsSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_settingsSections[section][@"items"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:kSettingsCellID forIndexPath:indexPath];
    NSArray *items = _settingsSections[indexPath.section][@"items"];
    BOOL isFirst = indexPath.row == 0;
    BOOL isLast = indexPath.row == (NSInteger)items.count - 1;
    [cell configureWithItem:items[indexPath.row] isFirst:isFirst isLast:isLast];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

@end

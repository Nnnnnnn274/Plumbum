//
//  SettingsViewController.m
//  plumbum
//

#import "SettingsViewController.h"
#import "SileoColors.h"
#import "../PackageManager/Repository.h"

static NSString * const kSettingsCellID = @"SettingsCell";

@interface SettingsCell : UITableViewCell
@end

@implementation SettingsCell {
    UIView *_cardView;
    UILabel *_titleLabel;
    UILabel *_valueLabel;
    UIImageView *_chevron;
    UISwitch *_toggle;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = [SileoColors secondaryBackground];
        _cardView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_cardView];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        _titleLabel.textColor = [SileoColors primaryText];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:_titleLabel];

        _valueLabel = [[UILabel alloc] init];
        _valueLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        _valueLabel.textColor = [SileoColors tertiaryText];
        _valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:_valueLabel];

        _chevron = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"chevron.right"]];
        _chevron.tintColor = [SileoColors tertiaryText];
        _chevron.contentMode = UIViewContentModeScaleAspectFit;
        _chevron.hidden = YES;
        _chevron.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:_chevron];

        _toggle = [[UISwitch alloc] init];
        _toggle.onTintColor = [SileoColors sileoBlue];
        _toggle.hidden = YES;
        _toggle.translatesAutoresizingMaskIntoConstraints = NO;
        [_cardView addSubview:_toggle];

        [NSLayoutConstraint activateConstraints:@[
            [_cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [_cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor],
            [_cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [_cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],

            [_titleLabel.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:16],
            [_titleLabel.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor],

            [_valueLabel.trailingAnchor constraintEqualToAnchor:_chevron.leadingAnchor constant:-6],
            [_valueLabel.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor],

            [_chevron.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
            [_chevron.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor],
            [_chevron.widthAnchor constraintEqualToConstant:12],
            [_chevron.heightAnchor constraintEqualToConstant:16],

            [_toggle.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-16],
            [_toggle.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor],
        ]];
    }
    return self;
}

- (void)configureWithItem:(NSDictionary *)item isFirst:(BOOL)isFirst isLast:(BOOL)isLast {
    _titleLabel.text = item[@"title"];
    _valueLabel.text = item[@"value"] ?: @"";
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
        _chevron.hidden = YES;
        _valueLabel.text = item[@"value"] ?: @"";
    }

    // Rounded corners for first/last in group
    UIRectCorner corners = 0;
    if (isFirst && isLast) corners = UIRectCornerAllCorners;
    else if (isFirst) corners = UIRectCornerTopLeft | UIRectCornerTopRight;
    else if (isLast) corners = UIRectCornerBottomLeft | UIRectCornerBottomRight;

    if (corners != 0) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width - 32, 44)
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(14, 14)];
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.path = path.CGPath;
        _cardView.layer.mask = mask;
    } else {
        _cardView.layer.mask = nil;
    }
}

@end

// ─────────────────────────────────────────────

@interface SettingsViewController ()
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *settingsSections;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Settings";
    [self loadSettings];
    [self setupHeaderView];
    [self setupTableView];
    [self configureNavigationBar];
}

- (void)setupHeaderView {
    _headerView = [[UIView alloc] init];
    _headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_headerView];

    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"Settings";
    _titleLabel.numberOfLines = 2;
    _titleLabel.font = [UIFont systemFontOfSize:34 weight:UIFontWeightBold];
    _titleLabel.textColor = [SileoColors primaryText];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_headerView addSubview:_titleLabel];

    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.text = @"Configure your preferences";
    _subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _subtitleLabel.textColor = [SileoColors secondaryText];
    _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_headerView addSubview:_subtitleLabel];

    [NSLayoutConstraint activateConstraints:@[
        [_headerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [_headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [_headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [_headerView.heightAnchor constraintEqualToConstant:80],

        [_titleLabel.topAnchor constraintEqualToAnchor:_headerView.topAnchor],
        [_titleLabel.leadingAnchor constraintEqualToAnchor:_headerView.leadingAnchor],
        [_titleLabel.trailingAnchor constraintEqualToAnchor:_headerView.trailingAnchor],

        [_subtitleLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:8],
        [_subtitleLabel.leadingAnchor constraintEqualToAnchor:_headerView.leadingAnchor],
        [_subtitleLabel.trailingAnchor constraintEqualToAnchor:_headerView.trailingAnchor],
    ]];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [SileoColors background];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[SettingsCell class] forCellReuseIdentifier:kSettingsCellID];

    [self.view addSubview:_tableView];
    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:_headerView.bottomAnchor constant:20],
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, tableView.bounds.size.width - 32, 20)];
    label.text = [_settingsSections[section][@"title"] uppercaseString];
    label.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    label.textColor = [SileoColors tertiaryText];
    [header addSubview:label];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

@end

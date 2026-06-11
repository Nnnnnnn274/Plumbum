//
//  SourcesViewController.m
//  plumbum
//

#import "SourcesViewController.h"
#import "SileoColors.h"
#import "../PackageManager/Repository.h"
#import "PackageListViewController.h"

static NSString * const kSourceCellID = @"SourceCell";

// ─────────────────────────────────────────────
#pragma mark - SourceCell (private)
// ─────────────────────────────────────────────

@interface SourceCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *urlLabel;
@property (nonatomic, strong) UILabel *packageCountLabel;
@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, weak) id<NSObject> refreshTarget;
- (void)configureWithRepository:(Repository *)repo atIndex:(NSInteger)index;
@end

@implementation SourceCell {
    UIView *_cardView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    _cardView = [[UIView alloc] init];
    _cardView.backgroundColor = [SileoColors secondaryBackground];
    _cardView.layer.cornerRadius = 14;
    _cardView.layer.masksToBounds = YES;
    _cardView.layer.borderWidth = 0.5;
    _cardView.layer.borderColor = [SileoColors borderColor].CGColor;
    _cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_cardView];

    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    _iconImageView.layer.cornerRadius = 10;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.backgroundColor = [SileoColors tertiaryBackground];
    _iconImageView.layer.borderWidth = 0.5;
    _iconImageView.layer.borderColor = [SileoColors accentBorderColor].CGColor;
    _iconImageView.tintColor = [SileoColors sileoBlue];
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_cardView addSubview:_iconImageView];

    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    _nameLabel.textColor = [SileoColors primaryText];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_cardView addSubview:_nameLabel];

    _urlLabel = [[UILabel alloc] init];
    _urlLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    _urlLabel.textColor = [SileoColors tertiaryText];
    _urlLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_cardView addSubview:_urlLabel];

    _packageCountLabel = [[UILabel alloc] init];
    _packageCountLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    _packageCountLabel.textColor = [SileoColors sileoBlue];
    _packageCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_cardView addSubview:_packageCountLabel];

    _refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_refreshButton setImage:[UIImage systemImageNamed:@"arrow.clockwise"] forState:UIControlStateNormal];
    _refreshButton.tintColor = [SileoColors sileoBlue];
    _refreshButton.backgroundColor = [SileoColors tertiaryBackground];
    _refreshButton.layer.cornerRadius = 14;
    _refreshButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_cardView addSubview:_refreshButton];

    [NSLayoutConstraint activateConstraints:@[
        [_cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:4],
        [_cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-4],
        [_cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12],
        [_cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12],

        [_iconImageView.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:12],
        [_iconImageView.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor],
        [_iconImageView.widthAnchor constraintEqualToConstant:44],
        [_iconImageView.heightAnchor constraintEqualToConstant:44],

        [_nameLabel.leadingAnchor constraintEqualToAnchor:_iconImageView.trailingAnchor constant:12],
        [_nameLabel.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:12],
        [_nameLabel.trailingAnchor constraintEqualToAnchor:_refreshButton.leadingAnchor constant:-12],

        [_urlLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_urlLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:3],
        [_urlLabel.trailingAnchor constraintEqualToAnchor:_nameLabel.trailingAnchor],

        [_packageCountLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_packageCountLabel.topAnchor constraintEqualToAnchor:_urlLabel.bottomAnchor constant:3],
        [_packageCountLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-12],

        [_refreshButton.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-12],
        [_refreshButton.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor],
        [_refreshButton.widthAnchor constraintEqualToConstant:28],
        [_refreshButton.heightAnchor constraintEqualToConstant:28],
    ]];
}

- (void)configureWithRepository:(Repository *)repo atIndex:(NSInteger)index {
    _iconImageView.image = [UIImage systemImageNamed:@"globe"];
    _nameLabel.text = repo.name;
    _urlLabel.text = repo.url;
    _packageCountLabel.text = @"Loading...";
    
    // Add refresh button action
    [_refreshButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [_refreshButton addTarget:_refreshTarget action:@selector(refreshRepository:) forControlEvents:UIControlEventTouchUpInside];
    _refreshButton.tag = index;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [UIView animateWithDuration:0.1 animations:^{
        self->_cardView.alpha = highlighted ? 0.6 : 1.0;
    }];
}

@end

// ─────────────────────────────────────────────
#pragma mark - SourcesViewController
// ─────────────────────────────────────────────

@interface SourcesViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<Repository *> *repositories;
@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation SourcesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Sources";
    _repositories = [NSMutableArray array];
    [self setupViews];
    [self configureNavigationBar];
    [self loadRepositories];
}

- (void)setupViews {
    // Search bar
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    _searchBar.placeholder = @"Search repos…";
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.barTintColor = [SileoColors background];
    _searchBar.backgroundColor = [SileoColors background];
    _searchBar.tintColor = [SileoColors sileoBlue];

    if (@available(iOS 13.0, *)) {
        UITextField *tf = [_searchBar valueForKey:@"searchField"];
        if (tf) {
            tf.backgroundColor = [SileoColors tertiaryBackground];
            tf.textColor = [SileoColors primaryText];
            tf.attributedPlaceholder = [[NSAttributedString alloc]
                initWithString:@"Search repos…"
                    attributes:@{NSForegroundColorAttributeName: [SileoColors tertiaryText]}];
        }
    }

    // Table view
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [SileoColors background];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 16, 0);
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [_tableView registerClass:[SourceCell class] forCellReuseIdentifier:kSourceCellID];
    _tableView.tableHeaderView = _searchBar;

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

    // Add repo button
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                             target:self
                             action:@selector(addRepository)];
    self.navigationItem.rightBarButtonItem = addBtn;
}

- (void)loadRepositories {
    RepositoryManager *rm = [RepositoryManager sharedManager];
    _repositories = [rm.repositories mutableCopy];
    [_tableView reloadData];
    
    // Load packages for each repository
    for (Repository *repo in _repositories) {
        [self loadPackagesForRepository:repo];
    }
}

- (void)loadPackagesForRepository:(Repository *)repo {
    RepositoryManager *rm = [RepositoryManager sharedManager];
    [rm packagesFromRepository:repo completion:^(NSArray<PlumbumPackage *> *packages, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Find the cell for this repository and update the package count
            NSInteger index = [self->_repositories indexOfObject:repo];
            if (index != NSNotFound) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                SourceCell *cell = [self->_tableView cellForRowAtIndexPath:indexPath];
                if (cell) {
                    cell.packageCountLabel.text = [NSString stringWithFormat:@"%ld packages", (long)packages.count];
                }
            }
        });
    }];
}

- (void)refreshRepository:(UIButton *)sender {
    NSInteger index = sender.tag;
    if (index >= (NSInteger)_repositories.count) return;
    
    Repository *repo = _repositories[index];
    SourceCell *cell = (SourceCell *)sender.superview;
    cell.packageCountLabel.text = @"Refreshing...";
    
    [self loadPackagesForRepository:repo];
}

- (void)addRepository {
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:@"Add Source"
                         message:@"Enter the repository URL"
                  preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.placeholder = @"https://repo.example.com";
        tf.keyboardType = UIKeyboardTypeURL;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }];

    UIAlertAction *add = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *urlString = alert.textFields.firstObject.text;
        if (urlString.length > 0) {
            Repository *repo = [[Repository alloc] init];
            repo.url = urlString;
            repo.name = urlString;
            RepositoryManager *rm = [RepositoryManager sharedManager];
            NSError *error = nil;
            if ([rm addRepository:repo error:&error]) {
                [self->_repositories addObject:repo];
                [self->_tableView reloadData];
                // Load packages for the new repository
                [self loadPackagesForRepository:repo];
            }
        }
    }];

    [alert addAction:add];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _repositories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SourceCell *cell = [tableView dequeueReusableCellWithIdentifier:kSourceCellID forIndexPath:indexPath];
    cell.refreshTarget = self;
    [cell configureWithRepository:_repositories[indexPath.row] atIndex:indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 82;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Repository *repo = _repositories[indexPath.row];
    PackageListViewController *pkgVC = [[PackageListViewController alloc] initWithRepository:repo];
    [self.navigationController pushViewController:pkgVC animated:YES];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

@end

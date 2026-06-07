//
//  SourcesViewController.m
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import "SourcesViewController.h"
#import "SileoColors.h"
#import "../PackageManager/Repository.h"

@interface SourceCell : UITableViewCell
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *urlLabel;
@property (nonatomic, strong) UILabel *packageCountLabel;
@property (nonatomic, strong) UIButton *refreshButton;
- (void)configureWithRepository:(Repository *)repo;
@end

@implementation SourceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = [SileoColors cellBackgroundColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    _iconImageView.layer.cornerRadius = 10;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.backgroundColor = [SileoColors tertiaryBackground];
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_iconImageView];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    _nameLabel.textColor = [SileoColors primaryText];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_nameLabel];
    
    _urlLabel = [[UILabel alloc] init];
    _urlLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    _urlLabel.textColor = [SileoColors tertiaryText];
    _urlLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_urlLabel];
    
    _packageCountLabel = [[UILabel alloc] init];
    _packageCountLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _packageCountLabel.textColor = [SileoColors sileoBlue];
    _packageCountLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_packageCountLabel];
    
    _refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_refreshButton setImage:[UIImage systemImageNamed:@"arrow.clockwise"] forState:UIControlStateNormal];
    _refreshButton.tintColor = [SileoColors sileoBlue];
    _refreshButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_refreshButton];
    
    [NSLayoutConstraint activateConstraints:@[
        [_iconImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [_iconImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_iconImageView.widthAnchor constraintEqualToConstant:50],
        [_iconImageView.heightAnchor constraintEqualToConstant:50],
        
        [_nameLabel.leadingAnchor constraintEqualToAnchor:_iconImageView.trailingAnchor constant:12],
        [_nameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12],
        [_nameLabel.trailingAnchor constraintEqualToAnchor:_refreshButton.leadingAnchor constant:-12],
        
        [_urlLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_urlLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:4],
        [_urlLabel.trailingAnchor constraintEqualToAnchor:_nameLabel.trailingAnchor],
        
        [_packageCountLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_packageCountLabel.topAnchor constraintEqualToAnchor:_urlLabel.bottomAnchor constant:4],
        [_packageCountLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-12],
        
        [_refreshButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [_refreshButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_refreshButton.widthAnchor constraintEqualToConstant:30],
        [_refreshButton.heightAnchor constraintEqualToConstant:30]
    ]];
}

- (void)configureWithRepository:(Repository *)repo {
    _iconImageView.image = [UIImage systemImageNamed:@"globe"];
    _nameLabel.text = repo.name;
    _urlLabel.text = repo.url;
    _packageCountLabel.text = repo.repoDescription;
}

@end

@interface SourcesViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<Repository *> *repositories;
@property (nonatomic, strong) RepositoryManager *repoManager;
@end

@implementation SourcesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Sources";
    
    _repoManager = [RepositoryManager sharedManager];
    
    [self setupTableView];
    [self loadRepositories];
    [self configureNavigationBar];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [SileoColors background];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [_tableView registerClass:[SourceCell class] forCellReuseIdentifier:@"SourceCell"];
    
    [self.view addSubview:_tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [_tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)configureNavigationBar {
    self.navigationController.navigationBar.tintColor = [SileoColors sileoBlue];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSource)];
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAllSources)];
    
    self.navigationItem.rightBarButtonItems = @[addButton, refreshButton];
    
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
}
- (void)loadRepositories {
    // Add default repositories if none exist
    if (_repoManager.repositories.count == 0) {
        [_repoManager addDefaultRepositories];
    }
    
    self.repositories = _repoManager.repositories;
    [_tableView reloadData];
}

- (void)addSource {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Add Source"
                                                                   message:@"Enter repository URL"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"https://example.com/";
    }];
    
    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        NSString *url = textField.text;
        
        if (url.length > 0) {
            Repository *repo = [[Repository alloc] init];
            repo.name = @"Custom Repository";
            repo.url = url;
            repo.repoDescription = @"Custom repository";
            repo.trusted = NO;
            
            NSError *error = nil;
            if ([self.repoManager addRepository:repo error:&error]) {
                [self loadRepositories];
            } else {
                [self showErrorAlert:error];
            }
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:addAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)refreshAllSources {
    [self.repoManager refreshAllRepositories:^(BOOL success, NSError *error) {
        if (success) {
            [self loadRepositories];
        } else {
            [self showErrorAlert:error];
        }
    }];
}

- (void)showErrorAlert:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.repositories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SourceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SourceCell" forIndexPath:indexPath];
    Repository *repo = self.repositories[indexPath.row];
    [cell configureWithRepository:repo];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Repository *repo = self.repositories[indexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:repo.name
                                                                   message:repo.repoDescription
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *refreshAction = [UIAlertAction actionWithTitle:@"Refresh" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.repoManager refreshRepository:repo completion:^(BOOL success, NSError *error) {
            if (success) {
                [self loadRepositories];
            } else {
                [self showErrorAlert:error];
            }
        }];
    }];
    
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        NSError *error = nil;
        if ([self.repoManager removeRepository:repo error:&error]) {
            [self loadRepositories];
        } else {
            [self showErrorAlert:error];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:refreshAction];
    [alert addAction:removeAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end


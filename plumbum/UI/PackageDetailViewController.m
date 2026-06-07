//
//  PackageDetailViewController.m
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import "PackageDetailViewController.h"
#import "SileoColors.h"
#import "../PackageManager/PackageManager.h"

@interface PackageDetailViewController ()
@property (nonatomic, strong) PlumbumPackage *package;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UILabel *sectionLabel;
@property (nonatomic, strong) UITextView *descriptionTextView;
@property (nonatomic, strong) UIButton *installButton;
@property (nonatomic, strong) UIStackView *infoStackView;
@end

@implementation PackageDetailViewController

- (instancetype)initWithPackage:(PlumbumPackage *)package {
    self = [super init];
    if (self) {
        _package = package;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Details";
    
    [self setupScrollView];
    [self setupViews];
    [self configureNavigationBar];
    [self populateData];
}

- (void)setupScrollView {
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _scrollView.backgroundColor = [SileoColors background];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self.view addSubview:_scrollView];
    
    [NSLayoutConstraint activateConstraints:@[
        [_scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)setupViews {
    // Header container
    UIView *headerView = [[UIView alloc] init];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:headerView];
    
    // Icon
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    _iconImageView.layer.cornerRadius = 20;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.backgroundColor = [SileoColors tertiaryBackground];
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:_iconImageView];
    
    // Name
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];
    _nameLabel.textColor = [SileoColors primaryText];
    _nameLabel.numberOfLines = 0;
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:_nameLabel];
    
    // Author
    _authorLabel = [[UILabel alloc] init];
    _authorLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    _authorLabel.textColor = [SileoColors sileoBlue];
    _authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:_authorLabel];
    
    // Install button
    _installButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _installButton.layer.cornerRadius = 12;
    _installButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    _installButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_installButton addTarget:self action:@selector(installButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:_installButton];
    
    // Info stack view
    _infoStackView = [[UIStackView alloc] init];
    _infoStackView.axis = UILayoutConstraintAxisVertical;
    _infoStackView.spacing = 12;
    _infoStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_infoStackView];
    
    // Description
    UILabel *descriptionTitle = [[UILabel alloc] init];
    descriptionTitle.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    descriptionTitle.textColor = [SileoColors primaryText];
    descriptionTitle.text = @"Description";
    descriptionTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:descriptionTitle];
    
    _descriptionTextView = [[UITextView alloc] init];
    _descriptionTextView.font = [UIFont systemFontOfSize:15 weight:UIFontWeightRegular];
    _descriptionTextView.textColor = [SileoColors secondaryText];
    _descriptionTextView.backgroundColor = [SileoColors secondaryBackground];
    _descriptionTextView.layer.cornerRadius = 12;
    _descriptionTextView.editable = NO;
    _descriptionTextView.scrollEnabled = NO;
    _descriptionTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
    _descriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_descriptionTextView];
    
    // Layout constraints
    [NSLayoutConstraint activateConstraints:@[
        [headerView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor constant:20],
        [headerView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:20],
        [headerView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-20],
        
        [_iconImageView.topAnchor constraintEqualToAnchor:headerView.topAnchor],
        [_iconImageView.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor],
        [_iconImageView.widthAnchor constraintEqualToConstant:100],
        [_iconImageView.heightAnchor constraintEqualToConstant:100],
        
        [_nameLabel.topAnchor constraintEqualToAnchor:headerView.topAnchor],
        [_nameLabel.leadingAnchor constraintEqualToAnchor:_iconImageView.trailingAnchor constant:16],
        [_nameLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor],
        
        [_authorLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:8],
        [_authorLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_authorLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor],
        
        [_installButton.topAnchor constraintEqualToAnchor:_authorLabel.bottomAnchor constant:16],
        [_installButton.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_installButton.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor],
        [_installButton.heightAnchor constraintEqualToConstant:50],
        [_installButton.bottomAnchor constraintEqualToAnchor:headerView.bottomAnchor],
        
        [_infoStackView.topAnchor constraintEqualToAnchor:headerView.bottomAnchor constant:24],
        [_infoStackView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:20],
        [_infoStackView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-20],
        
        [descriptionTitle.topAnchor constraintEqualToAnchor:_infoStackView.bottomAnchor constant:24],
        [descriptionTitle.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:20],
        [descriptionTitle.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-20],
        
        [_descriptionTextView.topAnchor constraintEqualToAnchor:descriptionTitle.bottomAnchor constant:12],
        [_descriptionTextView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor constant:20],
        [_descriptionTextView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor constant:-20],
        [_descriptionTextView.bottomAnchor constraintEqualToAnchor:_scrollView.bottomAnchor constant:-20]
    ]];
    
    // Add info labels to stack view
    [self addInfoLabel:@"Version" value:_package.version];
    [self addInfoLabel:@"Section" value:_package.section];
    [self addInfoLabel:@"Package ID" value:_package.packageID];
    [self addInfoLabel:@"Architecture" value:_package.architecture];
    if (_package.dependencies.count > 0) {
        [self addInfoLabel:@"Dependencies" value:[_package.dependencies componentsJoinedByString:@", "]];
    }
}

- (void)addInfoLabel:(NSString *)title value:(NSString *)value {
    UIView *infoRow = [[UIView alloc] init];
    infoRow.backgroundColor = [SileoColors secondaryBackground];
    infoRow.layer.cornerRadius = 12;
    infoRow.translatesAutoresizingMaskIntoConstraints = NO;
    [_infoStackView addArrangedSubview:infoRow];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    titleLabel.textColor = [SileoColors tertiaryText];
    titleLabel.text = title;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [infoRow addSubview:titleLabel];
    
    UILabel *valueLabel = [[UILabel alloc] init];
    valueLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    valueLabel.textColor = [SileoColors primaryText];
    valueLabel.text = value;
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [infoRow addSubview:valueLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [infoRow.heightAnchor constraintEqualToConstant:44],
        [titleLabel.leadingAnchor constraintEqualToAnchor:infoRow.leadingAnchor constant:16],
        [titleLabel.centerYAnchor constraintEqualToAnchor:infoRow.centerYAnchor],
        [titleLabel.widthAnchor constraintEqualToConstant:100],
        [valueLabel.leadingAnchor constraintEqualToAnchor:titleLabel.trailingAnchor constant:8],
        [valueLabel.trailingAnchor constraintEqualToAnchor:infoRow.trailingAnchor constant:-16],
        [valueLabel.centerYAnchor constraintEqualToAnchor:infoRow.centerYAnchor]
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

- (void)populateData {
    _iconImageView.image = [UIImage systemImageNamed:@"app.fill"];
    _nameLabel.text = _package.name;
    _authorLabel.text = [NSString stringWithFormat:@"by %@", _package.author];
    _descriptionTextView.text = _package.packageDescription;
    
    if (_package.installStatus == PackageInstallStatusInstalled) {
        [_installButton setTitle:@"Open" forState:UIControlStateNormal];
        [_installButton setTitleColor:[SileoColors sileoGreen] forState:UIControlStateNormal];
        _installButton.backgroundColor = [[SileoColors sileoGreen] colorWithAlphaComponent:0.15];
    } else if (_package.installStatus == PackageInstallStatusUpdateAvailable) {
        [_installButton setTitle:@"Update" forState:UIControlStateNormal];
        [_installButton setTitleColor:[SileoColors warningColor] forState:UIControlStateNormal];
        _installButton.backgroundColor = [[SileoColors warningColor] colorWithAlphaComponent:0.15];
    } else {
        [_installButton setTitle:@"Get" forState:UIControlStateNormal];
        [_installButton setTitleColor:[SileoColors sileoBlue] forState:UIControlStateNormal];
        _installButton.backgroundColor = [[SileoColors sileoBlue] colorWithAlphaComponent:0.15];
    }
}

- (void)installButtonTapped {
    PackageManager *manager = [PackageManager sharedManager];
    NSError *error = nil;
    
    if (_package.installStatus == PackageInstallStatusInstalled) {
        // Open or uninstall
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:_package.name 
                                                                       message:@"What would you like to do?" 
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self openPackage];
        }];
        
        UIAlertAction *uninstallAction = [UIAlertAction actionWithTitle:@"Uninstall" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self uninstallPackage];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:openAction];
        [alert addAction:uninstallAction];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    } else if (_package.installStatus == PackageInstallStatusUpdateAvailable) {
        // Update
        BOOL success = [manager updatePackage:_package error:&error];
        if (success) {
            [self showSuccessAlert:@"Package updated successfully"];
            _package.installStatus = PackageInstallStatusInstalled;
            [self populateData];
        } else {
            [self showErrorAlert:error];
        }
    } else {
        // Install
        BOOL success = [manager installPackage:_package error:&error];
        if (success) {
            [self showSuccessAlert:@"Package installed successfully"];
            _package.installStatus = PackageInstallStatusInstalled;
            [self populateData];
        } else {
            [self showErrorAlert:error];
        }
    }
}

- (void)openPackage {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:_package.name 
                                                                   message:@"Opening application..." 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)uninstallPackage {
    PackageManager *manager = [PackageManager sharedManager];
    NSError *error = nil;
    
    BOOL success = [manager uninstallPackage:_package error:&error];
    if (success) {
        [self showSuccessAlert:@"Package uninstalled successfully"];
        _package.installStatus = PackageInstallStatusNotInstalled;
        [self populateData];
    } else {
        [self showErrorAlert:error];
    }
}

- (void)showSuccessAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" 
                                                                   message:message 
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
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

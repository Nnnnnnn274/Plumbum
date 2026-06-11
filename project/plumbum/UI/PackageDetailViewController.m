//
//  PackageDetailViewController.m
//  plumbum
//

#import "PackageDetailViewController.h"
#import "SileoColors.h"
#import "../PackageManager/PackageManager.h"

@interface PackageDetailViewController ()
@property (nonatomic, strong) PlumbumPackage *package;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UIButton *installButton;
@property (nonatomic, strong) UIStackView *infoStack;
@property (nonatomic, strong) UITextView *descriptionTextView;
@end

@implementation PackageDetailViewController

- (instancetype)initWithPackage:(PlumbumPackage *)package {
    self = [super init];
    if (self) { _package = package; }
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
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = [SileoColors background];
    _scrollView.alwaysBounceVertical = YES;
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_scrollView];

    _contentView = [[UIView alloc] init];
    _contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView addSubview:_contentView];

    [NSLayoutConstraint activateConstraints:@[
        [_scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [_contentView.topAnchor constraintEqualToAnchor:_scrollView.topAnchor],
        [_contentView.leadingAnchor constraintEqualToAnchor:_scrollView.leadingAnchor],
        [_contentView.trailingAnchor constraintEqualToAnchor:_scrollView.trailingAnchor],
        [_contentView.bottomAnchor constraintEqualToAnchor:_scrollView.bottomAnchor],
        [_contentView.widthAnchor constraintEqualToAnchor:_scrollView.widthAnchor],
    ]];
}

- (void)setupViews {
    CGFloat pad = 20;

    // Icon
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    _iconImageView.layer.cornerRadius = 20;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.backgroundColor = [SileoColors tertiaryBackground];
    _iconImageView.layer.borderWidth = 0.5;
    _iconImageView.layer.borderColor = [SileoColors accentBorderColor].CGColor;
    _iconImageView.tintColor = [SileoColors sileoBlue];
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_iconImageView];

    // Name
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightBold];
    _nameLabel.textColor = [SileoColors primaryText];
    _nameLabel.numberOfLines = 0;
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_nameLabel];

    // Author
    _authorLabel = [[UILabel alloc] init];
    _authorLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _authorLabel.textColor = [SileoColors sileoBlue];
    _authorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_authorLabel];

    // Install button
    _installButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _installButton.layer.cornerRadius = 12;
    _installButton.layer.masksToBounds = YES;
    _installButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    _installButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_installButton addTarget:self action:@selector(installButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_installButton];

    // Separator
    UIView *sep = [[UIView alloc] init];
    sep.backgroundColor = [SileoColors separatorColor];
    sep.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:sep];

    // Info stack
    _infoStack = [[UIStackView alloc] init];
    _infoStack.axis = UILayoutConstraintAxisVertical;
    _infoStack.spacing = 8;
    _infoStack.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_infoStack];

    // Description header
    UILabel *descHeader = [[UILabel alloc] init];
    descHeader.text = @"Description";
    descHeader.font = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
    descHeader.textColor = [SileoColors primaryText];
    descHeader.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:descHeader];

    // Description body
    _descriptionTextView = [[UITextView alloc] init];
    _descriptionTextView.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    _descriptionTextView.textColor = [SileoColors secondaryText];
    _descriptionTextView.backgroundColor = [SileoColors secondaryBackground];
    _descriptionTextView.layer.cornerRadius = 12;
    _descriptionTextView.layer.borderWidth = 0.5;
    _descriptionTextView.layer.borderColor = [SileoColors borderColor].CGColor;
    _descriptionTextView.editable = NO;
    _descriptionTextView.scrollEnabled = NO;
    _descriptionTextView.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12);
    _descriptionTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [_contentView addSubview:_descriptionTextView];

    [NSLayoutConstraint activateConstraints:@[
        [_iconImageView.topAnchor constraintEqualToAnchor:_contentView.topAnchor constant:pad],
        [_iconImageView.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor constant:pad],
        [_iconImageView.widthAnchor constraintEqualToConstant:88],
        [_iconImageView.heightAnchor constraintEqualToConstant:88],

        [_nameLabel.topAnchor constraintEqualToAnchor:_iconImageView.topAnchor constant:4],
        [_nameLabel.leadingAnchor constraintEqualToAnchor:_iconImageView.trailingAnchor constant:16],
        [_nameLabel.trailingAnchor constraintEqualToAnchor:_contentView.trailingAnchor constant:-pad],

        [_authorLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:4],
        [_authorLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_authorLabel.trailingAnchor constraintEqualToAnchor:_nameLabel.trailingAnchor],

        [_installButton.topAnchor constraintEqualToAnchor:_authorLabel.bottomAnchor constant:12],
        [_installButton.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_installButton.trailingAnchor constraintEqualToAnchor:_nameLabel.trailingAnchor],
        [_installButton.heightAnchor constraintEqualToConstant:44],
        [_installButton.bottomAnchor constraintLessThanOrEqualToAnchor:_iconImageView.bottomAnchor],

        [sep.topAnchor constraintEqualToAnchor:_iconImageView.bottomAnchor constant:20],
        [sep.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor constant:pad],
        [sep.trailingAnchor constraintEqualToAnchor:_contentView.trailingAnchor constant:-pad],
        [sep.heightAnchor constraintEqualToConstant:0.5],

        [_infoStack.topAnchor constraintEqualToAnchor:sep.bottomAnchor constant:16],
        [_infoStack.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor constant:pad],
        [_infoStack.trailingAnchor constraintEqualToAnchor:_contentView.trailingAnchor constant:-pad],

        [descHeader.topAnchor constraintEqualToAnchor:_infoStack.bottomAnchor constant:20],
        [descHeader.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor constant:pad],
        [descHeader.trailingAnchor constraintEqualToAnchor:_contentView.trailingAnchor constant:-pad],

        [_descriptionTextView.topAnchor constraintEqualToAnchor:descHeader.bottomAnchor constant:10],
        [_descriptionTextView.leadingAnchor constraintEqualToAnchor:_contentView.leadingAnchor constant:pad],
        [_descriptionTextView.trailingAnchor constraintEqualToAnchor:_contentView.trailingAnchor constant:-pad],
        [_descriptionTextView.bottomAnchor constraintEqualToAnchor:_contentView.bottomAnchor constant:-pad],
    ]];

    [self addInfoRow:@"Version" value:_package.version];
    [self addInfoRow:@"Section" value:_package.section];
    [self addInfoRow:@"Package ID" value:_package.packageID];
    [self addInfoRow:@"Architecture" value:_package.architecture];
    if (_package.dependencies.count > 0) {
        [self addInfoRow:@"Dependencies" value:[_package.dependencies componentsJoinedByString:@", "]];
    }
}

- (void)addInfoRow:(NSString *)title value:(NSString *)value {
    UIView *row = [[UIView alloc] init];
    row.backgroundColor = [SileoColors secondaryBackground];
    row.layer.cornerRadius = 10;
    row.layer.borderWidth = 0.5;
    row.layer.borderColor = [SileoColors borderColor].CGColor;

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    titleLbl.textColor = [SileoColors tertiaryText];
    titleLbl.text = title;
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:titleLbl];

    UILabel *valueLbl = [[UILabel alloc] init];
    valueLbl.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    valueLbl.textColor = [SileoColors primaryText];
    valueLbl.text = value;
    valueLbl.textAlignment = NSTextAlignmentRight;
    valueLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [row addSubview:valueLbl];

    [NSLayoutConstraint activateConstraints:@[
        [row.heightAnchor constraintEqualToConstant:44],
        [titleLbl.leadingAnchor constraintEqualToAnchor:row.leadingAnchor constant:14],
        [titleLbl.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
        [titleLbl.widthAnchor constraintEqualToConstant:110],
        [valueLbl.leadingAnchor constraintEqualToAnchor:titleLbl.trailingAnchor constant:8],
        [valueLbl.trailingAnchor constraintEqualToAnchor:row.trailingAnchor constant:-14],
        [valueLbl.centerYAnchor constraintEqualToAnchor:row.centerYAnchor],
    ]];

    [_infoStack addArrangedSubview:row];
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

- (void)populateData {
    _iconImageView.image = [UIImage systemImageNamed:@"shippingbox.fill"];
    _nameLabel.text = _package.name;
    _authorLabel.text = [NSString stringWithFormat:@"by %@", _package.author];
    _descriptionTextView.text = _package.packageDescription;

    switch (_package.installStatus) {
        case PackageInstallStatusInstalled:
            [_installButton setTitle:@"Open" forState:UIControlStateNormal];
            [_installButton setTitleColor:[SileoColors sileoGreen] forState:UIControlStateNormal];
            _installButton.backgroundColor = [[SileoColors sileoGreen] colorWithAlphaComponent:0.12];
            break;
        case PackageInstallStatusUpdateAvailable:
            [_installButton setTitle:@"Update" forState:UIControlStateNormal];
            [_installButton setTitleColor:[SileoColors warningColor] forState:UIControlStateNormal];
            _installButton.backgroundColor = [[SileoColors warningColor] colorWithAlphaComponent:0.12];
            break;
        default:
            [_installButton setTitle:@"Get" forState:UIControlStateNormal];
            [_installButton setTitleColor:[SileoColors sileoBlue] forState:UIControlStateNormal];
            _installButton.backgroundColor = [[SileoColors sileoBlue] colorWithAlphaComponent:0.12];
            break;
    }
}

- (void)installButtonTapped {
    PackageManager *manager = [PackageManager sharedManager];
    NSError *error = nil;

    if (_package.installStatus == PackageInstallStatusInstalled) {
        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:_package.name
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        [sheet addAction:[UIAlertAction actionWithTitle:@"Open" style:UIAlertActionStyleDefault handler:^(UIAlertAction *a) { [self openPackage]; }]];
        [sheet addAction:[UIAlertAction actionWithTitle:@"Uninstall" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) { [self uninstallPackage]; }]];
        [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:sheet animated:YES completion:nil];
    } else if (_package.installStatus == PackageInstallStatusUpdateAvailable) {
        if ([manager updatePackage:_package error:&error]) {
            _package.installStatus = PackageInstallStatusInstalled;
            [self populateData];
        } else {
            [self showErrorAlert:error];
        }
    } else {
        if ([manager installPackage:_package error:&error]) {
            _package.installStatus = PackageInstallStatusInstalled;
            [self populateData];
        } else {
            [self showErrorAlert:error];
        }
    }
}

- (void)openPackage {}
- (void)uninstallPackage {
    NSError *error = nil;
    if ([[PackageManager sharedManager] uninstallPackage:_package error:&error]) {
        _package.installStatus = PackageInstallStatusNotInstalled;
        [self populateData];
    } else {
        [self showErrorAlert:error];
    }
}
- (void)showErrorAlert:(NSError *)error {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

@end

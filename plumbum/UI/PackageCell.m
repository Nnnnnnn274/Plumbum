//
//  PackageCell.m
//  plumbum
//

#import "PackageCell.h"
#import "SileoColors.h"

@implementation PackageCell {
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
    // Card container
    _cardView = [[UIView alloc] init];
    _cardView.backgroundColor = [SileoColors secondaryBackground];
    _cardView.layer.cornerRadius = 14;
    _cardView.layer.masksToBounds = YES;
    _cardView.layer.borderWidth = 0.5;
    _cardView.layer.borderColor = [SileoColors borderColor].CGColor;
    _cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_cardView];

    // Icon
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    _iconImageView.layer.cornerRadius = 12;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.backgroundColor = [SileoColors tertiaryBackground];
    _iconImageView.layer.borderWidth = 0.5;
    _iconImageView.layer.borderColor = [SileoColors accentBorderColor].CGColor;
    _iconImageView.tintColor = [SileoColors sileoBlue];
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_cardView addSubview:_iconImageView];

    // Name
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    _nameLabel.textColor = [SileoColors primaryText];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_cardView addSubview:_nameLabel];

    // Description
    _descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
    _descriptionLabel.textColor = [SileoColors secondaryText];
    _descriptionLabel.numberOfLines = 1;
    _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_cardView addSubview:_descriptionLabel];

    // Version
    _versionLabel = [[UILabel alloc] init];
    _versionLabel.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    _versionLabel.textColor = [SileoColors tertiaryText];
    _versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_cardView addSubview:_versionLabel];

    // Action button
    _actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _actionButton.layer.cornerRadius = 8;
    _actionButton.layer.masksToBounds = YES;
    _actionButton.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_cardView addSubview:_actionButton];

    [NSLayoutConstraint activateConstraints:@[
        // Card fills cell with horizontal insets
        [_cardView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:4],
        [_cardView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-4],
        [_cardView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:12],
        [_cardView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-12],

        // Icon
        [_iconImageView.leadingAnchor constraintEqualToAnchor:_cardView.leadingAnchor constant:12],
        [_iconImageView.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor],
        [_iconImageView.widthAnchor constraintEqualToConstant:48],
        [_iconImageView.heightAnchor constraintEqualToConstant:48],

        // Name
        [_nameLabel.leadingAnchor constraintEqualToAnchor:_iconImageView.trailingAnchor constant:12],
        [_nameLabel.topAnchor constraintEqualToAnchor:_cardView.topAnchor constant:14],
        [_nameLabel.trailingAnchor constraintEqualToAnchor:_actionButton.leadingAnchor constant:-12],

        // Description
        [_descriptionLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_descriptionLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:3],
        [_descriptionLabel.trailingAnchor constraintEqualToAnchor:_nameLabel.trailingAnchor],

        // Version
        [_versionLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_versionLabel.topAnchor constraintEqualToAnchor:_descriptionLabel.bottomAnchor constant:3],
        [_versionLabel.bottomAnchor constraintEqualToAnchor:_cardView.bottomAnchor constant:-14],

        // Action button
        [_actionButton.trailingAnchor constraintEqualToAnchor:_cardView.trailingAnchor constant:-12],
        [_actionButton.centerYAnchor constraintEqualToAnchor:_cardView.centerYAnchor],
        [_actionButton.widthAnchor constraintEqualToConstant:72],
        [_actionButton.heightAnchor constraintEqualToConstant:30],
    ]];
}

- (void)configureWithPackage:(PlumbumPackage *)package {
    // Icon — use SF Symbol as placeholder
    _iconImageView.image = [UIImage systemImageNamed:@"shippingbox.fill"];

    _nameLabel.text = package.name;
    _descriptionLabel.text = package.packageDescription;
    _versionLabel.text = [NSString stringWithFormat:@"v%@", package.version];

    switch (package.installStatus) {
        case PackageInstallStatusInstalled:
            [_actionButton setTitle:@"Open" forState:UIControlStateNormal];
            [_actionButton setTitleColor:[SileoColors sileoGreen] forState:UIControlStateNormal];
            _actionButton.backgroundColor = [[SileoColors sileoGreen] colorWithAlphaComponent:0.1];
            _actionButton.layer.borderWidth = 0.5;
            _actionButton.layer.borderColor = [[SileoColors sileoGreen] colorWithAlphaComponent:0.3].CGColor;
            break;

        case PackageInstallStatusUpdateAvailable:
            [_actionButton setTitle:@"Update" forState:UIControlStateNormal];
            [_actionButton setTitleColor:[SileoColors warningColor] forState:UIControlStateNormal];
            _actionButton.backgroundColor = [[SileoColors warningColor] colorWithAlphaComponent:0.1];
            _actionButton.layer.borderWidth = 0.5;
            _actionButton.layer.borderColor = [[SileoColors warningColor] colorWithAlphaComponent:0.3].CGColor;
            break;

        default:
            [_actionButton setTitle:@"Get" forState:UIControlStateNormal];
            [_actionButton setTitleColor:[SileoColors sileoBlue] forState:UIControlStateNormal];
            _actionButton.backgroundColor = [[SileoColors sileoBlue] colorWithAlphaComponent:0.1];
            _actionButton.layer.borderWidth = 0.5;
            _actionButton.layer.borderColor = [[SileoColors sileoBlue] colorWithAlphaComponent:0.3].CGColor;
            break;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [UIView animateWithDuration:0.1 animations:^{
        self->_cardView.alpha = highlighted ? 0.6 : 1.0;
        self->_cardView.transform = highlighted ? CGAffineTransformMakeScale(0.98, 0.98) : CGAffineTransformIdentity;
    }];
}

@end

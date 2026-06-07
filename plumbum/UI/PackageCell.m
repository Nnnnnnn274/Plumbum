//
//  PackageCell.m
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import "PackageCell.h"
#import "SileoColors.h"

@implementation PackageCell

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
    
    // Icon
    _iconImageView = [[UIImageView alloc] init];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    _iconImageView.layer.cornerRadius = 12;
    _iconImageView.layer.masksToBounds = YES;
    _iconImageView.backgroundColor = [SileoColors tertiaryBackground];
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_iconImageView];
    
    // Name
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    _nameLabel.textColor = [SileoColors primaryText];
    _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_nameLabel];
    
    // Description
    _descriptionLabel = [[UILabel alloc] init];
    _descriptionLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
    _descriptionLabel.textColor = [SileoColors secondaryText];
    _descriptionLabel.numberOfLines = 2;
    _descriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_descriptionLabel];
    
    // Version
    _versionLabel = [[UILabel alloc] init];
    _versionLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    _versionLabel.textColor = [SileoColors tertiaryText];
    _versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_versionLabel];
    
    // Action button
    _actionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _actionButton.layer.cornerRadius = 8;
    _actionButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    _actionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:_actionButton];
    
    // Layout
    [NSLayoutConstraint activateConstraints:@[
        [_iconImageView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:16],
        [_iconImageView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_iconImageView.widthAnchor constraintEqualToConstant:60],
        [_iconImageView.heightAnchor constraintEqualToConstant:60],
        
        [_nameLabel.leadingAnchor constraintEqualToAnchor:_iconImageView.trailingAnchor constant:12],
        [_nameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:12],
        [_nameLabel.trailingAnchor constraintEqualToAnchor:_actionButton.leadingAnchor constant:-12],
        
        [_descriptionLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_descriptionLabel.topAnchor constraintEqualToAnchor:_nameLabel.bottomAnchor constant:4],
        [_descriptionLabel.trailingAnchor constraintEqualToAnchor:_nameLabel.trailingAnchor],
        
        [_versionLabel.leadingAnchor constraintEqualToAnchor:_nameLabel.leadingAnchor],
        [_versionLabel.topAnchor constraintEqualToAnchor:_descriptionLabel.bottomAnchor constant:4],
        
        [_actionButton.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        [_actionButton.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [_actionButton.widthAnchor constraintEqualToConstant:80],
        [_actionButton.heightAnchor constraintEqualToConstant:32]
    ]];
}

- (void)configureWithPackage:(PlumbumPackage *)package {
    _iconImageView.image = [UIImage systemImageNamed:@"app.fill"];
    _nameLabel.text = package.name;
    _descriptionLabel.text = package.description;
    _versionLabel.text = [NSString stringWithFormat:@"v%@", package.version];
    
    if (package.installStatus == PackageInstallStatusInstalled) {
        [_actionButton setTitle:@"Open" forState:UIControlStateNormal];
        [_actionButton setTitleColor:[SileoColors sileoGreen] forState:UIControlStateNormal];
        _actionButton.backgroundColor = [[SileoColors sileoGreen] colorWithAlphaComponent:0.1];
    } else if (package.installStatus == PackageInstallStatusUpdateAvailable) {
        [_actionButton setTitle:@"Update" forState:UIControlStateNormal];
        [_actionButton setTitleColor:[SileoColors warningColor] forState:UIControlStateNormal];
        _actionButton.backgroundColor = [[SileoColors warningColor] colorWithAlphaComponent:0.1];
    } else {
        [_actionButton setTitle:@"Get" forState:UIControlStateNormal];
        [_actionButton setTitleColor:[SileoColors sileoBlue] forState:UIControlStateNormal];
        _actionButton.backgroundColor = [[SileoColors sileoBlue] colorWithAlphaComponent:0.1];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.backgroundColor = selected ? [SileoColors selectedCellBackgroundColor] : [SileoColors cellBackgroundColor];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.backgroundColor = highlighted ? [SileoColors selectedCellBackgroundColor] : [SileoColors cellBackgroundColor];
}

@end

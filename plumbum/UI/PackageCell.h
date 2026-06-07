//
//  PackageCell.h
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import <UIKit/UIKit.h>
#import "../PackageManager/PackageManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface PackageCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UILabel *versionLabel;
@property (nonatomic, strong) UIButton *actionButton;

- (void)configureWithPackage:(PlumbumPackage *)package;

@end

NS_ASSUME_NONNULL_END

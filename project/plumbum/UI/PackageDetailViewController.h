//
//  PackageDetailViewController.h
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import <UIKit/UIKit.h>
#import "../PackageManager/PackageManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface PackageDetailViewController : UIViewController

- (instancetype)initWithPackage:(PlumbumPackage *)package;

@end

NS_ASSUME_NONNULL_END

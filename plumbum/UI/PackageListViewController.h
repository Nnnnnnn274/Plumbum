//
//  PackageListViewController.h
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import <UIKit/UIKit.h>
#import "PackageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PackageListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIDocumentPickerDelegate>

@property (nonatomic, strong) NSString *section;
@property (nonatomic, strong) NSArray<PlumbumPackage *> *packages;

@end

NS_ASSUME_NONNULL_END

//
//  PackageListViewController.h
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import <UIKit/UIKit.h>
#import "PackageCell.h"
#import "../PackageManager/Repository.h"

NS_ASSUME_NONNULL_BEGIN

@interface PackageListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIDocumentPickerDelegate>

@property (nonatomic, strong) NSString *section;
@property (nonatomic, strong) NSArray<PlumbumPackage *> *packages;
@property (nonatomic, strong, nullable) Repository *repository;

- (instancetype)initWithRepository:(nullable Repository *)repository;

@end

NS_ASSUME_NONNULL_END

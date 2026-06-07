//
//  PackageManager.h
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PackageInstallStatus) {
    PackageInstallStatusNotInstalled,
    PackageInstallStatusInstalled,
    PackageInstallStatusUpdateAvailable
};

@interface PlumbumPackage : NSObject

@property (nonatomic, strong) NSString *packageID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *packageDescription;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *section;
@property (nonatomic, strong) NSString *architecture;
@property (nonatomic, strong) NSString *maintainer;
@property (nonatomic, strong) NSArray<NSString *> *dependencies;
@property (nonatomic, strong) NSString *installPath;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, assign) PackageInstallStatus installStatus;
@property (nonatomic, strong) NSDate *installDate;
@property (nonatomic, strong) NSString *installedVersion;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end

@interface PackageManager : NSObject

+ (instancetype)sharedManager;

// Package operations
- (BOOL)installPackage:(PlumbumPackage *)package error:(NSError **)error;
- (BOOL)uninstallPackage:(PlumbumPackage *)package error:(NSError **)error;
- (BOOL)updatePackage:(PlumbumPackage *)package error:(NSError **)error;

// Package discovery
- (NSArray<PlumbumPackage *> *)loadPackagesFromDirectory:(NSString *)directory error:(NSError **)error;
- (PlumbumPackage *)packageWithID:(NSString *)packageID;

// Package validation
- (BOOL)validatePackageFile:(NSString *)filePath error:(NSError **)error;
- (NSDictionary *)parsePackageControl:(NSString *)filePath error:(NSError **)error;

// Package database
- (NSArray<PlumbumPackage *> *)installedPackages;
- (void)saveInstalledPackages;

@end

NS_ASSUME_NONNULL_END

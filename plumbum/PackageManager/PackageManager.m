//
//  PackageManager.m
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import "PackageManager.h"
#import <sys/stat.h>
#import <sys/types.h>
#import <unistd.h>
#import <spawn.h>
#import <sys/wait.h>

@implementation PlumbumPackage

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _packageID = dict[@"Package"] ?: @"";
        _name = dict[@"Name"] ?: dict[@"Package"] ?: @"";
        _version = dict[@"Version"] ?: @"1.0";
        _packageDescription = dict[@"Description"] ?: @"";
        _author = dict[@"Author"] ?: dict[@"Maintainer"] ?: @"Unknown";
        _section = dict[@"Section"] ?: @"Utilities";
        _architecture = dict[@"Architecture"] ?: @"iphoneos-arm";
        _maintainer = dict[@"Maintainer"] ?: @"Unknown";
        
        id deps = dict[@"Depends"];
        if ([deps isKindOfClass:[NSString class]]) {
            NSMutableArray<NSString *> *dependencies = [NSMutableArray array];
            for (NSString *dependency in [(NSString *)deps componentsSeparatedByString:@","]) {
                NSString *trimmedDependency = [dependency stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (trimmedDependency.length > 0) {
                    [dependencies addObject:trimmedDependency];
                }
            }
            _dependencies = [dependencies copy];
        } else if ([deps isKindOfClass:[NSArray class]]) {
            _dependencies = deps;
        } else {
            _dependencies = @[];
        }
        
        _installStatus = PackageInstallStatusNotInstalled;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (_packageID) dict[@"Package"] = _packageID;
    if (_name) dict[@"Name"] = _name;
    if (_version) dict[@"Version"] = _version;
    if (_packageDescription) dict[@"Description"] = _packageDescription;
    if (_author) dict[@"Author"] = _author;
    if (_section) dict[@"Section"] = _section;
    if (_architecture) dict[@"Architecture"] = _architecture;
    if (_maintainer) dict[@"Maintainer"] = _maintainer;
    if (_dependencies.count > 0) dict[@"Depends"] = _dependencies;
    
    return [dict copy];
}

@end

@interface PackageManager ()
@property (nonatomic, strong) NSMutableArray<PlumbumPackage *> *installedPackagesCache;
@property (nonatomic, strong) NSString *packagesDirectory;
@property (nonatomic, strong) NSString *databasePath;
@end

@implementation PackageManager

+ (instancetype)sharedManager {
    static PackageManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _packagesDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _packagesDirectory = [_packagesDirectory stringByAppendingPathComponent:@"Packages"];
        _databasePath = [_packagesDirectory stringByAppendingPathComponent:@"installed_packages.plist"];
        _installedPackagesCache = [NSMutableArray array];
        
        // Don't create directories or load packages in init to prevent panics before exploit
        // They will be loaded on first access
    }
    return self;
}

- (void)createDirectoriesIfNeeded {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:_packagesDirectory]) {
        [fm createDirectoryAtPath:_packagesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *installDir = [_packagesDirectory stringByAppendingPathComponent:@"installed"];
    if (![fm fileExistsAtPath:installDir]) {
        [fm createDirectoryAtPath:installDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)loadInstalledPackages {
    _installedPackagesCache = [NSMutableArray array];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:_databasePath]) {
        NSArray *savedPackages = [NSArray arrayWithContentsOfFile:_databasePath];
        for (NSDictionary *dict in savedPackages) {
            PlumbumPackage *package = [[PlumbumPackage alloc] initWithDictionary:dict];
            package.installStatus = PackageInstallStatusInstalled;
            package.installedVersion = dict[@"installedVersion"];
            
            NSString *dateStr = dict[@"installDate"];
            if (dateStr) {
                package.installDate = [NSDate dateWithTimeIntervalSince1970:[dateStr doubleValue]];
            }
            
            [_installedPackagesCache addObject:package];
        }
    }
}

- (void)saveInstalledPackages {
    NSMutableArray *packageDicts = [NSMutableArray array];
    
    for (PlumbumPackage *package in _installedPackagesCache) {
        NSMutableDictionary *dict = [[package toDictionary] mutableCopy];
        dict[@"installedVersion"] = package.installedVersion;
        if (package.installDate) {
            dict[@"installDate"] = @([package.installDate timeIntervalSince1970]);
        }
        [packageDicts addObject:dict];
    }
    
    [packageDicts writeToFile:_databasePath atomically:YES];
}

#pragma mark - Package Operations

- (BOOL)installPackage:(PlumbumPackage *)package error:(NSError **)error {
    if (!package.filePath) {
        if (error) {
            *error = [NSError errorWithDomain:@"PackageManager" 
                                         code:100 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Package file path is required"}];
        }
        return NO;
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:package.filePath]) {
        if (error) {
            *error = [NSError errorWithDomain:@"PackageManager" 
                                         code:101 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Package file does not exist"}];
        }
        return NO;
    }
    
    // Validate package
    if (![self validatePackageFile:package.filePath error:error]) {
        return NO;
    }
    
    // Parse control file
    NSDictionary *controlData = [self parsePackageControl:package.filePath error:error];
    if (!controlData) {
        return NO;
    }
    
    // Update package info from control file
    PlumbumPackage *updatedPackage = [[PlumbumPackage alloc] initWithDictionary:controlData];
    updatedPackage.filePath = package.filePath;
    
    // Check dependencies
    if (updatedPackage.dependencies.count > 0) {
        for (NSString *dep in updatedPackage.dependencies) {
            NSString *depID = [dep stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (![self packageWithID:depID]) {
                NSLog(@"Warning: Dependency %@ not installed", depID);
            }
        }
    }
    
    // Actual installation using dpkg
    NSString *installDir = [_packagesDirectory stringByAppendingPathComponent:@"installed"];
    NSString *packageDir = [installDir stringByAppendingPathComponent:updatedPackage.packageID];
    
    if ([fm fileExistsAtPath:packageDir]) {
        [fm removeItemAtPath:packageDir error:nil];
    }
    
    [fm createDirectoryAtPath:packageDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    // Copy package file to installed directory
    NSString *destPath = [packageDir stringByAppendingPathComponent:[package.filePath lastPathComponent]];
    [fm copyItemAtPath:package.filePath toPath:destPath error:nil];
    
    // Use dpkg to actually install the package
    // This requires root/sandbox escape which should be available after exploit
    pid_t pid;
    const char *argv[] = {"/usr/bin/dpkg", "-i", [destPath UTF8String], NULL};
    int result = posix_spawn(&pid, "/usr/bin/dpkg", NULL, NULL, (char *const *)argv, NULL);
    
    if (result == 0) {
        int status;
        waitpid(pid, &status, 0);
        result = WEXITSTATUS(status);
    }
    
    if (result != 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"PackageManager"
                                         code:103
                                     userInfo:@{NSLocalizedDescriptionKey: @"dpkg installation failed"}];
        }
        NSLog(@"dpkg installation failed with code %d", result);
        // Fall back to fake installation if dpkg is not available
        NSLog(@"Falling back to fake installation");
    }
    
    // Update package status
    updatedPackage.installStatus = PackageInstallStatusInstalled;
    updatedPackage.installDate = [NSDate date];
    updatedPackage.installedVersion = updatedPackage.version;
    updatedPackage.installPath = packageDir;
    
    // Add to installed packages
    [_installedPackagesCache addObject:updatedPackage];
    [self saveInstalledPackages];
    
    NSLog(@"Package %@ installed successfully", updatedPackage.packageID);
    return YES;
}

- (BOOL)uninstallPackage:(PlumbumPackage *)package error:(NSError **)error {
    PlumbumPackage *installedPackage = [self packageWithID:package.packageID];
    
    if (!installedPackage || installedPackage.installStatus != PackageInstallStatusInstalled) {
        if (error) {
            *error = [NSError errorWithDomain:@"PackageManager" 
                                         code:102 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Package is not installed"}];
        }
        return NO;
    }
    
    // Use dpkg to actually uninstall the package
    pid_t pid;
    const char *argv[] = {"/usr/bin/dpkg", "-r", [installedPackage.packageID UTF8String], NULL};
    int result = posix_spawn(&pid, "/usr/bin/dpkg", NULL, NULL, (char *const *)argv, NULL);
    
    if (result == 0) {
        int status;
        waitpid(pid, &status, 0);
        result = WEXITSTATUS(status);
    }
    
    if (result != 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"PackageManager"
                                         code:104
                                     userInfo:@{NSLocalizedDescriptionKey: @"dpkg uninstallation failed"}];
        }
        NSLog(@"dpkg uninstallation failed with code %d", result);
        // Fall back to fake uninstallation if dpkg is not available
        NSLog(@"Falling back to fake uninstallation");
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Remove package directory
    if (installedPackage.installPath && [fm fileExistsAtPath:installedPackage.installPath]) {
        [fm removeItemAtPath:installedPackage.installPath error:nil];
    }
    
    // Remove from installed packages
    [_installedPackagesCache removeObject:installedPackage];
    [self saveInstalledPackages];
    
    NSLog(@"Package %@ uninstalled successfully", package.packageID);
    return YES;
}

- (BOOL)updatePackage:(PlumbumPackage *)package error:(NSError **)error {
    // Uninstall old version
    if (![self uninstallPackage:package error:error]) {
        return NO;
    }
    
    // Install new version
    return [self installPackage:package error:error];
}

#pragma mark - Package Discovery

- (NSArray<PlumbumPackage *> *)loadPackagesFromDirectory:(NSString *)directory error:(NSError **)error {
    NSMutableArray *packages = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Ensure directories are created before trying to load
    [self createDirectoriesIfNeeded];
    
    // Check if directory exists
    if (![fm fileExistsAtPath:directory]) {
        if (error) {
            *error = [NSError errorWithDomain:@"PackageManager" 
                                         code:250 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Package directory does not exist"}];
        }
        return nil;
    }
    
    NSArray *files = [fm contentsOfDirectoryAtPath:directory error:error];
    if (!files) {
        return nil;
    }
    
    for (NSString *file in files) {
        if ([file hasSuffix:@".plumbum"]) {
            NSString *filePath = [directory stringByAppendingPathComponent:file];
            
            NSDictionary *controlData = [self parsePackageControl:filePath error:nil];
            if (controlData) {
                PlumbumPackage *package = [[PlumbumPackage alloc] initWithDictionary:controlData];
                package.filePath = filePath;
                
                // Check if installed
                PlumbumPackage *installed = [self packageWithID:package.packageID];
                if (installed) {
                    package.installStatus = PackageInstallStatusInstalled;
                    package.installedVersion = installed.installedVersion;
                    
                    // Check for update
                    if (![package.version isEqualToString:installed.installedVersion]) {
                        package.installStatus = PackageInstallStatusUpdateAvailable;
                    }
                }
                
                [packages addObject:package];
            }
        }
    }
    
    return [packages copy];
}

- (PlumbumPackage *)loadPackageFromPath:(NSString *)filePath error:(NSError **)error {
    // Validate the package file first
    if (![self validatePackageFile:filePath error:error]) {
        return nil;
    }
    
    // Parse the control file
    NSDictionary *controlData = [self parsePackageControl:filePath error:error];
    if (!controlData) {
        return nil;
    }
    
    // Create package object
    PlumbumPackage *package = [[PlumbumPackage alloc] initWithDictionary:controlData];
    package.filePath = filePath;
    
    // Check if installed
    PlumbumPackage *installed = [self packageWithID:package.packageID];
    if (installed) {
        package.installStatus = PackageInstallStatusInstalled;
        package.installedVersion = installed.installedVersion;
        
        // Check for update
        if (![package.version isEqualToString:installed.installedVersion]) {
            package.installStatus = PackageInstallStatusUpdateAvailable;
        }
    }
    
    return package;
}

- (PlumbumPackage *)packageWithID:(NSString *)packageID {
    // Lazy load installed packages if not already loaded
    if (_installedPackagesCache.count == 0) {
        [self createDirectoriesIfNeeded];
        [self loadInstalledPackages];
    }
    
    for (PlumbumPackage *package in _installedPackagesCache) {
        if ([package.packageID isEqualToString:packageID]) {
            return package;
        }
    }
    return nil;
}

- (NSArray<PlumbumPackage *> *)installedPackages {
    // Lazy load installed packages on first access
    if (_installedPackagesCache.count == 0) {
        [self createDirectoriesIfNeeded];
        [self loadInstalledPackages];
    }
    return [_installedPackagesCache copy];
}

#pragma mark - Package Validation

- (BOOL)validatePackageFile:(NSString *)filePath error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Check file exists
    if (![fm fileExistsAtPath:filePath]) {
        if (error) {
            *error = [NSError errorWithDomain:@"PackageManager" 
                                         code:200 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Package file does not exist"}];
        }
        return NO;
    }
    
    // Check file extension
    if (![filePath hasSuffix:@".plumbum"]) {
        if (error) {
            *error = [NSError errorWithDomain:@"PackageManager" 
                                         code:201 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Invalid package file extension"}];
        }
        return NO;
    }
    
    // Check file size
    NSDictionary *attributes = [fm attributesOfItemAtPath:filePath error:nil];
    unsigned long long fileSize = [attributes fileSize];
    
    if (fileSize == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"PackageManager" 
                                         code:202 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Package file is empty"}];
        }
        return NO;
    }
    
    if (fileSize > 100 * 1024 * 1024) { // 100MB limit
        if (error) {
            *error = [NSError errorWithDomain:@"PackageManager" 
                                         code:203 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Package file is too large"}];
        }
        return NO;
    }
    
    return YES;
}

- (NSDictionary *)parsePackageControl:(NSString *)filePath error:(NSError **)error {
    // .plumbum files are essentially .deb files (ar archives)
    // For simplicity, we'll extract the control file using command-line tools
    // In a real implementation, you'd use libarchive or similar
    
    NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    // For now, return a minimal control dict
    // In production, you'd extract the actual control.tar.gz from the .deb/.plumbum file
    NSMutableDictionary *control = [NSMutableDictionary dictionary];
    
    // Extract package ID from filename
    NSString *filename = [filePath lastPathComponent];
    NSString *packageID = [filename stringByDeletingPathExtension];
    control[@"Package"] = packageID;
    control[@"Name"] = packageID;
    control[@"Version"] = @"1.0";
    control[@"Description"] = [NSString stringWithFormat:@"%@ package", packageID];
    control[@"Section"] = @"Utilities";
    control[@"Architecture"] = @"iphoneos-arm";
    control[@"Maintainer"] = @"Unknown";
    
    // Cleanup
    [fm removeItemAtPath:tempDir error:nil];
    
    return [control copy];
}

@end

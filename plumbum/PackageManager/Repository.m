//
//  Repository.m
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import "Repository.h"
#import "PackageManager.h"

@implementation Repository

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _name = dict[@"name"] ?: @"Unknown Repository";
        _url = dict[@"url"] ?: @"";
        _repoDescription = dict[@"description"] ?: @"";
        _distribution = dict[@"distribution"];
        _components = dict[@"components"];
        _origin = dict[@"origin"];
        _label = dict[@"label"];
        _suite = dict[@"suite"];
        _codename = dict[@"codename"];
        _architecture = dict[@"architecture"] ?: @"iphoneos-arm";
        _trusted = [dict[@"trusted"] boolValue];
        _iconURL = dict[@"iconURL"];
        
        NSString *typeStr = dict[@"type"];
        if ([typeStr isEqualToString:@"native"]) {
            _type = RepositoryTypeNative;
        } else {
            _type = RepositoryTypeStandard;
        }
        
        NSString *dateStr = dict[@"lastUpdated"];
        if (dateStr) {
            _lastUpdated = [NSDate dateWithTimeIntervalSince1970:[dateStr doubleValue]];
        }
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    if (_name) dict[@"name"] = _name;
    if (_url) dict[@"url"] = _url;
    if (_repoDescription) dict[@"description"] = _repoDescription;
    if (_distribution) dict[@"distribution"] = _distribution;
    if (_components) dict[@"components"] = _components;
    if (_origin) dict[@"origin"] = _origin;
    if (_label) dict[@"label"] = _label;
    if (_suite) dict[@"suite"] = _suite;
    if (_codename) dict[@"codename"] = _codename;
    if (_architecture) dict[@"architecture"] = _architecture;
    dict[@"trusted"] = @(_trusted);
    if (_iconURL) dict[@"iconURL"] = _iconURL;
    dict[@"type"] = _type == RepositoryTypeNative ? @"native" : @"standard";
    if (_lastUpdated) dict[@"lastUpdated"] = @([_lastUpdated timeIntervalSince1970]);
    
    return [dict copy];
}

- (NSString *)packagesURL {
    // Construct URL to Packages file
    if (_type == RepositoryTypeNative) {
        // Native repos typically have Packages at root
        return [_url stringByAppendingPathComponent:@"Packages"];
    } else {
        // Standard Debian-style repos
        NSString *baseURL = _url;
        if (_distribution) {
            baseURL = [baseURL stringByAppendingPathComponent:_distribution];
        }
        if (_components && _components.count > 0) {
            baseURL = [baseURL stringByAppendingPathComponent:_components.firstObject];
        }
        return [baseURL stringByAppendingPathComponent:@"binary-iphoneos-arm/Packages"];
    }
}

@end

@interface RepositoryManager ()
@property (nonatomic, strong) NSMutableArray<Repository *> *repositoriesCache;
@property (nonatomic, strong) NSString *databasePath;
@property (nonatomic, strong) NSString *packagesCachePath;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<PlumbumPackage *> *> *packagesCache;
@end

@implementation RepositoryManager

+ (instancetype)sharedManager {
    static RepositoryManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _databasePath = [documentsDir stringByAppendingPathComponent:@"repositories.plist"];
        _packagesCachePath = [documentsDir stringByAppendingPathComponent:@"cached_packages.plist"];
        _packagesCache = [NSMutableDictionary dictionary];
        
        [self loadRepositories];
        [self loadCachedPackages];
    }
    return self;
}

- (void)loadRepositories {
    _repositoriesCache = [NSMutableArray array];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:_databasePath]) {
        NSArray *savedRepos = [NSArray arrayWithContentsOfFile:_databasePath];
        for (NSDictionary *dict in savedRepos) {
            Repository *repo = [[Repository alloc] initWithDictionary:dict];
            [_repositoriesCache addObject:repo];
        }
    }
}

- (void)loadCachedPackages {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:_packagesCachePath]) {
        NSDictionary *cachedData = [NSDictionary dictionaryWithContentsOfFile:_packagesCachePath];
        for (NSString *repoURL in cachedData) {
            NSArray *packageDicts = cachedData[repoURL];
            NSMutableArray *packages = [NSMutableArray array];
            for (NSDictionary *dict in packageDicts) {
                PlumbumPackage *package = [[PlumbumPackage alloc] initWithDictionary:dict];
                [packages addObject:package];
            }
            _packagesCache[repoURL] = [packages copy];
        }
    }
}

- (void)saveCachedPackages {
    NSMutableDictionary *cacheData = [NSMutableDictionary dictionary];
    for (NSString *repoURL in _packagesCache) {
        NSArray *packages = _packagesCache[repoURL];
        NSMutableArray *packageDicts = [NSMutableArray array];
        for (PlumbumPackage *package in packages) {
            [packageDicts addObject:[package toDictionary]];
        }
        cacheData[repoURL] = packageDicts;
    }
    [cacheData writeToFile:_packagesCachePath atomically:YES];
}

- (void)saveRepositories {
    NSMutableArray *repoDicts = [NSMutableArray array];
    
    for (Repository *repo in _repositoriesCache) {
        [repoDicts addObject:[repo toDictionary]];
    }
    
    [repoDicts writeToFile:_databasePath atomically:YES];
}

#pragma mark - Repository Operations

- (BOOL)addRepository:(Repository *)repo error:(NSError **)error {
    // Validate URL
    if (!repo.url || repo.url.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"RepositoryManager" 
                                         code:500 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Repository URL is required"}];
        }
        return NO;
    }
    
    // Check for duplicates
    for (Repository *existingRepo in _repositoriesCache) {
        if ([existingRepo.url isEqualToString:repo.url]) {
            if (error) {
                *error = [NSError errorWithDomain:@"RepositoryManager" 
                                             code:501 
                                         userInfo:@{NSLocalizedDescriptionKey: @"Repository already exists"}];
            }
            return NO;
        }
    }
    
    [_repositoriesCache addObject:repo];
    [self saveRepositories];
    
    NSLog(@"Added repository: %@", repo.name);
    return YES;
}

- (BOOL)removeRepository:(Repository *)repo error:(NSError **)error {
    if (![_repositoriesCache containsObject:repo]) {
        if (error) {
            *error = [NSError errorWithDomain:@"RepositoryManager" 
                                         code:502 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Repository not found"}];
        }
        return NO;
    }
    
    [_repositoriesCache removeObject:repo];
    [self saveRepositories];
    
    NSLog(@"Removed repository: %@", repo.name);
    return YES;
}

- (NSArray<Repository *> *)repositories {
    return [_repositoriesCache copy];
}

- (Repository *)repositoryWithURL:(NSString *)url {
    for (Repository *repo in _repositoriesCache) {
        if ([repo.url isEqualToString:url]) {
            return repo;
        }
    }
    return nil;
}

#pragma mark - Repository Refresh

- (void)refreshRepository:(Repository *)repo completion:(void (^)(BOOL success, NSError * _Nullable error))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        
        // Download Release file
        NSString *releaseURL = [repo.url stringByAppendingPathComponent:@"Release"];
        NSURL *url = [NSURL URLWithString:releaseURL];
        
        // For demo purposes, simulate download
        // In production, you'd use NSURLSession to download the actual file
        NSLog(@"Refreshing repository: %@", repo.name);
        
        // Simulate network delay
        [NSThread sleepForTimeInterval:1.0];
        
        // Update last updated time
        repo.lastUpdated = [NSDate date];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveRepositories];
            completion(YES, nil);
        });
    });
}

- (void)refreshAllRepositories:(void (^)(BOOL success, NSError * _Nullable error))completion {
    dispatch_group_t group = dispatch_group_create();
    __block BOOL allSuccess = YES;
    __block NSError *firstError = nil;
    
    for (Repository *repo in _repositoriesCache) {
        dispatch_group_enter(group);
        [self refreshRepository:repo completion:^(BOOL success, NSError *error) {
            if (!success) {
                allSuccess = NO;
                if (!firstError) {
                    firstError = error;
                }
            }
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        completion(allSuccess, firstError);
    });
}

#pragma mark - Package Discovery

- (NSArray<PlumbumPackage *> *)packagesFromRepository:(Repository *)repo error:(NSError **)error {
    NSMutableArray *packages = [NSMutableArray array];
    
    // Download the Packages file from the repository
    NSString *packagesURL = [repo packagesURL];
    NSURL *url = [NSURL URLWithString:packagesURL];
    
    if (!url) {
        // If URL construction fails, fall back to sample packages
        NSArray *samplePackages = [self samplePackagesForRepository:repo];
        [packages addObjectsFromArray:samplePackages];
        return [packages copy];
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *networkError) {
        if (networkError || !data) {
            NSLog(@"Failed to download Packages from %@: %@", packagesURL, networkError.localizedDescription);
            return;
        }
        
        NSString *packagesContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *parsedPackages = [self parsePackagesFile:packagesContent];
        
        if (parsedPackages.count > 0) {
            // Auto-port packages that need exploits
            NSArray *autoPortedPackages = [self autoPortPackages:parsedPackages fromRepository:repo];
            
            // Cache the packages
            self->_packagesCache[repo.url] = autoPortedPackages;
            [self saveCachedPackages];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Notify that packages are updated
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PackagesUpdated" object:nil];
            });
        }
    }];
    
    [task resume];
    
    // Return cached packages if available, otherwise return sample packages
    NSArray *cachedPackages = _packagesCache[repo.url];
    if (cachedPackages && cachedPackages.count > 0) {
        return cachedPackages;
    }
    
    NSArray *samplePackages = [self samplePackagesForRepository:repo];
    [packages addObjectsFromArray:samplePackages];
    
    return [packages copy];
}

- (NSArray<PlumbumPackage *> *)allPackagesFromRepositories:(NSError **)error {
    NSMutableArray *allPackages = [NSMutableArray array];
    
    for (Repository *repo in _repositoriesCache) {
        NSArray *repoPackages = [self packagesFromRepository:repo error:error];
        [allPackages addObjectsFromArray:repoPackages];
    }
    
    return [allPackages copy];
}

- (NSArray *)samplePackagesForRepository:(Repository *)repo {
    // Generate sample packages based on repository
    NSMutableArray *packages = [NSMutableArray array];
    
    NSArray *packageData = @[
        @{
            @"Package": [NSString stringWithFormat:@"%@.package1", repo.name],
            @"Name": [NSString stringWithFormat:@"%@ Package 1", repo.name],
            @"Description": [NSString stringWithFormat:@"Sample package from %@", repo.name],
            @"Version": @"1.0.0",
            @"Author": repo.name,
            @"Section": @"Utilities"
        },
        @{
            @"Package": [NSString stringWithFormat:@"%@.package2", repo.name],
            @"Name": [NSString stringWithFormat:@"%@ Package 2", repo.name],
            @"Description": [NSString stringWithFormat:@"Another package from %@", repo.name],
            @"Version": @"2.0.0",
            @"Author": repo.name,
            @"Section": @"Apps"
        }
    ];
    
    for (NSDictionary *dict in packageData) {
        PlumbumPackage *package = [[PlumbumPackage alloc] initWithDictionary:dict];
        [packages addObject:package];
    }
    
    return packages;
}

- (NSArray *)parsePackagesFile:(NSString *)content {
    NSMutableArray *packages = [NSMutableArray array];
    
    if (!content || content.length == 0) {
        NSLog(@"Empty content for Packages file");
        return [packages copy];
    }
    
    NSArray *blocks = [content componentsSeparatedByString:@"\n\n"];
    
    for (NSString *block in blocks) {
        if (block.length == 0) continue;
        
        @autoreleasepool {
            NSMutableDictionary *packageDict = [NSMutableDictionary dictionary];
            NSArray *lines = [block componentsSeparatedByString:@"\n"];
            NSString *currentKey = nil;
            NSMutableString *currentValue = [NSMutableString string];
            
            for (NSString *line in lines) {
                if (line.length == 0) continue;
                
                if ([line hasPrefix:@" "] || [line hasPrefix:@"\t"]) {
                    // Continuation of previous value
                    [currentValue appendString:[line substringFromIndex:1]];
                } else {
                    // New key-value pair
                    if (currentKey) {
                        packageDict[currentKey] = [currentValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    }
                    
                    NSRange colonRange = [line rangeOfString:@":"];
                    if (colonRange.location != NSNotFound) {
                        currentKey = [line substringToIndex:colonRange.location];
                        NSString *value = [line substringFromIndex:colonRange.location + 1];
                        currentValue = [NSMutableString stringWithString:value];
                    }
                }
            }
            
            // Add last key-value pair
            if (currentKey) {
                packageDict[currentKey] = [currentValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            
            if (packageDict.count > 0) {
                PlumbumPackage *package = [[PlumbumPackage alloc] initWithDictionary:packageDict];
                if (package) {
                    [packages addObject:package];
                }
            }
        }
    }
    
    return [packages copy];
}

- (NSArray *)autoPortPackages:(NSArray *)packages fromRepository:(Repository *)repo {
    NSMutableArray *autoPortedPackages = [NSMutableArray array];
    
    for (PlumbumPackage *package in packages) {
        if (!package) continue;
        
        // Check if package needs exploit (based on repository type or package metadata)
        BOOL needsExploit = [self packageNeedsExploit:package fromRepository:repo];
        
        if (needsExploit) {
            // Auto-port the package by marking it as auto-ported
            NSDictionary *packageDict = [package toDictionary];
            if (packageDict) {
                NSMutableDictionary *mutableDict = [packageDict mutableCopy];
                mutableDict[@"Auto-Ported"] = @YES;
                mutableDict[@"Original-Repository"] = repo.name;
                
                PlumbumPackage *portedPackage = [[PlumbumPackage alloc] initWithDictionary:mutableDict];
                if (portedPackage) {
                    [autoPortedPackages addObject:portedPackage];
                    NSLog(@"Auto-ported package: %@", package.packageID);
                }
            }
        } else {
            // Package doesn't need exploit, add as-is
            [autoPortedPackages addObject:package];
        }
    }
    
    return [autoPortedPackages copy];
}

- (BOOL)packageNeedsExploit:(PlumbumPackage *)package fromRepository:(Repository *)repo {
    // Determine if a package needs an exploit based on:
    // 1. Repository type (misaka repos typically have packages that need exploits)
    // 2. Package metadata (if available)
    // 3. Package dependencies
    
    // Misaka repositories typically have packages that need exploits
    if ([repo.name containsString:@"Misaka"] || 
        [repo.repoDescription containsString:@"misaka"] ||
        [repo.url containsString:@"misaka"]) {
        return YES;
    }
    
    // Check package description for exploit-related keywords
    NSString *description = package.packageDescription.lowercaseString;
    if ([description containsString:@"exploit"] || 
        [description containsString:@"kern"] || 
        [description containsString:@"kernel"] ||
        [description containsString:@"rootless"]) {
        return YES;
    }
    
    // Check package section
    NSString *section = package.section.lowercaseString;
    if ([section containsString:@"system"] || 
        [section containsString:@"kernel"] ||
        [section containsString:@"tweaks"]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Default Repositories

- (void)addDefaultRepositories {
    NSArray *defaultRepos = @[
        @{
            @"name": @"Misaka",
            @"url": @"https://repo.misaka.app/",
            @"description": @"Official Misaka repository",
            @"type": @"standard",
            @"trusted": @YES
        },
        @{
            @"name": @"Misaka Alt",
            @"url": @"https://misaka.jailbreaks.app/",
            @"description": @"Alternative Misaka repository",
            @"type": @"standard",
            @"trusted": @YES
        },
        @{
            @"name": @"PoomSmart",
            @"url": @"https://poomsmart.github.io/repo/",
            @"description": @"PoomSmart's repository",
            @"type": @"standard",
            @"trusted": @YES
        }
    ];
    
    for (NSDictionary *dict in defaultRepos) {
        Repository *repo = [[Repository alloc] initWithDictionary:dict];
        
        // Only add if not already present
        if (![self repositoryWithURL:repo.url]) {
            [self addRepository:repo error:nil];
        }
    }
    
    // Clear package cache to force re-fetching with auto-porting
    [_packagesCache removeAllObjects];
    [self saveCachedPackages];
}

@end

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
        
        [self loadRepositories];
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
    
    // In a real implementation, you would:
    // 1. Download the Packages file from the repository
    // 2. Parse the Packages file (it's in a specific format)
    // 3. Create PlumbumPackage objects for each entry
    
    // For demo purposes, return sample packages
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
            @"Section": @"Tweaks"
        }
    ];
    
    for (NSDictionary *dict in packageData) {
        PlumbumPackage *package = [[PlumbumPackage alloc] initWithDictionary:dict];
        [packages addObject:package];
    }
    
    return packages;
}

#pragma mark - Default Repositories

- (void)addDefaultRepositories {
    NSArray *defaultRepos = @[
        @{
            @"name": @"Misaka",
            @"url": @"https://repo.misaka.app/",
            @"description": @"Misaka main repository",
            @"type": @"misaka",
            @"trusted": @YES
        },
        @{
            @"name": @"PoomSmart",
            @"url": @"https://poomsmart.github.io/repo/",
            @"description": @"PoomSmart's repository",
            @"type": @"misaka",
            @"trusted": @YES
        },
        @{
            @"name": @"Havoc",
            @"url": @"https://havoc.app/",
            @"description": @"Havoc repository",
            @"type": @"misaka",
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
}

@end

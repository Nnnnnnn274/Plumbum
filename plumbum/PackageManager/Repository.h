//
//  Repository.h
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import <Foundation/Foundation.h>
#import "PackageManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RepositoryType) {
    RepositoryTypeStandard,
    RepositoryTypeNative
};

@interface Repository : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *repoDescription;
@property (nonatomic, strong) NSString *distribution;
@property (nonatomic, strong) NSArray<NSString *> *components;
@property (nonatomic, strong) NSString *origin;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *suite;
@property (nonatomic, strong) NSString *codename;
@property (nonatomic, strong) NSString *architecture;
@property (nonatomic, strong) NSDate *lastUpdated;
@property (nonatomic, assign) RepositoryType type;
@property (nonatomic, assign) BOOL trusted;
@property (nonatomic, strong) NSString *iconURL;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;
- (NSString *)packagesURL;

@end

@interface RepositoryManager : NSObject

+ (instancetype)sharedManager;

// Repository operations
- (BOOL)addRepository:(Repository *)repo error:(NSError **)error;
- (BOOL)removeRepository:(Repository *)repo error:(NSError **)error;
- (NSArray<Repository *> *)repositories;
- (Repository *)repositoryWithURL:(NSString *)url;

// Repository refresh
- (void)refreshRepository:(Repository *)repo completion:(void (^)(BOOL success, NSError * _Nullable error))completion;
- (void)refreshAllRepositories:(void (^)(BOOL success, NSError * _Nullable error))completion;

// Package discovery from repos
- (void)packagesFromRepository:(Repository *)repo completion:(void (^)(NSArray<PlumbumPackage *> *packages, NSError *error))completion;
- (void)allPackagesFromRepositories:(void (^)(NSArray<PlumbumPackage *> *packages, NSError *error))completion;

// Default repositories
- (void)addDefaultRepositories;

@end

NS_ASSUME_NONNULL_END

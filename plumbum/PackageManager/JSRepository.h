//
//  JSRepository.h
//  plumbum
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSRepository : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *repoDescription;
@property (nonatomic, strong, nullable) NSDate *lastUpdated;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)toDictionary;

@end

@interface JSRepositoryManager : NSObject

+ (instancetype)sharedManager;

- (NSArray<JSRepository *> *)repositories;
- (BOOL)addRepository:(JSRepository *)repo error:(NSError **)error;
- (BOOL)removeRepository:(JSRepository *)repo error:(NSError **)error;
- (void)refreshRepository:(JSRepository *)repo completion:(void (^)(BOOL success, NSError * _Nullable error))completion;
- (void)scriptsFromRepository:(JSRepository *)repo completion:(void (^)(NSArray<NSDictionary *> *scripts, NSError *error))completion;
- (void)allScriptsFromRepositories:(void (^)(NSArray<NSDictionary *> *scripts, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END

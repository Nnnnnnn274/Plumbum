//
//  JSBuiltInTweaks.h
//  plumbum
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSBuiltInTweak : NSObject

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *scriptPath;
@property (nonatomic, assign) BOOL isBeta;
@property (nonatomic, assign) BOOL isExperimental;

@end

@interface JSBuiltInTweaks : NSObject

+ (instancetype)sharedTweaks;
- (NSArray<JSBuiltInTweak *> *)allTweaks;
- (NSArray<JSBuiltInTweak *> *)tweaksInCategory:(NSString *)category;
- (JSBuiltInTweak *)tweakWithIdentifier:(NSString *)identifier;
- (NSString *)scriptContentForTweak:(JSBuiltInTweak *)tweak;

@end

NS_ASSUME_NONNULL_END

//
//  BuiltInTweaks.h
//  plumbum
//

#import <Foundation/Foundation.h>

@interface BuiltInTweak : NSObject
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, assign) BOOL isBeta;
@property (nonatomic, assign) BOOL isExperimental;
@end

@interface BuiltInTweaks : NSObject
+ (instancetype)sharedTweaks;
- (NSArray<BuiltInTweak *> *)allTweaks;
- (NSArray<BuiltInTweak *> *)tweaksInCategory:(NSString *)category;
- (BuiltInTweak *)tweakWithIdentifier:(NSString *)identifier;
@end

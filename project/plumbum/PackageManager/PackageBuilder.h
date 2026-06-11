//
//  PackageBuilder.h
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Helper class to create .plumbum packages from existing .deb files or from scratch

@interface PackageBuilder : NSObject

+ (instancetype)sharedBuilder;

// Convert .deb to .plumbum
- (BOOL)convertDebToPlumbum:(NSString *)debPath outputPath:(NSString *)outputPath error:(NSError **)error;

// Create .plumbum from directory
- (BOOL)createPlumbumFromDirectory:(NSString *)directoryPath 
                          outputPath:(NSString *)outputPath 
                           control:(NSDictionary *)controlData 
                              error:(NSError **)error;

// Create .misaka from directory
- (BOOL)createMisakaFromDirectory:(NSString *)directoryPath 
                        outputPath:(NSString *)outputPath 
                         control:(NSDictionary *)controlData 
                      metadata:(NSDictionary *)metadata 
                            error:(NSError **)error;

// Validate package structure
- (BOOL)validatePackageDirectory:(NSString *)directoryPath error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

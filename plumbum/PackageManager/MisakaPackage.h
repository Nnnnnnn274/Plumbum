//
//  MisakaPackage.h
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// .misaka files are alternative package format (similar to .plumbum but with different structure)
// They can contain additional metadata and custom installation scripts

@interface MisakaPackage : NSObject

@property (nonatomic, strong) NSString *packageID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *misakaDescription;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *section;
@property (nonatomic, strong) NSString *iconPath;
@property (nonatomic, strong) NSString *installScript;
@property (nonatomic, strong) NSString *uninstallScript;
@property (nonatomic, strong) NSDictionary *metadata;
@property (nonatomic, strong) NSString *filePath;

- (instancetype)initWithMisakaFile:(NSString *)filePath error:(NSError **)error;
- (BOOL)isValidMisakaPackage:(NSError **)error;

@end

@interface MisakaPackageManager : NSObject

+ (instancetype)sharedManager;

// Convert .misaka to .plumbum
- (BOOL)convertMisakaToPlumbum:(NSString *)misakaPath outputPath:(NSString *)outputPath error:(NSError **)error;

// Install .misaka directly
- (BOOL)installMisakaPackage:(NSString *)filePath error:(NSError **)error;

// Validate .misaka file
- (BOOL)validateMisakaFile:(NSString *)filePath error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END

//
//  MisakaPackage.m
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import "MisakaPackage.h"
#import "PackageManager.h"
#import <zlib.h>

@implementation MisakaPackage

- (instancetype)initWithMisakaFile:(NSString *)filePath error:(NSError **)error {
    self = [super init];
    if (self) {
        _filePath = filePath;
        
        if (![self parseMisakaFile:error]) {
            return nil;
        }
    }
    return self;
}

- (BOOL)parseMisakaFile:(NSError **)error {
    // .misaka files have a JSON header followed by package data
    // Format: [JSON metadata]\n[package data]
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:_filePath]) {
        if (error) {
            *error = [NSError errorWithDomain:@"MisakaPackage" 
                                         code:300 
                                     userInfo:@{NSLocalizedDescriptionKey: @"File does not exist"}];
        }
        return NO;
    }
    
    NSData *fileData = [NSData dataWithContentsOfFile:_filePath];
    if (!fileData) {
        if (error) {
            *error = [NSError errorWithDomain:@"MisakaPackage" 
                                         code:301 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to read file"}];
        }
        return NO;
    }
    
    // Find the separator between JSON and data
    NSString *fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSRange separatorRange = [fileString rangeOfString:@"\n---MISAKA-PACKAGE-DATA---\n"];
    
    if (separatorRange.location == NSNotFound) {
        // No separator, treat entire file as JSON metadata
        NSData *jsonData = [fileString dataUsingEncoding:NSUTF8StringEncoding];
        _metadata = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
        
        if (!_metadata) {
            return NO;
        }
    } else {
        // Parse JSON header
        NSString *jsonString = [fileString substringToIndex:separatorRange.location];
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        _metadata = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
        
        if (!_metadata) {
            return NO;
        }
        
        // Package data starts after separator
        // In a real implementation, you'd extract and process this
    }
    
    // Extract package info from metadata
    _packageID = _metadata[@"packageID"] ?: @"";
    _name = _metadata[@"name"] ?: _packageID;
    _version = _metadata[@"version"] ?: @"1.0";
    _description = _metadata[@"description"] ?: @"";
    _author = _metadata[@"author"] ?: @"Unknown";
    _section = _metadata[@"section"] ?: @"Utilities";
    _iconPath = _metadata[@"iconPath"];
    _installScript = _metadata[@"installScript"];
    _uninstallScript = _metadata[@"uninstallScript"];
    
    return YES;
}

- (BOOL)isValidMisakaPackage:(NSError **)error {
    // Check required fields
    if (!_packageID || _packageID.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"MisakaPackage" 
                                         code:302 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Missing package ID"}];
        }
        return NO;
    }
    
    if (!_name || _name.length == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"MisakaPackage" 
                                         code:303 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Missing package name"}];
        }
        return NO;
    }
    
    return YES;
}

@end

@implementation MisakaPackageManager

+ (instancetype)sharedManager {
    static MisakaPackageManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)convertMisakaToPlumbum:(NSString *)misakaPath outputPath:(NSString *)outputPath error:(NSError **)error {
    // Convert .misaka file to .plumbum format
    // This involves extracting the package data and creating a proper .deb structure
    
    MisakaPackage *misakaPackage = [[MisakaPackage alloc] initWithMisakaFile:misakaPath error:error];
    if (!misakaPackage) {
        return NO;
    }
    
    if (![misakaPackage isValidMisakaPackage:error]) {
        return NO;
    }
    
    // Create control file content
    NSMutableString *controlContent = [NSMutableString string];
    [controlContent appendFormat:@"Package: %@\n", misakaPackage.packageID];
    [controlContent appendFormat:@"Name: %@\n", misakaPackage.name];
    [controlContent appendFormat:@"Version: %@\n", misakaPackage.version];
    [controlContent appendFormat:@"Description: %@\n", misakaPackage.description];
    [controlContent appendFormat:@"Author: %@\n", misakaPackage.author];
    [controlContent appendFormat:@"Section: %@\n", misakaPackage.section];
    [controlContent appendFormat:@"Architecture: iphoneos-arm\n"];
    [controlContent appendFormat:@"Maintainer: %@\n", misakaPackage.author];
    
    if (misakaPackage.installScript) {
        [controlContent appendFormat:@"Install-Script: %@\n", misakaPackage.installScript];
    }
    
    if (misakaPackage.uninstallScript) {
        [controlContent appendFormat:@"Uninstall-Script: %@\n", misakaPackage.uninstallScript];
    }
    
    // In a real implementation, you would:
    // 1. Create the .deb directory structure (DEBIAN/, etc.)
    // 2. Write the control file
    // 3. Copy package files
    // 4. Create the ar archive
    
    // For now, just copy the file with .plumbum extension
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL success = [fm copyItemAtPath:misakaPath toPath:outputPath error:error];
    
    if (success) {
        NSLog(@"Converted %@ to %@", misakaPath, outputPath);
    }
    
    return success;
}

- (BOOL)installMisakaPackage:(NSString *)filePath error:(NSError **)error {
    // Convert to .plumbum first, then install
    NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString *plumbumPath = [tempDir stringByAppendingPathComponent:[[filePath lastPathComponent] stringByDeletingPathExtension]];
    plumbumPath = [plumbumPath stringByAppendingPathExtension:@"plumbum"];
    
    if (![self convertMisakaToPlumbum:filePath outputPath:plumbumPath error:error]) {
        [fm removeItemAtPath:tempDir error:nil];
        return NO;
    }
    
    // Create PlumbumPackage and install
    PlumbumPackage *package = [[PlumbumPackage alloc] init];
    package.packageID = [[filePath lastPathComponent] stringByDeletingPathExtension];
    package.filePath = plumbumPath;
    
    PackageManager *pm = [PackageManager sharedManager];
    BOOL success = [pm installPackage:package error:error];
    
    // Cleanup
    [fm removeItemAtPath:tempDir error:nil];
    
    return success;
}

- (BOOL)validateMisakaFile:(NSString *)filePath error:(NSError **)error {
    MisakaPackage *package = [[MisakaPackage alloc] initWithMisakaFile:filePath error:error];
    if (!package) {
        return NO;
    }
    
    return [package isValidMisakaPackage:error];
}

@end

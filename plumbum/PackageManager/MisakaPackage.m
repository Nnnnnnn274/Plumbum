//
//  MisakaPackage.m
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import "MisakaPackage.h"
#import "PackageManager.h"
#import <zlib.h>
#import <sys/utsname.h>

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
    // .misaka files are ZIP archives containing package data
    // They typically contain a Config.plist or similar metadata file
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:_filePath]) {
        if (error) {
            *error = [NSError errorWithDomain:@"MisakaPackage" 
                                         code:300 
                                     userInfo:@{NSLocalizedDescriptionKey: @"File does not exist"}];
        }
        return NO;
    }
    
    // Create temporary directory for extraction
    NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
    [fm createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    // Try to extract the ZIP archive
    BOOL extracted = [self extractZipFile:_filePath toDestination:tempDir error:error];
    
    if (!extracted) {
        // If ZIP extraction fails, try parsing as JSON (fallback for older format)
        return [self parseAsJSON:error];
    }
    
    // Look for Config.plist or Info.plist in the extracted files
    NSString *configPath = [self findConfigFileInDirectory:tempDir];
    
    if (configPath) {
        NSDictionary *configDict = [NSDictionary dictionaryWithContentsOfFile:configPath];
        if (configDict) {
            _metadata = configDict;
            [self extractPackageInfoFromConfig:configDict];
            
            // Cleanup
            [fm removeItemAtPath:tempDir error:nil];
            return YES;
        }
    }
    
    // If no config file found, try to parse as JSON from the original file
    [fm removeItemAtPath:tempDir error:nil];
    return [self parseAsJSON:error];
}

- (BOOL)extractZipFile:(NSString *)zipPath toDestination:(NSString *)destPath error:(NSError **)error {
    // Use system() to run unzip command (iOS-compatible)
    NSString *command = [NSString stringWithFormat:@"/usr/bin/unzip -q -o \"%@\" -d \"%@\"", zipPath, destPath];
    int result = system([command UTF8String]);
    
    if (result != 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"MisakaPackage" 
                                         code:302 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to extract ZIP archive"}];
        }
        return NO;
    }
    
    return YES;
}

- (NSString *)findConfigFileInDirectory:(NSString *)directory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    
    for (NSString *file in files) {
        NSString *fullPath = [directory stringByAppendingPathComponent:file];
        BOOL isDirectory = NO;
        [fm fileExistsAtPath:fullPath isDirectory:&isDirectory];
        
        if (isDirectory) {
            // Recursively search subdirectories
            NSString *found = [self findConfigFileInDirectory:fullPath];
            if (found) return found;
        } else {
            // Check for config files
            if ([file isEqualToString:@"Config.plist"] || 
                [file isEqualToString:@"Info.plist"] ||
                [file isEqualToString:@"package.plist"] ||
                [file isEqualToString:@"metadata.plist"]) {
                return fullPath;
            }
        }
    }
    
    return nil;
}

- (void)extractPackageInfoFromConfig:(NSDictionary *)config {
    // Extract package information from Config.plist
    _packageID = config[@"PackageID"] ?: config[@"CFBundleIdentifier"] ?: @"";
    _name = config[@"Name"] ?: config[@"CFBundleDisplayName"] ?: _packageID;
    _version = config[@"Version"] ?: config[@"CFBundleShortVersionString"] ?: @"1.0";
    _misakaDescription = config[@"Description"] ?: config[@"Description"] ?: @"";
    _author = config[@"Author"] ?: config[@"Author"] ?: @"Unknown";
    _section = config[@"Section"] ?: @"Utilities";
    _iconPath = config[@"Icon"] ?: config[@"IconPath"];
    _installScript = config[@"InstallScript"];
    _uninstallScript = config[@"UninstallScript"];
}

- (BOOL)parseAsJSON:(NSError **)error {
    // Fallback: try to parse as JSON (for older .misaka format)
    NSData *fileData = [NSData dataWithContentsOfFile:_filePath];
    if (!fileData) {
        if (error) {
            *error = [NSError errorWithDomain:@"MisakaPackage" 
                                         code:301 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to read file"}];
        }
        return NO;
    }
    
    NSString *fileString = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    if (!fileString) {
        if (error) {
            *error = [NSError errorWithDomain:@"MisakaPackage" 
                                         code:303 
                                     userInfo:@{NSLocalizedDescriptionKey: @"File is not valid UTF-8"}];
        }
        return NO;
    }
    
    // Try to parse as JSON directly
    NSData *jsonData = [fileString dataUsingEncoding:NSUTF8StringEncoding];
    _metadata = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:error];
    
    if (!_metadata) {
        return NO;
    }
    
    // Extract package info from metadata
    _packageID = _metadata[@"packageID"] ?: _metadata[@"PackageID"] ?: @"";
    _name = _metadata[@"name"] ?: _metadata[@"Name"] ?: _packageID;
    _version = _metadata[@"version"] ?: _metadata[@"Version"] ?: @"1.0";
    _misakaDescription = _metadata[@"description"] ?: _metadata[@"Description"] ?: @"";
    _author = _metadata[@"author"] ?: _metadata[@"Author"] ?: @"Unknown";
    _section = _metadata[@"section"] ?: _metadata[@"Section"] ?: @"Utilities";
    _iconPath = _metadata[@"iconPath"] ?: _metadata[@"Icon"];
    _installScript = _metadata[@"installScript"] ?: _metadata[@"InstallScript"];
    _uninstallScript = _metadata[@"uninstallScript"] ?: _metadata[@"UninstallScript"];
    
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
    [controlContent appendFormat:@"Description: %@\n", misakaPackage.misakaDescription];
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

//
//  PackageBuilder.m
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import "PackageBuilder.h"

@implementation PackageBuilder

+ (instancetype)sharedBuilder {
    static PackageBuilder *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (BOOL)convertDebToPlumbum:(NSString *)debPath outputPath:(NSString *)outputPath error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Check if .deb file exists
    if (![fm fileExistsAtPath:debPath]) {
        if (error) {
            *error = [NSError errorWithDomain:@"PackageBuilder" 
                                         code:400 
                                     userInfo:@{NSLocalizedDescriptionKey: @".deb file does not exist"}];
        }
        return NO;
    }
    
    // Simply copy and rename the file
    // In a real implementation, you might want to:
    // 1. Extract the .deb
    // 2. Modify the control file
    // 3. Rebuild as .plumbum
    
    BOOL success = [fm copyItemAtPath:debPath toPath:outputPath error:error];
    
    if (success) {
        NSLog(@"Converted .deb to .plumbum: %@", outputPath);
    }
    
    return success;
}

- (BOOL)createPlumbumFromDirectory:(NSString *)directoryPath 
                          outputPath:(NSString *)outputPath 
                           control:(NSDictionary *)controlData 
                              error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Validate directory structure
    if (![self validatePackageDirectory:directoryPath error:error]) {
        return NO;
    }
    
    // Create DEBIAN directory if it doesn't exist
    NSString *debianDir = [directoryPath stringByAppendingPathComponent:@"DEBIAN"];
    if (![fm fileExistsAtPath:debianDir]) {
        [fm createDirectoryAtPath:debianDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // Write control file
    NSMutableString *controlContent = [NSMutableString string];
    
    [controlContent appendFormat:@"Package: %@\n", controlData[@"Package"] ?: @"unknown"];
    [controlContent appendFormat:@"Name: %@\n", controlData[@"Name"] ?: controlData[@"Package"]];
    [controlContent appendFormat:@"Version: %@\n", controlData[@"Version"] ?: @"1.0"];
    [controlContent appendFormat:@"Description: %@\n", controlData[@"Description"] ?: @""];
    [controlContent appendFormat:@"Author: %@\n", controlData[@"Author"] ?: @"Unknown"];
    [controlContent appendFormat:@"Section: %@\n", controlData[@"Section"] ?: @"Utilities"];
    [controlContent appendFormat:@"Architecture: %@\n", controlData[@"Architecture"] ?: @"iphoneos-arm"];
    [controlContent appendFormat:@"Maintainer: %@\n", controlData[@"Maintainer"] ?: @"Unknown"];
    
    if (controlData[@"Depends"]) {
        [controlContent appendFormat:@"Depends: %@\n", controlData[@"Depends"]];
    }
    
    NSString *controlPath = [debianDir stringByAppendingPathComponent:@"control"];
    [controlContent writeToFile:controlPath atomically:YES encoding:NSUTF8StringEncoding error:error];
    
    // In a real implementation, you would:
    // 1. Create control.tar.gz
    // 2. Create data.tar.gz
    // 3. Create the ar archive (.deb/.plumbum)
    
    // For now, just create a placeholder file
    [fm createFileAtPath:outputPath contents:nil attributes:nil];
    
    NSLog(@"Created .plumbum package at: %@", outputPath);
    return YES;
}

- (BOOL)createMisakaFromDirectory:(NSString *)directoryPath 
                        outputPath:(NSString *)outputPath 
                         control:(NSDictionary *)controlData 
                      metadata:(NSDictionary *)metadata 
                            error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    // Validate directory structure
    if (![self validatePackageDirectory:directoryPath error:error]) {
        return NO;
    }
    
    // Create JSON metadata header
    NSMutableDictionary *fullMetadata = [NSMutableDictionary dictionaryWithDictionary:controlData];
    [fullMetadata addEntriesFromDictionary:metadata];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:fullMetadata options:NSJSONWritingPrettyPrinted error:error];
    if (!jsonData) {
        return NO;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // Create .misaka file with JSON header
    NSMutableString *misakaContent = [NSMutableString string];
    [misakaContent appendString:jsonString];
    [misakaContent appendString:@"\n---MISAKA-PACKAGE-DATA---\n"];
    
    // In a real implementation, you would append the actual package data here
    // For now, just write the header
    
    [misakaContent writeToFile:outputPath atomically:YES encoding:NSUTF8StringEncoding error:error];
    
    NSLog(@"Created .misaka package at: %@", outputPath);
    return YES;
}

- (BOOL)validatePackageDirectory:(NSString *)directoryPath error:(NSError **)error {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    if (![fm fileExistsAtPath:directoryPath]) {
        if (error) {
            *error = [NSError errorWithDomain:@"PackageBuilder" 
                                         code:401 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Directory does not exist"}];
        }
        return NO;
    }
    
    BOOL isDirectory;
    if (![fm fileExistsAtPath:directoryPath isDirectory:&isDirectory] || !isDirectory) {
        if (error) {
            *error = [NSError errorWithDomain:@"PackageBuilder" 
                                         code:402 
                                     userInfo:@{NSLocalizedDescriptionKey: @"Path is not a directory"}];
        }
        return NO;
    }
    
    return YES;
}

@end

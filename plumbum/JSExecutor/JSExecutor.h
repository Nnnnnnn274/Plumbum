//
//  JSExecutor.h
//  plumbum
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSExecutor : NSObject

+ (instancetype)sharedExecutor;

- (BOOL)executeJavaScriptFromFile:(NSString *)filePath error:(NSError **)error;
- (BOOL)executeJavaScriptFromString:(NSString *)script error:(NSError **)error;
- (JSContext *)context;

@end

NS_ASSUME_NONNULL_END

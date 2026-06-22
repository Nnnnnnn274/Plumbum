//
//  JSExecutor.m
//  plumbum
//
//

#import "JSExecutor.h"
#import "../TaskRop/RemoteCall.h"

@interface JSExecutor ()
@property (nonatomic, strong, readwrite) JSContext *context;
@end

@implementation JSExecutor

+ (instancetype)sharedExecutor {
    static JSExecutor *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _context = [[JSContext alloc] init];
        [self setupContext];
    }
    return self;
}

- (void)setupContext {
    // Setup JavaScript context with RemoteCall bindings
    __weak typeof(self) weakSelf = self;
    
    // Remote call function
    _context[@"remoteCall"] = ^(NSString *functionName, uint64_t x0, uint64_t x1, uint64_t x2, uint64_t x3, uint64_t x4, uint64_t x5, uint64_t x6, uint64_t x7) {
        uint64_t result = do_remote_call_stable(100, [functionName UTF8String], x0, x1, x2, x3, x4, x5, x6, x7);
        return @(result);
    };
    
    // Remote read function
    _context[@"remoteRead"] = ^(uint64_t address, uint64_t size) {
        void *buffer = malloc(size);
        if (buffer) {
            bool success = remote_read(address, buffer, size);
            if (success) {
                NSData *data = [NSData dataWithBytes:buffer length:size];
                free(buffer);
                return data;
            }
            free(buffer);
        }
        return [NSData data];
    };
    
    // Remote write function
    _context[@"remoteWrite"] = ^(uint64_t address, NSData *data) {
        bool success = remote_write(address, data.bytes, data.length);
        return @(success);
    };
    
    // Remote write64 function
    _context[@"remoteWrite64"] = ^(uint64_t address, uint64_t value) {
        bool success = remote_write64(address, value);
        return @(success);
    };
    
    // Remote hexdump function
    _context[@"remoteHexdump"] = ^(uint64_t address, uint64_t size) {
        remote_hexdump(address, size);
    };
    
    // Log function
    _context[@"log"] = ^(NSString *message) {
        NSLog(@"[JS] %@", message);
    };
    
    // Exception handler
    _context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
        NSLog(@"JavaScript exception: %@", exception);
    };
}

- (BOOL)executeJavaScriptFromFile:(NSString *)filePath error:(NSError **)error {
    NSString *script = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:error];
    if (!script) {
        return NO;
    }
    
    return [self executeJavaScriptFromString:script error:error];
}

- (BOOL)executeJavaScriptFromString:(NSString *)script error:(NSError **)error {
    @try {
        JSValue *result = [_context evaluateScript:script];
        if (_context.exception) {
            if (error) {
                *error = [NSError errorWithDomain:@"JSExecutor" 
                                             code:100 
                                         userInfo:@{NSLocalizedDescriptionKey: _context.exception.toString}];
            }
            return NO;
        }
        return YES;
    } @catch (NSException *exception) {
        if (error) {
            *error = [NSError errorWithDomain:@"JSExecutor" 
                                         code:101 
                                     userInfo:@{NSLocalizedDescriptionKey: exception.reason}];
        }
        return NO;
    }
}

@end

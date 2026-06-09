//
//  AppDelegate.m
//  plumbum
//
//  Created by seo on 3/24/26.
//

#import "AppDelegate.h"
#import "kexploit/kexploit_opa334.h"
#import "utils/sandbox.h"
#import "research/sandbox_research.h"
#import "utils/process.h"
#import "TaskRop/RemoteCall.h"
#import "LogTextView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Initialize logging
    log_init();
    
    // Run exploit on app launch
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"Running kernel exploit...");
        kexploit_opa334();
        NSLog(@"Kernel exploit completed");
        
        // Run sandbox escape on app launch
        NSLog(@"Running sandbox escape...");
        const char* target = "SpringBoard";
        init_remote_call(target, false);
        
        uint64_t memRemote = 0;
        uint64_t pathRemote = memRemote;
        remote_writeStr(pathRemote, "/");
        
        const char* appSandboxReadExt = "com.apple.app-sandbox.read-write";
        uint64_t sandboxExtensionEntry = memRemote + 0x100;
        remote_writeStr(sandboxExtensionEntry, appSandboxReadExt);
        
        destroy_remote_call();
        NSLog(@"Sandbox escape completed");
    });
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end

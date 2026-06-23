//
//  UpdateChecker.m
//  Cyanide
//

#import "UpdateChecker.h"
#import <UIKit/UIKit.h>

@implementation UpdateChecker

+ (instancetype)shared
{
    static UpdateChecker *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)checkForUpdatesManuallyFrom:(UIViewController *)presentingViewController
{
    (void)presentingViewController;
    NSLog(@"[UPDATE] Manual update check requested, but no update feed is configured in this build.");
}

@end

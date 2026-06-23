//
//  UpdateChecker.h
//  Cyanide
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIViewController;

@interface UpdateChecker : NSObject

+ (instancetype)shared;
- (void)checkForUpdatesManuallyFrom:(UIViewController *)presentingViewController;

@end

NS_ASSUME_NONNULL_END

//
//  PatreonAuth.h
//  Cyanide
//
//  Lightweight Patreon state helpers used by Settings and Installer.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const kCyanidePatreonStatusDidChangeNotification;

BOOL cyanide_is_patron(void);
BOOL cyanide_is_creator(void);

BOOL cyanide_patreon_is_linked(void);
NSString * _Nullable cyanide_patreon_display_name(void);
NSString * _Nullable cyanide_patreon_tier_title(void);
NSInteger cyanide_patreon_pledge_cents(void);
NSDate * _Nullable cyanide_patreon_last_refresh_date(void);
NSURL *cyanide_patreon_join_url(void);

void cyanide_patreon_authenticate(UIViewController *host,
                                  void (^completion)(BOOL ok, NSError * _Nullable err));
void cyanide_patreon_refresh(void (^ _Nullable completion)(BOOL ok, NSError * _Nullable err));
void cyanide_patreon_sign_out(void);

NS_ASSUME_NONNULL_END

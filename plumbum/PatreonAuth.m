//
//  PatreonAuth.m
//  Cyanide
//

#import "PatreonAuth.h"

NSString * const kCyanidePatreonStatusDidChangeNotification = @"CyanidePatreonStatusDidChangeNotification";

static NSString * const kPatreonLinkedKey = @"CyanidePatreonLinked";
static NSString * const kPatreonIsPatronKey = @"CyanidePatreonIsPatron";
static NSString * const kPatreonIsCreatorKey = @"CyanidePatreonIsCreator";
static NSString * const kPatreonDisplayNameKey = @"CyanidePatreonDisplayName";
static NSString * const kPatreonTierTitleKey = @"CyanidePatreonTierTitle";
static NSString * const kPatreonPledgeCentsKey = @"CyanidePatreonPledgeCents";
static NSString * const kPatreonLastRefreshDateKey = @"CyanidePatreonLastRefreshDate";

static NSUserDefaults *cyanide_patreon_defaults(void)
{
    return [NSUserDefaults standardUserDefaults];
}

static void cyanide_patreon_post_status_change(void)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCyanidePatreonStatusDidChangeNotification
                                                        object:nil];
}

BOOL cyanide_patreon_is_linked(void)
{
    return [cyanide_patreon_defaults() boolForKey:kPatreonLinkedKey];
}

BOOL cyanide_is_patron(void)
{
    NSUserDefaults *d = cyanide_patreon_defaults();
    return [d boolForKey:kPatreonLinkedKey] && [d boolForKey:kPatreonIsPatronKey];
}

BOOL cyanide_is_creator(void)
{
    NSUserDefaults *d = cyanide_patreon_defaults();
    return [d boolForKey:kPatreonLinkedKey] && [d boolForKey:kPatreonIsCreatorKey];
}

NSString *cyanide_patreon_display_name(void)
{
    return cyanide_patreon_is_linked() ? [cyanide_patreon_defaults() stringForKey:kPatreonDisplayNameKey] : nil;
}

NSString *cyanide_patreon_tier_title(void)
{
    return cyanide_patreon_is_linked() ? [cyanide_patreon_defaults() stringForKey:kPatreonTierTitleKey] : nil;
}

NSInteger cyanide_patreon_pledge_cents(void)
{
    return cyanide_patreon_is_linked() ? [cyanide_patreon_defaults() integerForKey:kPatreonPledgeCentsKey] : 0;
}

NSDate *cyanide_patreon_last_refresh_date(void)
{
    return cyanide_patreon_is_linked() ? [cyanide_patreon_defaults() objectForKey:kPatreonLastRefreshDateKey] : nil;
}

NSURL *cyanide_patreon_join_url(void)
{
    return [NSURL URLWithString:@"https://www.patreon.com/zeroxjf"];
}

void cyanide_patreon_authenticate(UIViewController *host,
                                  void (^completion)(BOOL ok, NSError * _Nullable err))
{
    (void)host;
    NSError *err = [NSError errorWithDomain:@"CyanidePatreon"
                                       code:1
                                   userInfo:@{NSLocalizedDescriptionKey :
                                                  @"Patreon authentication is not available in this build."}];
    if (completion) completion(NO, err);
}

void cyanide_patreon_refresh(void (^completion)(BOOL ok, NSError * _Nullable err))
{
    NSUserDefaults *d = cyanide_patreon_defaults();
    if ([d boolForKey:kPatreonLinkedKey]) {
        [d setObject:[NSDate date] forKey:kPatreonLastRefreshDateKey];
        [d synchronize];
        cyanide_patreon_post_status_change();
    }
    if (completion) completion(YES, nil);
}

void cyanide_patreon_sign_out(void)
{
    NSUserDefaults *d = cyanide_patreon_defaults();
    [d removeObjectForKey:kPatreonLinkedKey];
    [d removeObjectForKey:kPatreonIsPatronKey];
    [d removeObjectForKey:kPatreonIsCreatorKey];
    [d removeObjectForKey:kPatreonDisplayNameKey];
    [d removeObjectForKey:kPatreonTierTitleKey];
    [d removeObjectForKey:kPatreonPledgeCentsKey];
    [d removeObjectForKey:kPatreonLastRefreshDateKey];
    [d synchronize];
    cyanide_patreon_post_status_change();
}

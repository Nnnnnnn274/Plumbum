//
//  BuiltInTweaks.m
//  plumbum
//

#import "BuiltInTweaks.h"

@implementation BuiltInTweak

@end

@interface BuiltInTweaks ()
@property (nonatomic, strong) NSArray<BuiltInTweak *> *tweaks;
@end

@implementation BuiltInTweaks

+ (instancetype)sharedTweaks {
    static BuiltInTweaks *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadBuiltInTweaks];
    }
    return self;
}

- (void)loadBuiltInTweaks {
    NSMutableArray *tweaks = [NSMutableArray array];
    
    // Status Bar
    [tweaks addObject:[self tweakWithIdentifier:@"statbar"
                                            name:@"StatBar"
                                        category:@"Status Bar"
                                     description:@"Battery temperature and free-RAM overlay anchored to the SpringBoard status bar"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"nsbar"
                                            name:@"NSBar"
                                        category:@"Status Bar"
                                     description:@"Compact live download/upload speed overlay for the status bar"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"nicebarlite"
                                            name:@"NiceBar Lite"
                                        category:@"Status Bar"
                                     description:@"Configurable status-bar-adjacent labels for custom text, date/time, battery, memory, traffic, uptime, IP address, disk, thermal state"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    // Home Screen Layout
    [tweaks addObject:[self tweakWithIdentifier:@"sbcustomizer"
                                            name:@"SBCustomizer"
                                        category:@"Home Screen Layout"
                                     description:@"Dock icon count, home-screen columns/rows, and hidden icon labels"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"darksword_layout"
                                            name:@"DarkSword Layout"
                                        category:@"Home Screen Layout"
                                     description:@"Extra padding around the home grid and dock, plus per-icon scale"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    // Performance
    [tweaks addObject:[self tweakWithIdentifier:@"powercuff"
                                            name:@"Powercuff"
                                        category:@"Performance"
                                     description:@"CPU/GPU underclocking through simulated thermalmonitord pressure levels"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    // SpringBoard Tweaks
    [tweaks addObject:[self tweakWithIdentifier:@"darksword_tweaks"
                                            name:@"DarkSword Tweaks"
                                        category:@"SpringBoard Tweaks"
                                     description:@"Various SpringBoard modifications"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"darksword_drag"
                                            name:@"DarkSword Drag"
                                        category:@"SpringBoard Tweaks"
                                     description:@"Icon drag modifications"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"hide_home_bar"
                                            name:@"Hide Home Bar"
                                        category:@"SpringBoard Tweaks"
                                     description:@"Hides the home indicator bar"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"killallapps"
                                            name:@"Kill All Apps"
                                        category:@"SpringBoard Tweaks"
                                     description:"Kill all running applications"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    // System Updates
    [tweaks addObject:[self tweakWithIdentifier:@"darksword_ota"
                                            name:@"Disable OTA Updates"
                                        category:@"System Updates"
                                     description:@"Toggles launchd OTA disabled.plist to block or unblock update prompts"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    // Beta
    [tweaks addObject:[self tweakWithIdentifier:@"gravitylite"
                                            name:@"Gravity Lite"
                                        category:@"Beta"
                                     description:@"Applies UIDynamicAnimator physics to home-screen and dock icons"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"axonlite"
                                            name:@"Axon Lite"
                                        category:@"Beta"
                                     description:@"Groups Notification Center requests by app with a SpringBoard overlay"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"snowboardlite"
                                            name:@"SnowBoard Lite"
                                        category:@"Beta"
                                     description:@"Imports SnowBoard/IconBundles-style theme folders or archives into local theme library"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"livewp"
                                            name:@"LiveWP"
                                        category:@"Beta"
                                     description:@"Plays a selected MP4/MOV/M4V behind SpringBoard's home and lock screen windows"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"location_sim"
                                            name:@"Location Simulator"
                                        category:@"Beta"
                                     description:@"Drives Apple's CoreLocation simulation path from a RemoteCall host process"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"call_recording_sound"
                                            name:@"Call Recording Sound"
                                        category:@"Beta"
                                     description:@"Replaces CallServices StartDisclosureWithTone and StopDisclosure audio files with silent payloads"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"nano_registry"
                                            name:@"Nano Registry"
                                        category:@"Beta"
                                     description:@"Nano registry modifications"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"appswitchergrid"
                                            name:@"App Switcher Grid"
                                        category:@"Beta"
                                     description:"Grid layout for app switcher"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    self.tweaks = [tweaks copy];
}

- (BuiltInTweak *)tweakWithIdentifier:(NSString *)identifier
                                       name:(NSString *)name
                                   category:(NSString *)category
                                description:(NSString *)description
                                     isBeta:(BOOL)isBeta
                          isExperimental:(BOOL)isExperimental {
    BuiltInTweak *tweak = [[BuiltInTweak alloc] init];
    tweak.identifier = identifier;
    tweak.name = name;
    tweak.category = category;
    tweak.description = description;
    tweak.isBeta = isBeta;
    tweak.isExperimental = isExperimental;
    return tweak;
}

- (NSArray<BuiltInTweak *> *)allTweaks {
    return self.tweaks;
}

- (NSArray<BuiltInTweak *> *)tweaksInCategory:(NSString *)category {
    return [self.tweaks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category == %@", category]];
}

- (BuiltInTweak *)tweakWithIdentifier:(NSString *)identifier {
    return [self.tweaks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", identifier]].firstObject;
}

@end

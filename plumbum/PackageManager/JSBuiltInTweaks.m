//
//  JSBuiltInTweaks.m
//  plumbum
//

#import "JSBuiltInTweaks.h"

@implementation JSBuiltInTweak

@end

@interface JSBuiltInTweaks ()
@property (nonatomic, strong) NSArray<JSBuiltInTweak *> *tweaks;
@end

@implementation JSBuiltInTweaks

+ (instancetype)sharedTweaks {
    static JSBuiltInTweaks *sharedInstance = nil;
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
                                      scriptPath:@"statbar.js"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"nsbar"
                                            name:@"NSBar"
                                        category:@"Status Bar"
                                     description:@"Compact live download/upload speed overlay for the status bar"
                                      scriptPath:@"nsbar.js"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"nicebarlite"
                                            name:@"NiceBar Lite"
                                        category:@"Status Bar"
                                     description:@"Configurable status-bar-adjacent labels for custom text, date/time, battery, memory, traffic, uptime, IP address, disk, thermal state"
                                      scriptPath:@"nicebarlite.js"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    // Home Screen Layout
    [tweaks addObject:[self tweakWithIdentifier:@"sbcustomizer"
                                            name:@"SBCustomizer"
                                        category:@"Home Screen Layout"
                                     description:@"Dock icon count, home-screen columns/rows, and hidden icon labels"
                                      scriptPath:@"sbcustomizer.js"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"homelayoutextras"
                                            name:@"Home Layout Extras"
                                        category:@"Home Screen Layout"
                                     description:@"Extra padding around the home grid and dock, plus per-icon scale"
                                      scriptPath:@"homelayoutextras.js"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    // Performance
    [tweaks addObject:[self tweakWithIdentifier:@"powercuff"
                                            name:@"Powercuff"
                                        category:@"Performance"
                                     description:@"CPU/GPU underclocking through simulated thermalmonitord pressure levels"
                                      scriptPath:@"powercuff.js"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    // SpringBoard Tweaks
    [tweaks addObject:[self tweakWithIdentifier:@"disableapplibrary"
                                            name:@"Disable App Library"
                                        category:@"SpringBoard Tweaks"
                                     description:@"Removes the App Library page past the last home screen"
                                      scriptPath:@"disableapplibrary.js"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"disableiconflyin"
                                            name:@"Disable Icon Fly-In"
                                        category:@"SpringBoard Tweaks"
                                     description:@"Skips the spring-in animation when icons appear"
                                      scriptPath:@"disableiconflyin.js"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"zerowakeanimation"
                                            name:@"Zero Wake Animation"
                                        category:@"SpringBoard Tweaks"
                                     description:@"Snaps the display on instantly when waking"
                                      scriptPath:@"zerowakeanimation.js"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"zerobacklightfade"
                                            name:@"Zero Backlight Fade"
                                        category:@"SpringBoard Tweaks"
                                     description:@"Instant lock/unlock backlight"
                                      scriptPath:@"zerobacklightfade.js"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"doubletaplock"
                                            name:@"Double-Tap to Lock"
                                        category:@"SpringBoard Tweaks"
                                     description:@"Lock the device with a wallpaper double-tap"
                                      scriptPath:@"doubletaplock.js"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    // System Updates
    [tweaks addObject:[self tweakWithIdentifier:@"disableota"
                                            name:@"Disable OTA Updates"
                                        category:@"System Updates"
                                     description:@"Toggles launchd OTA disabled.plist to block or unblock update prompts"
                                      scriptPath:@"disableota.js"
                                          isBeta:NO
                                   isExperimental:NO]];
    
    // Beta
    [tweaks addObject:[self tweakWithIdentifier:@"gravitylite"
                                            name:@"Gravity Lite"
                                        category:@"Beta"
                                     description:@"Applies UIDynamicAnimator physics to home-screen and dock icons"
                                      scriptPath:@"gravitylite.js"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"axonlite"
                                            name:@"Axon Lite"
                                        category:@"Beta"
                                     description:@"Groups Notification Center requests by app with a SpringBoard overlay"
                                      scriptPath:@"axonlite.js"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"plumbumthemer"
                                            name:@"Plumbum Themer"
                                        category:@"Beta"
                                     description:@"Per-bundle icon theme engine. Walks SpringBoard's SBIconView hierarchy and swaps each icon's image"
                                      scriptPath:@"plumbumthemer.js"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"snowboardlite"
                                            name:@"SnowBoard Lite"
                                        category:@"Beta"
                                     description:@"Imports SnowBoard/IconBundles-style theme folders or archives into local theme library"
                                      scriptPath:@"snowboardlite.js"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"livewp"
                                            name:@"LiveWP"
                                        category:@"Beta"
                                     description:@"Plays a selected MP4/MOV/M4V behind SpringBoard's home and lock screen windows"
                                      scriptPath:@"livewp.js"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"watchpairingoverride"
                                            name:@"Watch Pairing Override"
                                        category:@"Beta"
                                     description:@"Edits the watchOS pairing range stored on the iPhone"
                                      scriptPath:@"watchpairingoverride.js"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"locationsimulator"
                                            name:@"Location Simulator"
                                        category:@"Beta"
                                     description:@"Drives Apple's CoreLocation simulation path from a RemoteCall host process"
                                      scriptPath:@"locationsimulator.js"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"callrecordingsound"
                                            name:@"Call Recording Sound"
                                        category:@"Beta"
                                     description:@"Replaces CallServices StartDisclosureWithTone and StopDisclosure audio files with silent payloads"
                                      scriptPath:@"callrecordingsound.js"
                                          isBeta:YES
                                   isExperimental:NO]];
    
    // Experimental
    [tweaks addObject:[self tweakWithIdentifier:@"dynamicstagelite"
                                            name:@"Dynamic Stage Lite"
                                        category:@"Experimental"
                                     description:@"Brings Stage Manager-style split-view to iPhone over RemoteCall"
                                      scriptPath:@"dynamicstagelite.js"
                                          isBeta:NO
                                   isExperimental:YES]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"signalreadouts"
                                            name:@"Signal Readouts"
                                        category:@"Experimental"
                                     description:@"Replaces signal-strength glyphs with live numeric readouts"
                                      scriptPath:@"signalreadouts.js"
                                          isBeta:NO
                                   isExperimental:YES]];
    
    [tweaks addObject:[self tweakWithIdentifier:@"typebanner"
                                            name:@"TypeBanner"
                                        category:@"Experimental"
                                     description:@"Shows a pill banner below the Dynamic Island when Messages shows a typing indicator"
                                      scriptPath:@"typebanner.js"
                                          isBeta:NO
                                   isExperimental:YES]];
    
    self.tweaks = [tweaks copy];
}

- (JSBuiltInTweak *)tweakWithIdentifier:(NSString *)identifier
                                       name:(NSString *)name
                                   category:(NSString *)category
                                description:(NSString *)description
                                 scriptPath:(NSString *)scriptPath
                                     isBeta:(BOOL)isBeta
                          isExperimental:(BOOL)isExperimental {
    JSBuiltInTweak *tweak = [[JSBuiltInTweak alloc] init];
    tweak.identifier = identifier;
    tweak.name = name;
    tweak.category = category;
    tweak.description = description;
    tweak.scriptPath = scriptPath;
    tweak.isBeta = isBeta;
    tweak.isExperimental = isExperimental;
    return tweak;
}

- (NSArray<JSBuiltInTweak *> *)allTweaks {
    return self.tweaks;
}

- (NSArray<JSBuiltInTweak *> *)tweaksInCategory:(NSString *)category {
    return [self.tweaks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"category == %@", category]];
}

- (JSBuiltInTweak *)tweakWithIdentifier:(NSString *)identifier {
    return [self.tweaks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier == %@", identifier]].firstObject;
}

- (NSString *)scriptContentForTweak:(JSBuiltInTweak *)tweak {
    NSString *scriptPath = [[NSBundle mainBundle] pathForResource:tweak.scriptPath.stringByDeletingPathExtension
                                                           ofType:tweak.scriptPath.pathExtension
                                                      inDirectory:@"BuiltInTweaks"];
    
    if (!scriptPath) {
        NSLog(@"Failed to find built-in tweak script: %@", tweak.scriptPath);
        return @"";
    }
    
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Failed to load built-in tweak script: %@", error);
        return @"";
    }
    return content;
}

@end

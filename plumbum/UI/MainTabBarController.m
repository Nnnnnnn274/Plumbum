//
//  MainTabBarController.m
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import "MainTabBarController.h"
#import "SileoColors.h"
#import "TweaksViewController.h"
#import "SourcesViewController.h"
#import "LogsViewController.h"
#import "SettingsViewController.h"

@interface MainTabBarController ()
@end

@implementation MainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTabBar];
    [self setupViewControllers];
}

- (void)setupTabBar {
    if (@available(iOS 15.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [SileoColors background];
        
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors sileoBlue]};
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors tertiaryText]};
        
        self.tabBar.standardAppearance = appearance;
        self.tabBar.scrollEdgeAppearance = appearance;
    } else {
        self.tabBar.barTintColor = [SileoColors background];
        self.tabBar.tintColor = [SileoColors sileoBlue];
        self.tabBar.unselectedItemTintColor = [SileoColors tertiaryText];
    }
    
    self.tabBar.translucent = NO;
}

- (void)setupViewControllers {
    // Tweaks tab
    TweaksViewController *tweaksVC = [[TweaksViewController alloc] init];
    UINavigationController *tweaksNav = [[UINavigationController alloc] initWithRootViewController:tweaksVC];
    tweaksNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tweaks" 
                                                         image:[UIImage systemImageNamed:@"wrench.and.screwdriver"] 
                                                 selectedImage:[UIImage systemImageNamed:@"wrench.and.screwdriver.fill"]];
    
    // Sources tab
    SourcesViewController *sourcesVC = [[SourcesViewController alloc] init];
    UINavigationController *sourcesNav = [[UINavigationController alloc] initWithRootViewController:sourcesVC];
    sourcesNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Sources" 
                                                          image:[UIImage systemImageNamed:@"globe"] 
                                                  selectedImage:[UIImage systemImageNamed:@"globe.fill"]];
    
    // Logs tab
    LogsViewController *logsVC = [[LogsViewController alloc] init];
    UINavigationController *logsNav = [[UINavigationController alloc] initWithRootViewController:logsVC];
    logsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Logs" 
                                                       image:[UIImage systemImageNamed:@"doc.text"] 
                                               selectedImage:[UIImage systemImageNamed:@"doc.text.fill"]];
    
    // Settings tab
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    UINavigationController *settingsNav = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" 
                                                           image:[UIImage systemImageNamed:@"gear"] 
                                                   selectedImage:[UIImage systemImageNamed:@"gear.fill"]];
    
    self.viewControllers = @[tweaksNav, sourcesNav, logsNav, settingsNav];
}

@end

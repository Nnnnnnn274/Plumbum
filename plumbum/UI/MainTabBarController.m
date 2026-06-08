//
//  MainTabBarController.m
//  plumbum
//
//  Created by seo on 6/7/26.
//

#import "MainTabBarController.h"
#import "SileoColors.h"
#import "PackageListViewController.h"
#import "SourcesViewController.h"
#import "ExploitViewController.h"
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
    // Packages tab
    PackageListViewController *packagesVC = [[PackageListViewController alloc] init];
    UINavigationController *packagesNav = [[UINavigationController alloc] initWithRootViewController:packagesVC];
    packagesNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Packages" 
                                                           image:[UIImage systemImageNamed:@"square.stack"] 
                                                   selectedImage:[UIImage systemImageNamed:@"square.stack.fill"]];
    
    // Sources tab
    SourcesViewController *sourcesVC = [[SourcesViewController alloc] init];
    UINavigationController *sourcesNav = [[UINavigationController alloc] initWithRootViewController:sourcesVC];
    sourcesNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Sources" 
                                                          image:[UIImage systemImageNamed:@"globe"] 
                                                  selectedImage:[UIImage systemImageNamed:@"globe.fill"]];
    
    // Exploit tab
    ExploitViewController *exploitVC = [[ExploitViewController alloc] init];
    UINavigationController *exploitNav = [[UINavigationController alloc] initWithRootViewController:exploitVC];
    exploitNav.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Exploit" 
                                                          image:[UIImage systemImageNamed:@"bolt"] 
                                                  selectedImage:[UIImage systemImageNamed:@"bolt.fill"]];
    
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
    
    self.viewControllers = @[packagesNav, sourcesNav, exploitNav, logsNav, settingsNav];
}

@end

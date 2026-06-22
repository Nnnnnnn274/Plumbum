//
//  MainTabBarController.m
//  plumbum
//

#import "MainTabBarController.h"
#import "SileoColors.h"
#import "TweaksViewController.h"
#import "SourcesViewController.h"
#import "LogsViewController.h"
#import "LogsOnlyViewController.h"
#import "SavedPackagesViewController.h"
#import "JSQuickLoaderViewController.h"
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

        // Selected: cyan
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = @{
            NSForegroundColorAttributeName: [SileoColors sileoBlue],
            NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightSemibold]
        };
        appearance.stackedLayoutAppearance.selected.iconColor = [SileoColors sileoBlue];

        // Unselected: muted
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = @{
            NSForegroundColorAttributeName: [SileoColors tertiaryText],
            NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightMedium]
        };
        appearance.stackedLayoutAppearance.normal.iconColor = [SileoColors tertiaryText];

        // Hairline separator
        UITabBarItemStateAppearance *normalState = appearance.stackedLayoutAppearance.normal;
        appearance.shadowImage = [UIImage new];
        appearance.shadowColor = [SileoColors separatorColor];

        self.tabBar.standardAppearance = appearance;
        self.tabBar.scrollEdgeAppearance = appearance;
    } else {
        self.tabBar.barTintColor = [SileoColors background];
        self.tabBar.tintColor = [SileoColors sileoBlue];
        self.tabBar.unselectedItemTintColor = [SileoColors tertiaryText];
    }

    self.tabBar.translucent = NO;
}

- (UINavigationController *)wrapInNav:(UIViewController *)vc {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self applyNavAppearance:nav];
    return nav;
}

- (void)applyNavAppearance:(UINavigationController *)nav {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [SileoColors background];
        appearance.titleTextAttributes = @{
            NSForegroundColorAttributeName: [SileoColors primaryText],
            NSFontAttributeName: [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]
        };
        appearance.shadowColor = [SileoColors separatorColor];
        nav.navigationBar.standardAppearance = appearance;
        nav.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        nav.navigationBar.barTintColor = [SileoColors background];
        nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors primaryText]};
    }
    nav.navigationBar.tintColor = [SileoColors sileoBlue];
    nav.navigationBar.translucent = NO;
}

- (void)setupViewControllers {
    // Tweaks
    TweaksViewController *tweaksVC = [[TweaksViewController alloc] init];
    UINavigationController *tweaksNav = [self wrapInNav:tweaksVC];
    tweaksNav.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"Tweaks"
                image:[UIImage systemImageNamed:@"wrench.and.screwdriver"]
        selectedImage:[UIImage systemImageNamed:@"wrench.and.screwdriver.fill"]];

    // Sources
    SourcesViewController *sourcesVC = [[SourcesViewController alloc] init];
    UINavigationController *sourcesNav = [self wrapInNav:sourcesVC];
    sourcesNav.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"Sources"
                image:[UIImage systemImageNamed:@"globe"]
        selectedImage:[UIImage systemImageNamed:@"globe.fill"]];

    // Saved
    SavedPackagesViewController *savedVC = [[SavedPackagesViewController alloc] init];
    UINavigationController *savedNav = [self wrapInNav:savedVC];
    savedNav.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"Saved"
                image:[UIImage systemImageNamed:@"bookmark"]
        selectedImage:[UIImage systemImageNamed:@"bookmark.fill"]];

    // Logs tab (read-only logs view)
    LogsOnlyViewController *logsVC = [[LogsOnlyViewController alloc] init];
    UINavigationController *logsNav = [self wrapInNav:logsVC];
    logsNav.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"Logs"
                image:[UIImage systemImageNamed:@"doc.text"]
        selectedImage:[UIImage systemImageNamed:@"doc.text.fill"]];

    // JS QuickLoader
    JSQuickLoaderViewController *jsVC = [[JSQuickLoaderViewController alloc] init];
    UINavigationController *jsNav = [self wrapInNav:jsVC];
    jsNav.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"JS"
                image:[UIImage systemImageNamed:@"bolt"]
        selectedImage:[UIImage systemImageNamed:@"bolt.fill"]];

    // Settings
    SettingsViewController *settingsVC = [[SettingsViewController alloc] init];
    UINavigationController *settingsNav = [self wrapInNav:settingsVC];
    settingsNav.tabBarItem = [[UITabBarItem alloc]
        initWithTitle:@"Settings"
                image:[UIImage systemImageNamed:@"gear"]
        selectedImage:[UIImage systemImageNamed:@"gearshape.fill"]];

    self.viewControllers = @[tweaksNav, sourcesNav, savedNav, logsNav, jsNav, settingsNav];
}

@end

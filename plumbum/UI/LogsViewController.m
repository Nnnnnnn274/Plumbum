//
//  LogsViewController.m
//  plumbum
//
//  Created by seo on 6/8/26.
//

#import "LogsViewController.h"
#import "SileoColors.h"
#import "LogTextView.h"
#import "kexploit/kexploit_opa334.h"
#import "MainTabBarController.h"

@interface LogsViewController ()
@property (nonatomic, strong) UITextView *logView;
@property (nonatomic, strong) UIButton *clearButton;
@end

@implementation LogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Kernel Exploit";
    
    [self setupViews];
    [self configureNavigationBar];
    log_init();
    
    // Run kernel exploit automatically on view load
    [self runKernelExploit];
}

- (void)setupViews {
    // Log view
    _logView = [[LogTextView alloc] init];
    _logView.backgroundColor = [UIColor blackColor];
    _logView.textColor = [UIColor systemGreenColor];
    _logView.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    _logView.editable = NO;
    _logView.layer.cornerRadius = 12;
    _logView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_logView];
    
    // Clear button
    _clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_clearButton setTitle:@"Clear Logs" forState:UIControlStateNormal];
    _clearButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    _clearButton.layer.cornerRadius = 12;
    _clearButton.backgroundColor = [SileoColors sileoBlue];
    [_clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_clearButton addTarget:self action:@selector(clearLogs) forControlEvents:UIControlEventTouchUpInside];
    _clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_clearButton];
    
    // Layout
    [NSLayoutConstraint activateConstraints:@[
        [_logView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [_logView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [_logView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [_logView.bottomAnchor constraintEqualToAnchor:_clearButton.topAnchor constant:-20],
        
        [_clearButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [_clearButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [_clearButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [_clearButton.heightAnchor constraintEqualToConstant:50]
    ]];
}

- (void)configureNavigationBar {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [SileoColors background];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors primaryText]};
        
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        self.navigationController.navigationBar.barTintColor = [SileoColors background];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors primaryText]};
    }
    
    self.navigationController.navigationBar.tintColor = [SileoColors sileoBlue];
}

- (void)clearLogs {
    _logView.text = @"";
}

- (void)runKernelExploit {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"Starting kernel exploit...");
        
        // Run the kernel exploit
        kexploit_opa334();
        
        NSLog(@"Kernel exploit completed successfully");
        
        // Transition to main app after exploit completes
        dispatch_async(dispatch_get_main_queue(), ^{
            [self transitionToMainApp];
        });
    });
}

- (void)transitionToMainApp {
    MainTabBarController *tabBarController = [[MainTabBarController alloc] init];
    
    // Animate the transition
    [UIView transitionWithView:self.navigationController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.navigationController setViewControllers:@[tabBarController] animated:NO];
                    }
                    completion:nil];
}

@end

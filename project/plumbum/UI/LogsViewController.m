//
//  LogsViewController.m  (Kernel Exploit screen)
//  plumbum
//

#import "LogsViewController.h"
#import "SileoColors.h"
#import "LogTextView.h"
#import "kexploit/kexploit_opa334.h"
#import "MainTabBarController.h"

typedef NS_ENUM(NSInteger, ExploitStatus) {
    ExploitStatusIdle,
    ExploitStatusRunning,
    ExploitStatusDone
};

@interface LogsViewController ()
@property (nonatomic, strong) UIView *statusBadge;
@property (nonatomic, strong) UILabel *statusDot;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIView *progressTrack;
@property (nonatomic, strong) UIView *progressFill;
@property (nonatomic, strong) NSLayoutConstraint *progressWidthConstraint;
@property (nonatomic, strong) UIButton *runExploitButton;
@property (nonatomic, strong) UIButton *escapeSandboxButton;
@property (nonatomic, strong) UIButton *fiveIconButton;
@property (nonatomic, assign) ExploitStatus exploitStatus;
@end

@implementation LogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [SileoColors background];
    self.title = @"Exploit";
    _exploitStatus = ExploitStatusIdle;

    [self setupViews];
    [self configureNavigationBar];
    log_init();
}

#pragma mark - Setup

- (void)setupViews {
    // --- Status badge ---
    _statusBadge = [[UIView alloc] init];
    _statusBadge.layer.cornerRadius = 14;
    _statusBadge.layer.masksToBounds = YES;
    _statusBadge.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_statusBadge];

    _statusDot = [[UILabel alloc] init];
    _statusDot.text = @"●";
    _statusDot.font = [UIFont systemFontOfSize:8];
    _statusDot.translatesAutoresizingMaskIntoConstraints = NO;
    [_statusBadge addSubview:_statusDot];

    _statusLabel = [[UILabel alloc] init];
    _statusLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_statusBadge addSubview:_statusLabel];

    // --- Main title ---
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"Kernel\nExploit";
    _titleLabel.numberOfLines = 2;
    _titleLabel.font = [UIFont systemFontOfSize:34 weight:UIFontWeightBold];
    _titleLabel.textColor = [SileoColors primaryText];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_titleLabel];

    // --- Subtitle ---
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.text = @"opa334 · iOS 17.0 – 18.1";
    _subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _subtitleLabel.textColor = [SileoColors secondaryText];
    _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_subtitleLabel];

    // --- Progress bar ---
    _progressTrack = [[UIView alloc] init];
    _progressTrack.backgroundColor = [SileoColors tertiaryBackground];
    _progressTrack.layer.cornerRadius = 2;
    _progressTrack.clipsToBounds = YES;
    _progressTrack.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_progressTrack];

    _progressFill = [[UIView alloc] init];
    _progressFill.backgroundColor = [SileoColors sileoBlue];
    _progressFill.layer.cornerRadius = 2;
    _progressFill.translatesAutoresizingMaskIntoConstraints = NO;
    [_progressTrack addSubview:_progressFill];

    // --- Buttons ---
    _runExploitButton = [self makePrimaryButton:@"Run Kernel Exploit" icon:@"play.fill"];
    [_runExploitButton addTarget:self action:@selector(runExploit) forControlEvents:UIControlEventTouchUpInside];

    _escapeSandboxButton = [self makeSecondaryButton:@"Escape Sandbox" icon:@"shield.slash"];
    [_escapeSandboxButton addTarget:self action:@selector(escapeSandbox) forControlEvents:UIControlEventTouchUpInside];

    _fiveIconButton = [self makeTertiaryButton:@"Five Icon Dock" icon:@"square.grid.3x2"];
    [_fiveIconButton addTarget:self action:@selector(fiveIconDock) forControlEvents:UIControlEventTouchUpInside];

    // --- Layout ---
    NSDictionary *views = @{
        @"badge": _statusBadge,
        @"title": _titleLabel,
        @"sub": _subtitleLabel,
        @"track": _progressTrack,
        @"run": _runExploitButton,
        @"sandbox": _escapeSandboxButton,
        @"five": _fiveIconButton
    };

    // Progress fill width (starts at 0)
    _progressWidthConstraint = [_progressFill.widthAnchor constraintEqualToAnchor:_progressTrack.widthAnchor multiplier:0.0];

    [NSLayoutConstraint activateConstraints:@[
        // Badge
        [_statusBadge.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [_statusBadge.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [_statusBadge.heightAnchor constraintEqualToConstant:28],

        [_statusDot.leadingAnchor constraintEqualToAnchor:_statusBadge.leadingAnchor constant:12],
        [_statusDot.centerYAnchor constraintEqualToAnchor:_statusBadge.centerYAnchor],
        [_statusLabel.leadingAnchor constraintEqualToAnchor:_statusDot.trailingAnchor constant:6],
        [_statusLabel.centerYAnchor constraintEqualToAnchor:_statusBadge.centerYAnchor],
        [_statusBadge.trailingAnchor constraintEqualToAnchor:_statusLabel.trailingAnchor constant:-12],

        // Title
        [_titleLabel.topAnchor constraintEqualToAnchor:_statusBadge.bottomAnchor constant:16],
        [_titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [_titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        // Subtitle
        [_subtitleLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:8],
        [_subtitleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [_subtitleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],

        // Progress track
        [_progressTrack.topAnchor constraintEqualToAnchor:_subtitleLabel.bottomAnchor constant:20],
        [_progressTrack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [_progressTrack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [_progressTrack.heightAnchor constraintEqualToConstant:3],

        // Progress fill
        [_progressFill.leadingAnchor constraintEqualToAnchor:_progressTrack.leadingAnchor],
        [_progressFill.topAnchor constraintEqualToAnchor:_progressTrack.topAnchor],
        [_progressFill.bottomAnchor constraintEqualToAnchor:_progressTrack.bottomAnchor],
        _progressWidthConstraint,

        // Buttons
        [_runExploitButton.topAnchor constraintEqualToAnchor:_progressTrack.bottomAnchor constant:24],
        [_runExploitButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [_runExploitButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [_runExploitButton.heightAnchor constraintEqualToConstant:54],

        [_escapeSandboxButton.topAnchor constraintEqualToAnchor:_runExploitButton.bottomAnchor constant:10],
        [_escapeSandboxButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [_escapeSandboxButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [_escapeSandboxButton.heightAnchor constraintEqualToConstant:54],

        [_fiveIconButton.topAnchor constraintEqualToAnchor:_escapeSandboxButton.bottomAnchor constant:10],
        [_fiveIconButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [_fiveIconButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [_fiveIconButton.heightAnchor constraintEqualToConstant:54],
    ]];

    [self applyIdleState];
}

#pragma mark - Button Factories

- (UIButton *)makePrimaryButton:(NSString *)title icon:(NSString *)iconName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [SileoColors sileoBlue];
    btn.layer.cornerRadius = 14;
    btn.layer.masksToBounds = YES;
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:btn];

    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:iconName]];
    icon.tintColor = [UIColor blackColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addSubview:icon];

    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    label.textColor = [UIColor blackColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [icon.widthAnchor constraintEqualToConstant:18],
        [icon.heightAnchor constraintEqualToConstant:18],
        [icon.centerYAnchor constraintEqualToAnchor:btn.centerYAnchor],
        [icon.leadingAnchor constraintEqualToAnchor:btn.leadingAnchor constant:20],
        [label.centerYAnchor constraintEqualToAnchor:btn.centerYAnchor],
        [label.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:10],
    ]];

    btn.accessibilityLabel = title;
    return btn;
}

- (UIButton *)makeSecondaryButton:(NSString *)title icon:(NSString *)iconName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [SileoColors tertiaryBackground];
    btn.layer.cornerRadius = 14;
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = [SileoColors borderColor].CGColor;
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:btn];

    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:iconName]];
    icon.tintColor = [SileoColors primaryText];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addSubview:icon];

    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    label.textColor = [SileoColors primaryText];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [icon.widthAnchor constraintEqualToConstant:18],
        [icon.heightAnchor constraintEqualToConstant:18],
        [icon.centerYAnchor constraintEqualToAnchor:btn.centerYAnchor],
        [icon.leadingAnchor constraintEqualToAnchor:btn.leadingAnchor constant:20],
        [label.centerYAnchor constraintEqualToAnchor:btn.centerYAnchor],
        [label.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:10],
    ]];

    btn.accessibilityLabel = title;
    return btn;
}

- (UIButton *)makeTertiaryButton:(NSString *)title icon:(NSString *)iconName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [SileoColors secondaryBackground];
    btn.layer.cornerRadius = 14;
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = [SileoColors borderColor].CGColor;
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:btn];

    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:iconName]];
    icon.tintColor = [SileoColors secondaryText];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addSubview:icon];

    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    label.textColor = [SileoColors secondaryText];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addSubview:label];

    [NSLayoutConstraint activateConstraints:@[
        [icon.widthAnchor constraintEqualToConstant:18],
        [icon.heightAnchor constraintEqualToConstant:18],
        [icon.centerYAnchor constraintEqualToAnchor:btn.centerYAnchor],
        [icon.leadingAnchor constraintEqualToAnchor:btn.leadingAnchor constant:20],
        [label.centerYAnchor constraintEqualToAnchor:btn.centerYAnchor],
        [label.leadingAnchor constraintEqualToAnchor:icon.trailingAnchor constant:10],
    ]];

    btn.accessibilityLabel = title;
    return btn;
}

#pragma mark - State Management

- (void)applyIdleState {
    _exploitStatus = ExploitStatusIdle;

    // Badge
    _statusBadge.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.05];
    _statusBadge.layer.borderWidth = 0.5;
    _statusBadge.layer.borderColor = [SileoColors borderColor].CGColor;
    _statusDot.textColor = [SileoColors tertiaryText];
    _statusLabel.text = @"Idle";
    _statusLabel.textColor = [SileoColors secondaryText];

    // Subtitle
    _subtitleLabel.text = @"opa334 · iOS 17.0 – 18.1";
    _subtitleLabel.textColor = [SileoColors secondaryText];

    // Progress
    [self setProgressFraction:0.0 animated:NO];

    // Run button label reset
    [self updateRunButtonTitle:@"Run Kernel Exploit" icon:@"play.fill" color:[UIColor blackColor]];
    _runExploitButton.alpha = 1.0;
    _runExploitButton.userInteractionEnabled = YES;
}

- (void)applyRunningState {
    _exploitStatus = ExploitStatusRunning;

    // Badge
    _statusBadge.backgroundColor = [[SileoColors warningColor] colorWithAlphaComponent:0.1];
    _statusBadge.layer.borderColor = [[SileoColors warningColor] colorWithAlphaComponent:0.3].CGColor;
    _statusDot.textColor = [SileoColors warningColor];
    _statusLabel.text = @"Running";
    _statusLabel.textColor = [SileoColors warningColor];

    // Subtitle
    _subtitleLabel.text = @"Exploiting kernel… please wait";
    _subtitleLabel.textColor = [SileoColors warningColor];

    // Progress at 60%
    [self setProgressFraction:0.6 animated:YES];

    [self updateRunButtonTitle:@"Running…" icon:@"arrow.clockwise" color:[UIColor blackColor]];
    _runExploitButton.alpha = 0.7;
    _runExploitButton.userInteractionEnabled = NO;
}

- (void)applyDoneState {
    _exploitStatus = ExploitStatusDone;

    // Badge
    _statusBadge.backgroundColor = [[SileoColors sileoGreen] colorWithAlphaComponent:0.1];
    _statusBadge.layer.borderColor = [[SileoColors sileoGreen] colorWithAlphaComponent:0.3].CGColor;
    _statusDot.textColor = [SileoColors sileoGreen];
    _statusLabel.text = @"Done";
    _statusLabel.textColor = [SileoColors sileoGreen];

    // Subtitle
    _subtitleLabel.text = @"Kernel r/w acquired · AMFI disabled";
    _subtitleLabel.textColor = [SileoColors sileoGreen];

    // Progress full
    [self setProgressFraction:1.0 animated:YES];

    [self updateRunButtonTitle:@"Exploit Complete" icon:@"checkmark" color:[UIColor blackColor]];
    _runExploitButton.alpha = 0.65;
    _runExploitButton.userInteractionEnabled = NO;

    // Notify other tabs
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExploitCompleted" object:nil];
}

- (void)updateRunButtonTitle:(NSString *)title icon:(NSString *)iconName color:(UIColor *)color {
    // Update the icon imageview (first subview)
    for (UIView *sv in _runExploitButton.subviews) {
        if ([sv isKindOfClass:[UIImageView class]]) {
            UIImageView *iv = (UIImageView *)sv;
            iv.image = [UIImage systemImageNamed:iconName];
            iv.tintColor = color;
        }
        if ([sv isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)sv;
            lbl.text = title;
            lbl.textColor = color;
        }
    }
}

- (void)setProgressFraction:(CGFloat)fraction animated:(BOOL)animated {
    [_progressWidthConstraint setActive:NO];
    _progressWidthConstraint = [_progressFill.widthAnchor
        constraintEqualToAnchor:_progressTrack.widthAnchor
                     multiplier:fraction];
    [_progressWidthConstraint setActive:YES];

    if (animated) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    } else {
        [self.view layoutIfNeeded];
    }
}

#pragma mark - Navigation Bar

- (void)configureNavigationBar {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [SileoColors background];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors primaryText]};
        appearance.shadowColor = [SileoColors separatorColor];
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        self.navigationController.navigationBar.barTintColor = [SileoColors background];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors primaryText]};
    }
    self.navigationController.navigationBar.tintColor = [SileoColors sileoBlue];
}

#pragma mark - Actions

- (void)runExploit {
    if (_exploitStatus != ExploitStatusIdle) return;
    [self applyRunningState];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        kexploit_opa334();
        dispatch_async(dispatch_get_main_queue(), ^{
            [self applyDoneState];
            [self transitionToMainApp];
        });
    });
}

- (void)escapeSandbox {
    // Sandbox escape implementation
}

- (void)fiveIconDock {
    // Five icon dock implementation
}

- (void)transitionToMainApp {
    MainTabBarController *tabBar = [[MainTabBarController alloc] init];
    [UIView transitionWithView:self.navigationController.view
                      duration:0.45
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self.navigationController setViewControllers:@[tabBar] animated:NO];
                    }
                    completion:nil];
}

@end

//
//  LogsViewController.m  — launch screen, runs exploit on startup
//  plumbum
//

#import "LogsViewController.h"
#import "SileoColors.h"
#import "LogTextView.h"
#import "MainTabBarController.h"
#import "kexploit/kexploit_opa334.h"

typedef NS_ENUM(NSInteger, PBExploitStatus) {
    PBExploitStatusIdle,
    PBExploitStatusRunning,
    PBExploitStatusDone
};

// ─── small pulsing dot view ───────────────────────────────────────────────────
@interface PulsingDotView : UIView
- (void)startPulsing;
- (void)stopPulsing;
@property (nonatomic, strong) UIColor *dotColor;
@end

@implementation PulsingDotView
- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, 8, 8)];
    if (self) {
        _dotColor = [SileoColors tertiaryText];
        self.backgroundColor = _dotColor;
        self.layer.cornerRadius = 4;
    }
    return self;
}
- (void)setDotColor:(UIColor *)dotColor {
    _dotColor = dotColor;
    self.backgroundColor = dotColor;
}
- (void)startPulsing {
    [self.layer removeAllAnimations];
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulse.fromValue = @1.0;
    pulse.toValue = @0.3;
    pulse.duration = 0.7;
    pulse.autoreverses = YES;
    pulse.repeatCount = HUGE_VALF;
    pulse.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:pulse forKey:@"pulse"];
}
- (void)stopPulsing {
    [self.layer removeAllAnimations];
    self.layer.opacity = 1.0;
}
@end

// ─── main view controller ─────────────────────────────────────────────────────
@interface LogsViewController ()
// badge
@property (nonatomic, strong) UIView          *statusBadge;
@property (nonatomic, strong) PulsingDotView  *statusDot;
@property (nonatomic, strong) UILabel         *statusLabel;
// hero text
@property (nonatomic, strong) UILabel         *titleLabel;
@property (nonatomic, strong) UILabel         *subtitleLabel;
// progress
@property (nonatomic, strong) UIView          *progressTrack;
@property (nonatomic, strong) UIView          *progressFill;
@property (nonatomic, strong) NSLayoutConstraint *progressWidthConstraint;
// buttons
@property (nonatomic, strong) UIButton        *runButton;
@property (nonatomic, strong) UIButton        *continueButton;
// log terminal
@property (nonatomic, strong) UIView          *terminalCard;
@property (nonatomic, strong) LogTextView     *logView;
// state
@property (nonatomic, assign) PBExploitStatus  exploitStatus;
@end

@implementation LogsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SileoColors background];
    self.navigationController.navigationBarHidden = YES;

    log_init();
    _exploitStatus = PBExploitStatusIdle;

    [self buildViews];
    [self applyIdleState];

    // Auto-run the exploit as soon as the view is ready
    dispatch_async(dispatch_get_main_queue(), ^{
        [self runExploit];
    });
}

#pragma mark - Build views

- (void)buildViews {
    CGFloat pad = 20.0;

    // ── Status badge ──────────────────────────────────────────────────────────
    _statusBadge = [[UIView alloc] init];
    _statusBadge.layer.cornerRadius = 14;
    _statusBadge.layer.masksToBounds = YES;
    _statusBadge.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_statusBadge];

    _statusDot = [[PulsingDotView alloc] init];
    _statusDot.translatesAutoresizingMaskIntoConstraints = NO;
    [_statusBadge addSubview:_statusDot];

    _statusLabel = [[UILabel alloc] init];
    _statusLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    _statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_statusBadge addSubview:_statusLabel];

    // ── Hero title ────────────────────────────────────────────────────────────
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = @"Kernel\nExploit";
    _titleLabel.numberOfLines = 2;
    _titleLabel.font = [UIFont systemFontOfSize:38 weight:UIFontWeightBold];
    _titleLabel.textColor = [SileoColors primaryText];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_titleLabel];

    // ── Subtitle ──────────────────────────────────────────────────────────────
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    _subtitleLabel.textColor = [SileoColors secondaryText];
    _subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_subtitleLabel];

    // ── Progress bar ──────────────────────────────────────────────────────────
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

    _progressWidthConstraint = [_progressFill.widthAnchor
        constraintEqualToAnchor:_progressTrack.widthAnchor multiplier:0.0001];

    // ── Run button ────────────────────────────────────────────────────────────
    _runButton = [self makePrimaryButton:@"Running…" icon:@"arrow.clockwise"];
    [_runButton addTarget:self action:@selector(runExploit) forControlEvents:UIControlEventTouchUpInside];

    // ── Continue button (revealed when done) ──────────────────────────────────
    _continueButton = [self makeSecondaryButton:@"Continue to App" icon:@"arrow.right"];
    _continueButton.alpha = 0;
    _continueButton.userInteractionEnabled = NO;
    [_continueButton addTarget:self action:@selector(continueToApp) forControlEvents:UIControlEventTouchUpInside];

    // ── Terminal card ─────────────────────────────────────────────────────────
    _terminalCard = [[UIView alloc] init];
    _terminalCard.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9];
    _terminalCard.layer.cornerRadius = 14;
    _terminalCard.layer.masksToBounds = YES;
    _terminalCard.layer.borderWidth = 0.5;
    _terminalCard.layer.borderColor = [SileoColors borderColor].CGColor;
    _terminalCard.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_terminalCard];

    // Terminal header bar
    UIView *termHeader = [[UIView alloc] init];
    termHeader.backgroundColor = [SileoColors secondaryBackground];
    termHeader.translatesAutoresizingMaskIntoConstraints = NO;
    [_terminalCard addSubview:termHeader];

    // Traffic-light dots
    NSArray *dotColors = @[
        [UIColor colorWithRed:1.0 green:0.36 blue:0.33 alpha:1.0],
        [UIColor colorWithRed:1.0 green:0.73 blue:0.20 alpha:1.0],
        [UIColor colorWithRed:0.20 green:0.78 blue:0.35 alpha:1.0],
    ];
    CGFloat dotX = 12;
    for (UIColor *c in dotColors) {
        UIView *d = [[UIView alloc] init];
        d.backgroundColor = c;
        d.layer.cornerRadius = 5;
        d.translatesAutoresizingMaskIntoConstraints = NO;
        [termHeader addSubview:d];
        [NSLayoutConstraint activateConstraints:@[
            [d.widthAnchor constraintEqualToConstant:10],
            [d.heightAnchor constraintEqualToConstant:10],
            [d.centerYAnchor constraintEqualToAnchor:termHeader.centerYAnchor],
            [d.leadingAnchor constraintEqualToAnchor:termHeader.leadingAnchor constant:dotX],
        ]];
        dotX += 18;
    }

    UILabel *termTitle = [[UILabel alloc] init];
    termTitle.text = @"plumbum — log";
    termTitle.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightMedium];
    termTitle.textColor = [SileoColors tertiaryText];
    termTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [termHeader addSubview:termTitle];

    // Log text view
    _logView = [[LogTextView alloc] init];
    _logView.editable = NO;
    _logView.selectable = YES;
    _logView.backgroundColor = [UIColor clearColor];
    _logView.textColor = [SileoColors sileoGreen];
    _logView.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    _logView.translatesAutoresizingMaskIntoConstraints = NO;
    _logView.contentInset = UIEdgeInsetsMake(8, 8, 8, 8);
    [_terminalCard addSubview:_logView];

    // ── Layout ────────────────────────────────────────────────────────────────
    [NSLayoutConstraint activateConstraints:@[
        // Badge
        [_statusBadge.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [_statusBadge.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:pad],
        [_statusBadge.heightAnchor constraintEqualToConstant:28],

        [_statusDot.leadingAnchor constraintEqualToAnchor:_statusBadge.leadingAnchor constant:10],
        [_statusDot.centerYAnchor constraintEqualToAnchor:_statusBadge.centerYAnchor],
        [_statusDot.widthAnchor constraintEqualToConstant:8],
        [_statusDot.heightAnchor constraintEqualToConstant:8],
        [_statusLabel.leadingAnchor constraintEqualToAnchor:_statusDot.trailingAnchor constant:6],
        [_statusLabel.centerYAnchor constraintEqualToAnchor:_statusBadge.centerYAnchor],
        [_statusBadge.trailingAnchor constraintEqualToAnchor:_statusLabel.trailingAnchor constant:-12],

        // Title
        [_titleLabel.topAnchor constraintEqualToAnchor:_statusBadge.bottomAnchor constant:14],
        [_titleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:pad],
        [_titleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-pad],

        // Subtitle
        [_subtitleLabel.topAnchor constraintEqualToAnchor:_titleLabel.bottomAnchor constant:6],
        [_subtitleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:pad],
        [_subtitleLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-pad],

        // Progress
        [_progressTrack.topAnchor constraintEqualToAnchor:_subtitleLabel.bottomAnchor constant:18],
        [_progressTrack.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:pad],
        [_progressTrack.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-pad],
        [_progressTrack.heightAnchor constraintEqualToConstant:3],

        [_progressFill.leadingAnchor constraintEqualToAnchor:_progressTrack.leadingAnchor],
        [_progressFill.topAnchor constraintEqualToAnchor:_progressTrack.topAnchor],
        [_progressFill.bottomAnchor constraintEqualToAnchor:_progressTrack.bottomAnchor],
        _progressWidthConstraint,

        // Run button
        [_runButton.topAnchor constraintEqualToAnchor:_progressTrack.bottomAnchor constant:18],
        [_runButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:pad],
        [_runButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-pad],
        [_runButton.heightAnchor constraintEqualToConstant:54],

        // Continue button
        [_continueButton.topAnchor constraintEqualToAnchor:_runButton.bottomAnchor constant:10],
        [_continueButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:pad],
        [_continueButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-pad],
        [_continueButton.heightAnchor constraintEqualToConstant:54],

        // Terminal card
        [_terminalCard.topAnchor constraintEqualToAnchor:_continueButton.bottomAnchor constant:16],
        [_terminalCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:pad],
        [_terminalCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-pad],
        [_terminalCard.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-16],

        // Terminal header
        [termHeader.topAnchor constraintEqualToAnchor:_terminalCard.topAnchor],
        [termHeader.leadingAnchor constraintEqualToAnchor:_terminalCard.leadingAnchor],
        [termHeader.trailingAnchor constraintEqualToAnchor:_terminalCard.trailingAnchor],
        [termHeader.heightAnchor constraintEqualToConstant:30],

        [termTitle.centerXAnchor constraintEqualToAnchor:termHeader.centerXAnchor],
        [termTitle.centerYAnchor constraintEqualToAnchor:termHeader.centerYAnchor],

        // Log view
        [_logView.topAnchor constraintEqualToAnchor:termHeader.bottomAnchor],
        [_logView.leadingAnchor constraintEqualToAnchor:_terminalCard.leadingAnchor],
        [_logView.trailingAnchor constraintEqualToAnchor:_terminalCard.trailingAnchor],
        [_logView.bottomAnchor constraintEqualToAnchor:_terminalCard.bottomAnchor],
    ]];
}

#pragma mark - Button factories

- (UIButton *)makePrimaryButton:(NSString *)title icon:(NSString *)iconName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [SileoColors sileoBlue];
    btn.layer.cornerRadius = 14;
    btn.layer.masksToBounds = YES;
    btn.accessibilityLabel = title;
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:btn];
    [self attachIcon:iconName color:[UIColor blackColor] labelText:title labelColor:[UIColor blackColor] toButton:btn];
    return btn;
}

- (UIButton *)makeSecondaryButton:(NSString *)title icon:(NSString *)iconName {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.backgroundColor = [SileoColors tertiaryBackground];
    btn.layer.cornerRadius = 14;
    btn.layer.masksToBounds = YES;
    btn.layer.borderWidth = 0.5;
    btn.layer.borderColor = [SileoColors borderColor].CGColor;
    btn.accessibilityLabel = title;
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:btn];
    [self attachIcon:iconName color:[SileoColors primaryText] labelText:title labelColor:[SileoColors primaryText] toButton:btn];
    return btn;
}

- (void)attachIcon:(NSString *)iconName color:(UIColor *)iconColor labelText:(NSString *)text labelColor:(UIColor *)labelColor toButton:(UIButton *)btn {
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:iconName]];
    icon.tintColor = iconColor;
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addSubview:icon];

    UILabel *lbl = [[UILabel alloc] init];
    lbl.text = text;
    lbl.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    lbl.textColor = labelColor;
    lbl.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addSubview:lbl];

    [NSLayoutConstraint activateConstraints:@[
        [icon.widthAnchor constraintEqualToConstant:18],
        [icon.heightAnchor constraintEqualToConstant:18],
        [icon.centerYAnchor constraintEqualToAnchor:btn.centerYAnchor],
        [icon.leadingAnchor constraintEqualToAnchor:btn.leadingAnchor constant:20],
        [lbl.centerYAnchor constraintEqualToAnchor:btn.centerYAnchor],
        [lbl.centerXAnchor constraintEqualToAnchor:btn.centerXAnchor],
    ]];
}

#pragma mark - State transitions

- (void)applyIdleState {
    _statusBadge.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.05];
    _statusBadge.layer.borderWidth = 0.5;
    _statusBadge.layer.borderColor = [SileoColors borderColor].CGColor;
    _statusDot.dotColor = [SileoColors tertiaryText];
    [_statusDot stopPulsing];
    _statusLabel.text = @"Idle";
    _statusLabel.textColor = [SileoColors secondaryText];
    _subtitleLabel.text = @"opa334 · iOS 17.0 – 18.1";
    _subtitleLabel.textColor = [SileoColors secondaryText];
    [self setProgressFraction:0.0 animated:NO];
    [self setRunButtonTitle:@"Run Kernel Exploit" icon:@"play.fill"];
    _runButton.alpha = 1.0;
    _runButton.userInteractionEnabled = YES;
    _continueButton.alpha = 0;
    _continueButton.userInteractionEnabled = NO;
}

- (void)applyRunningState {
    _exploitStatus = PBExploitStatusRunning;
    _statusBadge.backgroundColor = [[SileoColors warningColor] colorWithAlphaComponent:0.10];
    _statusBadge.layer.borderColor = [[SileoColors warningColor] colorWithAlphaComponent:0.30].CGColor;
    _statusDot.dotColor = [SileoColors warningColor];
    [_statusDot startPulsing];
    _statusLabel.text = @"Running";
    _statusLabel.textColor = [SileoColors warningColor];
    _subtitleLabel.text = @"Exploiting kernel… please wait";
    _subtitleLabel.textColor = [SileoColors warningColor];
    [self setProgressFraction:0.5 animated:YES];
    [self setRunButtonTitle:@"Running…" icon:@"arrow.clockwise"];
    _runButton.alpha = 0.65;
    _runButton.userInteractionEnabled = NO;
}

- (void)applyDoneState {
    _exploitStatus = PBExploitStatusDone;
    _statusBadge.backgroundColor = [[SileoColors sileoGreen] colorWithAlphaComponent:0.10];
    _statusBadge.layer.borderColor = [[SileoColors sileoGreen] colorWithAlphaComponent:0.30].CGColor;
    _statusDot.dotColor = [SileoColors sileoGreen];
    [_statusDot stopPulsing];
    _statusLabel.text = @"Done";
    _statusLabel.textColor = [SileoColors sileoGreen];
    _subtitleLabel.text = @"Kernel r/w acquired · AMFI disabled";
    _subtitleLabel.textColor = [SileoColors sileoGreen];
    [self setProgressFraction:1.0 animated:YES];
    [self setRunButtonTitle:@"Exploit Complete" icon:@"checkmark"];
    _runButton.alpha = 0.55;
    _runButton.userInteractionEnabled = NO;

    // Reveal continue button
    [UIView animateWithDuration:0.35 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self->_continueButton.alpha = 1.0;
    } completion:^(BOOL done) {
        self->_continueButton.userInteractionEnabled = YES;
    }];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ExploitCompleted" object:nil];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ExploitRun"];
}



- (void)setRunButtonTitle:(NSString *)title icon:(NSString *)iconName {
    for (UIView *sv in _runButton.subviews) {
        if ([sv isKindOfClass:[UIImageView class]])
            ((UIImageView *)sv).image = [UIImage systemImageNamed:iconName];
        if ([sv isKindOfClass:[UILabel class]])
            ((UILabel *)sv).text = title;
    }
}

- (void)setProgressFraction:(CGFloat)fraction animated:(BOOL)animated {
    [_progressWidthConstraint setActive:NO];
    _progressWidthConstraint = [_progressFill.widthAnchor
        constraintEqualToAnchor:_progressTrack.widthAnchor
                     multiplier:MAX(0.0001, fraction)];
    [_progressWidthConstraint setActive:YES];

    if (animated) {
        [UIView animateWithDuration:0.55
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{ [self.view layoutIfNeeded]; }
                         completion:nil];
    } else {
        [self.view layoutIfNeeded];
    }
}

#pragma mark - Actions

- (void)runExploit {
    if (_exploitStatus == PBExploitStatusRunning) return;
    [self applyRunningState];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        // If the exploit fails mid-way, the kernel panics and the device reboots.
        // There is no recoverable failure — returning here means it succeeded.
        kexploit_opa334();

        dispatch_async(dispatch_get_main_queue(), ^{
            [self applyDoneState];
        });
    });
}

- (void)continueToApp {
    MainTabBarController *tabBar = [[MainTabBarController alloc] init];
    [UIView transitionWithView:self.view.window
                      duration:0.45
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.view.window.rootViewController = tabBar;
                    }
                    completion:nil];
}

@end

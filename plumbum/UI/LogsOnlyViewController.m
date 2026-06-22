//
//  LogsOnlyViewController.m
//  plumbum
//
//

#import "LogsOnlyViewController.h"
#import "SileoColors.h"
#import "LogTextView.h"

@interface LogsOnlyViewController ()
@property (nonatomic, strong) LogTextView *logView;
@end

@implementation LogsOnlyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Logs";
    
    [self setupViews];
    [self configureNavigationBar];
    [self loadLogs];
}

- (void)setupViews {
    CGFloat pad = 20.0;
    
    // Terminal card
    UIView *terminalCard = [[UIView alloc] init];
    terminalCard.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.9];
    terminalCard.layer.cornerRadius = 14;
    terminalCard.layer.masksToBounds = YES;
    terminalCard.layer.borderWidth = 0.5;
    terminalCard.layer.borderColor = [SileoColors borderColor].CGColor;
    terminalCard.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:terminalCard];
    
    // Terminal header bar
    UIView *termHeader = [[UIView alloc] init];
    termHeader.backgroundColor = [SileoColors secondaryBackground];
    termHeader.translatesAutoresizingMaskIntoConstraints = NO;
    [terminalCard addSubview:termHeader];
    
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
    LogTextView *logView = [[LogTextView alloc] init];
    logView.editable = NO;
    logView.selectable = YES;
    logView.backgroundColor = [UIColor clearColor];
    logView.textColor = [SileoColors sileoGreen];
    logView.font = [UIFont monospacedSystemFontOfSize:11 weight:UIFontWeightRegular];
    logView.translatesAutoresizingMaskIntoConstraints = NO;
    logView.contentInset = UIEdgeInsetsMake(8, 8, 8, 8);
    [terminalCard addSubview:logView];
    
    // Clear button
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [clearButton setTitle:@"Clear Logs" forState:UIControlStateNormal];
    clearButton.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    clearButton.layer.cornerRadius = 14;
    clearButton.layer.masksToBounds = YES;
    clearButton.backgroundColor = [SileoColors sileoBlue];
    [clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clearLogs) forControlEvents:UIControlEventTouchUpInside];
    clearButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:clearButton];
    
    [NSLayoutConstraint activateConstraints:@[
        // Clear button
        [clearButton.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:12],
        [clearButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:pad],
        [clearButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-pad],
        [clearButton.heightAnchor constraintEqualToConstant:50],
        
        // Terminal card
        [terminalCard.topAnchor constraintEqualToAnchor:clearButton.bottomAnchor constant:16],
        [terminalCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:pad],
        [terminalCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-pad],
        [terminalCard.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-16],
        
        // Terminal header
        [termHeader.topAnchor constraintEqualToAnchor:terminalCard.topAnchor],
        [termHeader.leadingAnchor constraintEqualToAnchor:terminalCard.leadingAnchor],
        [termHeader.trailingAnchor constraintEqualToAnchor:terminalCard.trailingAnchor],
        [termHeader.heightAnchor constraintEqualToConstant:30],
        
        [termTitle.centerXAnchor constraintEqualToAnchor:termHeader.centerXAnchor],
        [termTitle.centerYAnchor constraintEqualToAnchor:termHeader.centerYAnchor],
        
        // Log view
        [logView.topAnchor constraintEqualToAnchor:termHeader.bottomAnchor],
        [logView.leadingAnchor constraintEqualToAnchor:terminalCard.leadingAnchor],
        [logView.trailingAnchor constraintEqualToAnchor:terminalCard.trailingAnchor],
        [logView.bottomAnchor constraintEqualToAnchor:terminalCard.bottomAnchor],
    ]];
    
    _logView = logView;
}

- (void)loadLogs {
    // Load logs from file if they exist
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *logPath = [documentsDir stringByAppendingPathComponent:@"plumbum_log.txt"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:logPath]) {
        NSString *logContent = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
        if (logContent) {
            _logView.text = logContent;
        } else {
            _logView.text = @"No logs available.";
        }
    } else {
        _logView.text = @"No logs available.";
    }
}

- (void)clearLogs {
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *logPath = [documentsDir stringByAppendingPathComponent:@"plumbum_log.txt"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:logPath]) {
        [fm removeItemAtPath:logPath error:nil];
    }
    
    _logView.text = @"Logs cleared.";
}

- (void)configureNavigationBar {
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [SileoColors background];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [SileoColors primaryText]};
        appearance.shadowColor = [SileoColors separatorColor];
        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    self.navigationController.navigationBar.tintColor = [SileoColors sileoBlue];
}

@end

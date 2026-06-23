//
//  LogsOnlyViewController.m
//  plumbum
//

#import "LogsOnlyViewController.h"
#import "SileoColors.h"
#import "LogTextView.h"

@interface LogsOnlyViewController ()
@property (nonatomic, strong) LogTextView *logView;
@property (nonatomic, strong) UIBarButtonItem *refreshItem;
@end

@implementation LogsOnlyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SileoColors background];
    self.title = @"Logs";

    _refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                 target:self
                                                                 action:@selector(refreshTapped)];
    self.navigationItem.rightBarButtonItem = _refreshItem;

    _logView = [[LogTextView alloc] initWithFrame:CGRectZero];
    _logView.translatesAutoresizingMaskIntoConstraints = NO;
    _logView.editable = NO;
    _logView.backgroundColor = [SileoColors background];
    _logView.textColor = [SileoColors primaryText];
    _logView.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    [self.view addSubview:_logView];

    [NSLayoutConstraint activateConstraints:@[
        [_logView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [_logView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_logView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [_logView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    [self refreshLogContents];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshLogContents];
}

- (void)refreshTapped {
    [self refreshLogContents];
}

- (void)refreshLogContents {
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *logPath = [documentsDir stringByAppendingPathComponent:@"plumbum_log.txt"];
    NSError *error = nil;
    NSString *contents = [NSString stringWithContentsOfFile:logPath
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    if (contents.length == 0) {
        contents = error ? [NSString stringWithFormat:@"Failed to load log: %@", error.localizedDescription]
                         : @"No saved log yet.";
    }
    self.logView.text = contents;
}

@end

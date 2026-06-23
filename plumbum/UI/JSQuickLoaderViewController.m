//
//  JSQuickLoaderViewController.m
//  plumbum
//

#import "JSQuickLoaderViewController.h"
#import "SileoColors.h"
#import <WebKit/WebKit.h>

@interface JSQuickLoaderViewController () <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextView *editorView;
@property (nonatomic, strong) UITextView *outputView;
@property (nonatomic, strong) UIButton *runButton;
@property (nonatomic, assign) BOOL webReady;
@end

@implementation JSQuickLoaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [SileoColors background];
    self.title = @"JS";

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay
                                                      target:self
                                                      action:@selector(runTapped)];

    UILabel *hint = [[UILabel alloc] init];
    hint.text = @"Quick JavaScript runner";
    hint.textColor = [SileoColors secondaryText];
    hint.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    hint.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hint];

    UIView *editorCard = [self cardView];
    editorCard.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:editorCard];

    _editorView = [[UITextView alloc] initWithFrame:CGRectZero];
    _editorView.translatesAutoresizingMaskIntoConstraints = NO;
    _editorView.backgroundColor = [SileoColors tertiaryBackground];
    _editorView.textColor = [SileoColors primaryText];
    _editorView.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightRegular];
    _editorView.text = @"document.body.style.background = '#111';\n'Loaded';";
    _editorView.layer.cornerRadius = 10;
    _editorView.clipsToBounds = YES;
    [editorCard addSubview:_editorView];

    UILabel *outputLabel = [[UILabel alloc] init];
    outputLabel.text = @"Output";
    outputLabel.textColor = [SileoColors secondaryText];
    outputLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    outputLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:outputLabel];

    UIView *outputCard = [self cardView];
    outputCard.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:outputCard];

    _outputView = [[UITextView alloc] initWithFrame:CGRectZero];
    _outputView.translatesAutoresizingMaskIntoConstraints = NO;
    _outputView.backgroundColor = [SileoColors tertiaryBackground];
    _outputView.textColor = [SileoColors primaryText];
    _outputView.font = [UIFont monospacedSystemFontOfSize:13 weight:UIFontWeightRegular];
    _outputView.editable = NO;
    _outputView.layer.cornerRadius = 10;
    _outputView.clipsToBounds = YES;
    _outputView.text = @"Ready.";
    [outputCard addSubview:_outputView];

    _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    [_webView loadHTMLString:@"<html><body></body></html>" baseURL:nil];

    [NSLayoutConstraint activateConstraints:@[
        [hint.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:16],
        [hint.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [hint.trailingAnchor constraintLessThanOrEqualToAnchor:self.view.trailingAnchor constant:-16],

        [editorCard.topAnchor constraintEqualToAnchor:hint.bottomAnchor constant:10],
        [editorCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [editorCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [editorCard.heightAnchor constraintEqualToConstant:180],

        [_editorView.topAnchor constraintEqualToAnchor:editorCard.topAnchor constant:12],
        [_editorView.leadingAnchor constraintEqualToAnchor:editorCard.leadingAnchor constant:12],
        [_editorView.trailingAnchor constraintEqualToAnchor:editorCard.trailingAnchor constant:-12],
        [_editorView.bottomAnchor constraintEqualToAnchor:editorCard.bottomAnchor constant:-12],

        [outputLabel.topAnchor constraintEqualToAnchor:editorCard.bottomAnchor constant:16],
        [outputLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],

        [outputCard.topAnchor constraintEqualToAnchor:outputLabel.bottomAnchor constant:10],
        [outputCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [outputCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [outputCard.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-16],

        [_outputView.topAnchor constraintEqualToAnchor:outputCard.topAnchor constant:12],
        [_outputView.leadingAnchor constraintEqualToAnchor:outputCard.leadingAnchor constant:12],
        [_outputView.trailingAnchor constraintEqualToAnchor:outputCard.trailingAnchor constant:-12],
        [_outputView.bottomAnchor constraintEqualToAnchor:outputCard.bottomAnchor constant:-12],

        [_webView.widthAnchor constraintEqualToConstant:1],
        [_webView.heightAnchor constraintEqualToConstant:1],
        [_webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:1000],
        [_webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:1000],
    ]];
}

- (UIView *)cardView {
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = [SileoColors secondaryBackground];
    card.layer.cornerRadius = 14;
    card.layer.masksToBounds = YES;
    card.layer.borderWidth = 0.5;
    card.layer.borderColor = [SileoColors borderColor].CGColor;
    return card;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.webReady) return;
    self.webReady = YES;
}

- (void)runTapped {
    if (!self.webReady) {
        self.outputView.text = @"Web engine is still preparing.";
        return;
    }

    NSString *script = self.editorView.text ?: @"";
    if (script.length == 0) {
        self.outputView.text = @"No JavaScript entered.";
        return;
    }

    __weak typeof(self) weakSelf = self;
    [self.webView evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        if (error) {
            self.outputView.text = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
            return;
        }
        if (!result || result == [NSNull null]) {
            self.outputView.text = @"OK";
            return;
        }
        self.outputView.text = [result description];
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    (void)webView;
    (void)navigation;
    self.webReady = YES;
}

@end

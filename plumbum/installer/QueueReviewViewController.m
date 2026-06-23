//
//  QueueReviewViewController.m
//  Cyanide
//

#import "QueueReviewViewController.h"
#import "PackageQueue.h"
#import "InstallProgressViewController.h"
#import "../SettingsViewController.h"

@interface QueueReviewViewController ()
@property (nonatomic, strong) NSArray<Package *> *installs;
@property (nonatomic, strong) NSArray<Package *> *uninstalls;
@end

@implementation QueueReviewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Review Queue";
    self.tableView.backgroundColor = self.view.backgroundColor ?: [UIColor systemBackgroundColor];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 56.0;
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"queue"];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
        initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(cancelTapped)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
        initWithTitle:@"Apply"
                style:UIBarButtonItemStyleDone
               target:self
               action:@selector(applyTapped)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(queueDidChange:)
                                                 name:PackageQueueDidChangeNotification
                                               object:[PackageQueue sharedQueue]];
    [self reloadQueue];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)queueDidChange:(NSNotification *)note
{
    (void)note;
    [self reloadQueue];
}

- (void)reloadQueue
{
    PackageQueue *queue = [PackageQueue sharedQueue];
    self.installs = [queue.queuedInstalls copy];
    self.uninstalls = [queue.queuedUninstalls copy];
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = (self.installs.count + self.uninstalls.count) > 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    (void)tableView;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    (void)tableView;
    return section == 0 ? self.installs.count : self.uninstalls.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    (void)tableView;
    if (section == 0) return self.installs.count ? @"Install" : nil;
    return self.uninstalls.count ? @"Uninstall" : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"queue"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"queue"];
    }
    Package *pkg = (indexPath.section == 0) ? self.installs[indexPath.row] : self.uninstalls[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    cell.textLabel.text = pkg.name;
    cell.detailTextLabel.text = pkg.shortDescription;
    cell.detailTextLabel.textColor = UIColor.secondaryLabelColor;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    (void)tableView;
    if (section == 0 && self.installs.count == 0) return @"No installs queued.";
    if (section == 1 && self.uninstalls.count == 0) return @"No removals queued.";
    return nil;
}

- (void)cancelTapped
{
    [[PackageQueue sharedQueue] clear];
    if (self.navigationController.viewControllers.firstObject == self) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)applyTapped
{
    PackageQueue *queue = [PackageQueue sharedQueue];
    if (queue.pendingCount <= 0) return;

    InstallProgressViewController *progress = [[InstallProgressViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:progress];
    nav.modalPresentationStyle = UIModalPresentationAutomatic;

    __weak typeof(self) weakSelf = self;
    [self presentViewController:nav animated:YES completion:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) return;
        [queue commit];
    }];
}

@end

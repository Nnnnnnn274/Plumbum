//
//  DocsViewController.m
//  Cyanide
//

#import "DocsViewController.h"

@interface DocsViewController ()
@property (nonatomic, copy) NSArray<NSDictionary<NSString *, NSString *> *> *rows;
@end

@implementation DocsViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    if ((self = [super initWithStyle:style])) {
        self.title = @"Tweak SDK";
        _rows = @[
            @{ @"title": @"What this screen is", @"detail": @"A short guide to how Cyanide packages, settings bundles, and live tweaks fit together." },
            @{ @"title": @"Packages", @"detail": @"Installer items map to one Package object each. Toggles persist in NSUserDefaults; one-shot tools run their own apply step." },
            @{ @"title": @"Settings bundles", @"detail": @"Some packages also expose a Settings section so users can tune values before applying the tweak." },
            @{ @"title": @"Experimental access", @"detail": @"Experimental tweaks only appear after Patreon access is unlocked, and creator-only items stay hidden from non-creators." },
        ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 72.0;
    self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionHeaderHeight = 28.0;
    self.tableView.sectionFooterHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedSectionFooterHeight = 12.0;
    if (@available(iOS 15.0, *)) {
        self.tableView.sectionHeaderTopPadding = 0.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    (void)tableView;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    (void)tableView;
    (void)section;
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"doc"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"doc"];
    }
    NSDictionary *row = self.rows[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13.0];
    cell.detailTextLabel.textColor = UIColor.secondaryLabelColor;
    cell.textLabel.text = row[@"title"];
    cell.detailTextLabel.text = row[@"detail"];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    (void)tableView;
    (void)section;
    return @"This screen is a lightweight in-app reference for the project's package and settings model.";
}

@end

//
//  UFWBaseURLTableVC.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/14/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWBaseURLTableVC.h"
#import "UFWBaseUrlCell.h"
#import "UFWSelectionTracker.h"
#import "NSLayoutConstraint+DWSExtensions.h"
#import "Constants.h"

static CGFloat kHeightUrl = 98.0f;
static NSString *const kCellIdDefault = @"Default";

static NSInteger const kUrlEntry = 0;
static NSInteger const kReset = 1;
static NSInteger const kVersion = 2;

@interface UFWBaseURLTableVC () <UITextViewDelegate>
@property (nonatomic, strong) NSString *cellIdUrlEntry;
@end

@implementation UFWBaseURLTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Settings", nil);

    self.cellIdUrlEntry = NSStringFromClass([UFWBaseUrlCell class]);
    UINib *urlEntryNib = [UINib nibWithNibName:self.cellIdUrlEntry bundle:nil];
    [self.tableView registerNib:urlEntryNib forCellReuseIdentifier:self.cellIdUrlEntry];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[self urlEntryView] setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UFWSelectionTracker setUrlString:[self urlEntryView].text];
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kUrlEntry) {
        UFWBaseUrlCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdUrlEntry forIndexPath:indexPath];
        cell.labelTitle.text = NSLocalizedString(@"Base URL", nil);
        cell.textViewUrl.text = [UFWSelectionTracker urlString];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdDefault];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdDefault];
            
            // Add a line at the bottom
            UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(1, 1, 1, 1)];
            bottomLine.backgroundColor = [UIColor lightGrayColor];
            bottomLine.translatesAutoresizingMaskIntoConstraints = NO;
            [cell.contentView addSubview:bottomLine];
            NSArray *constraints = [NSLayoutConstraint constraintsBottomAnchorView:bottomLine insideView:cell.contentView height:0.5];
            [cell.contentView addConstraints:constraints];
            
        }
        if (indexPath.row == kReset) {
            cell.textLabel.text = NSLocalizedString(@"Reset URL", nil);
            cell.detailTextLabel.text = nil;
            cell.textLabel.textColor = [UIColor redColor];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        else if (indexPath.row == kVersion) {
            cell.textLabel.text = NSLocalizedString(@"Version", nil);
            cell.detailTextLabel.text = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            cell.textLabel.textColor = TEXT_COLOR_NORMAL;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            cell.textLabel.text = @"App Error: No value found.";
            cell.detailTextLabel.text = nil;
            NSAssert2(NO, @"%s: No value for indexpath %@", __PRETTY_FUNCTION__, indexPath);
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == kUrlEntry) {
        return kHeightUrl;
    }
    else {
        return 44.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row == 1) {
        if ([[UFWSelectionTracker urlString] isEqualToString:[self urlEntryView].text] == YES) {
            [[[UIAlertView alloc] initWithTitle:[self resetString] message:NSLocalizedString(@"The current url is the same as the entered url.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil] show];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:[self resetString] message:NSLocalizedString(@"Are you sure you want to reset the server url to the default?", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:[self resetString], nil] show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:[self resetString]]) {
        [self resetToNewUrl];
    }
}

- (NSString *)resetString
{
    return NSLocalizedString(@"Reset", nil);
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ( [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound ) {
        return YES;
    }
    else {
        [textView resignFirstResponder];
        return NO;
    }
}

- (void)resetToNewUrl
{
    [UFWSelectionTracker setUrlString:nil];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (UITextView *)urlEntryView
{
    NSArray *cells = self.tableView.visibleCells;
    UFWBaseUrlCell *cell = nil;
    for (UITableViewCell *aCell in cells) {
        if ([aCell isKindOfClass:[UFWBaseUrlCell class]]) {
            cell = (UFWBaseUrlCell *)aCell;
            break;
        }
    }
    return cell.textViewUrl;
}

@end

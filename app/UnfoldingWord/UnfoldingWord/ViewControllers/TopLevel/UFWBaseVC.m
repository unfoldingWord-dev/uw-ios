//
//  UFWBaseVC.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/5/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWBaseVC.h"
#import "Constants.h"
#import "UFWNotifications.h"
#import "UFWMasterUpdater.h"
#import "UWCoreDataClasses.h"
#import "UFWTopLevelItemCell.h"
#import "FrameDetailsViewController.h"
#import "UFWBaseSettingsCell.h"
#import "UFWBaseURLTableVC.h"
#import "UFWSelectionTracker.h"
#import "FPPopoverController.h"
#import "UFWFirstLaunchInfoVC.h"
#import "UFWAppInformationView.h"
#import "UIViewController+FileTransfer.h"
#import "UnfoldingWord-Swift.h"

@interface UFWBaseVC () <UITableViewDataSource, UITableViewDelegate, LaunchInfoDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *topCellID;
@property (nonatomic, strong) NSString *settingsCellID;
@property (nonatomic, strong) NSArray *arrayTopLevelObjects;
@property (nonatomic, assign) BOOL isLoadedOnce;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBarBottom;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonSettings;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonRefresh;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonSharing;

@property (nonatomic, strong) FPPopoverController *customPopoverController;

@end

@implementation UFWBaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = BACKGROUND_GREEN;
    
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 32)];
    titleImageView.image = [UIImage imageNamed:@"unfoldingWordLogoWithWords.png"];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = titleImageView;
    self.navigationItem.title = @"";
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor =BACKGROUND_GREEN;
    self.navigationController.navigationBar.translucent = YES;
    
    self.tableView.backgroundColor = BACKGROUND_GREEN;
    self.toolBarBottom.barTintColor = BACKGROUND_GREEN;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self loadTopLevelObjects];
    [self registerForNotifications];
    
    self.topCellID = NSStringFromClass([UFWTopLevelItemCell class]);
    UINib *nib = [UINib nibWithNibName:self.topCellID bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:self.topCellID];
    
    self.settingsCellID = NSStringFromClass([UFWBaseSettingsCell class]);
    UINib *settingsNib = [UINib nibWithNibName:self.settingsCellID bundle:nil];
    [self.tableView registerNib:settingsNib forCellReuseIdentifier:self.settingsCellID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isLoadedOnce == NO) {
        self.isLoadedOnce = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self selectTopContainer:[UFWSelectionTracker topContainer] animated:YES];
        });
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    static NSString *keyDidLaunch = @"did_launch";
    BOOL didLaunch = [defaults boolForKey:keyDidLaunch];
    if (didLaunch == NO) {
        [self showPopOver];
        [defaults setBool:YES forKey:keyDidLaunch];
    }
}

#pragma mark - Sharing

- (IBAction)userRequestedSharing:(UIBarButtonItem *)activityBarButtonItem
{
    __weak typeof(self) weakself = self;
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Share" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *sendAction = [UIAlertAction actionWithTitle:@"Send Content" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ChooseMediaToShareTableVC *chooser = [[ChooseMediaToShareTableVC alloc] init];
        chooser.navigationItem.title = @"Choose Content";
        chooser.completion = ^(BOOL isCanceled, NSArray<VersionSharingInfo *> * sharingInfo) {
            NSLog(@"Canceled: %d", isCanceled);
            [self dismissViewControllerAnimated:YES completion:^{}];
//            if (isCanceled == NO) {
//                [weakself sendFileForVersion:nil fromBarButtonOrView:activityBarButtonItem];
//            }
        };
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:chooser];
        [weakself presentViewController:navController animated:YES completion:^{}];
    }];
    
    UIAlertAction *receiveAction = [UIAlertAction actionWithTitle:@"Receive Content" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself receiveFileFromBarButtonOrView:activityBarButtonItem completion:^(BOOL success) {
            [weakself loadTopLevelObjects];
            [weakself.tableView reloadData];
        }];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    
    [ac addAction:sendAction];
    [ac addAction:receiveAction];
    [ac addAction:cancelAction];
    
    [self presentViewController:ac animated:YES completion:^{}];
}

#pragma mark - Settings
- (IBAction)userRequestedSettings:(UIBarButtonItem *)settingsBarButtonItem
{
    UFWBaseURLTableVC *urlVC = [[UFWBaseURLTableVC alloc] init];
    [self.navigationController pushViewController:urlVC animated:YES];
}

- (void)loadTopLevelObjects
{
    self.arrayTopLevelObjects = [UWTopContainer sortedContainers];
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDoneNotification:) name:kNotificationDownloadEnded object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayTopLevelObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UFWTopLevelItemCell *cell = [tableView dequeueReusableCellWithIdentifier:self.topCellID forIndexPath:indexPath];
    UWTopContainer *topContainer = self.arrayTopLevelObjects[indexPath.row];
    cell.labelName.text = topContainer.title;
    if ([[UFWSelectionTracker topContainer] isEqual:topContainer]) {
        cell.labelName.textColor = SELECTION_BLUE_COLOR;
    }
    else {
        cell.labelName.textColor = TEXT_COLOR_NORMAL;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static UIView *_header = nil;
    if (_header == nil) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        label.text = @"Projects";
        NSArray *constraints = [NSLayoutConstraint constraintsForView:label insideView:view topMargin:0 bottomMargin:0 leftMargin:10 rightMargin:10];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [view addSubview:label];
        [view addConstraints:constraints];
        _header = view;
    }
    return _header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UWTopContainer *topContainer = self.arrayTopLevelObjects[indexPath.row];
    [self selectTopContainer:topContainer animated:YES];
}

- (void)selectTopContainer:(UWTopContainer *)topContainer animated:(BOOL)animated
{
    if (topContainer == nil) {
        return;
    }
    
    [UFWSelectionTracker setTopContainer:topContainer];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MasterContainer" bundle:nil];
    ContainerVC *containerVC = [sb instantiateViewControllerWithIdentifier:@"ContainerVC"];
    containerVC.topContainer = topContainer;
    [self.navigationController pushViewController:containerVC animated:YES];
    
    [self.tableView reloadData];
}

#pragma mark - Refreshing content

- (IBAction)userPressedRefreshButton:(id)sender
{
    [self triggerRefresh];
}

- (void)triggerRefresh
{
    [self startAnimating];
    [UFWMasterUpdater update];
}

- (void)resetAvailableItems
{
    [self loadTopLevelObjects];
    [self.tableView reloadData];
}

- (void)downloadDoneNotification:(NSNotification *)notification
{
    [self stopAnimating];
    [self resetAvailableItems];
    [self.tableView reloadData];
}

- (void)startAnimating
{
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.barButtonRefresh = [[UIBarButtonItem alloc] initWithCustomView:activity];
    [activity startAnimating];

    NSMutableArray *items = [self.toolBarBottom.items mutableCopy];
    [items replaceObjectAtIndex:[self indexOfRefreshButton] withObject:self.barButtonRefresh];
    self.toolBarBottom.items = items;
}

- (void)stopAnimating
{
    self.barButtonRefresh = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"update-normal"] style:UIBarButtonItemStylePlain target:self action:@selector(userPressedRefreshButton:)];
    self.barButtonRefresh.tintColor = [UIColor whiteColor];
    NSMutableArray *items = [self.toolBarBottom.items mutableCopy];
    [items replaceObjectAtIndex:[self indexOfRefreshButton] withObject:self.barButtonRefresh];
    self.toolBarBottom.items = items;
}

- (NSInteger)indexOfRefreshButton {
    return 2;
//    __block NSInteger index = -1;
//    [self.toolBarBottom.items enumerateObjectsUsingBlock:^(UIBarButtonItem *  _Nonnull bbi, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([bbi isEqual:self.barButtonRefresh]) {
//            index = idx;
//            *stop = YES;
//        }
//    }];
//    NSAssert1(index >= 0, @"%s: Could not find index of activity bar button item!", __PRETTY_FUNCTION__);
//    return index;
}

#pragma mark - Version Info Popover

- (void)showPopOver
{
    UFWFirstLaunchInfoVC *firstLaunchInfoVC = [[UFWFirstLaunchInfoVC alloc] init];
    firstLaunchInfoVC.delegate = self;
    CGFloat width = self.view.frame.size.width - 40;
    CGSize size = [UFWAppInformationView sizeForWidth:width];
    self.customPopoverController = [[FPPopoverController alloc] initWithViewController:firstLaunchInfoVC delegate:nil maxSize:size];
    self.customPopoverController.border = NO;
    [self.customPopoverController setShadowsHidden:YES];
    
    self.customPopoverController.arrowDirection = FPPopoverNoArrow;
    [self.customPopoverController presentPopoverFromView:self.view];
}

-(void)userTappedAppInfo:(id)sender
{
    [self.customPopoverController dismissPopoverAnimated:YES];
}

@end

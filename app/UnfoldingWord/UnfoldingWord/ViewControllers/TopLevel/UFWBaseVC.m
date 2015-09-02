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
#import "UFWTextChapterVC.h"
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
@property (nonatomic, weak) IBOutlet UIView *viewTopBar;
@property (nonatomic, weak) IBOutlet UIButton *buttonRefresh;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *topCellID;
@property (nonatomic, strong) NSString *settingsCellID;
@property (nonatomic, strong) NSArray *arrayTopLevelObjects;
@property (nonatomic, assign) BOOL isLoadedOnce;

@property (nonatomic, strong) AudioPlayerView *playerView;

@property (nonatomic, strong) FPPopoverController *customPopoverController;

@end

@implementation UFWBaseVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 32)];
    titleImageView.image = [UIImage imageNamed:@"unfoldingWordLogoWithWords.png"];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = titleImageView;
    self.navigationItem.title = @"";
    
    UIBarButtonItem *bbiShare = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(userRequestedSharing:)];
    self.navigationItem.rightBarButtonItem = bbiShare;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor =BACKGROUND_GRAY;
    self.navigationController.navigationBar.translucent = YES;
    
    self.tableView.backgroundColor = BACKGROUND_GRAY;
    self.viewTopBar.backgroundColor = BACKGROUND_GREEN;
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

- (void)userRequestedSharing:(UIBarButtonItem *)activityBarButtonItem
{
    [self receiveFileFromBarButtonOrView:activityBarButtonItem];
}


- (void)loadTopLevelObjects
{
    self.arrayTopLevelObjects = [[UWTopContainer allObjects] sortedArrayUsingComparator:^NSComparisonResult(UWTopContainer *top1, UWTopContainer *top2) {
        return [top1.sortOrder compare:top2.sortOrder];
    }];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  53.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.playerView == nil) {
        self.playerView = [AudioPlayerView playerWithUrl:[NSURL URLWithString:@"https://api.unfoldingword.org/uw/audio/beta/01-GEN-br256.mp3"]];
    }
    return self.playerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayTopLevelObjects.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.arrayTopLevelObjects.count) {
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
    else {
        UFWBaseSettingsCell *settingsCell = [tableView dequeueReusableCellWithIdentifier:self.settingsCellID forIndexPath:indexPath];
        return settingsCell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == self.arrayTopLevelObjects.count) { // Settings Controller
        UFWBaseURLTableVC *urlVC = [[UFWBaseURLTableVC alloc] init];
        [self.navigationController pushViewController:urlVC animated:YES];
    }
    else { // Top level object
        UWTopContainer *topContainer = self.arrayTopLevelObjects[indexPath.row];
        [self selectTopContainer:topContainer animated:YES];
    }
}

- (void)selectTopContainer:(UWTopContainer *)topContainer animated:(BOOL)animated
{
    if (topContainer == nil) {
        return;
    }
    
    [UFWSelectionTracker setTopContainer:topContainer];
    UWLanguage *language = [topContainer.languages anyObject];
    UWVersion *version = [language.versions anyObject];
    UWTOC *toc = [version.toc anyObject];
    
    if (toc.isUSFMValue == YES) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"USFM" bundle:nil];
        UFWContainerUSFMVC *containerVC = [sb instantiateViewControllerWithIdentifier:@"UFWContainerUSFMVC"];
        containerVC.topContainer = topContainer;
        [self.navigationController pushViewController:containerVC animated:YES];
    }
    else {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flow.minimumInteritemSpacing = 0;
        flow.minimumLineSpacing = 0;
        flow.sectionInset = UIEdgeInsetsZero;
        FrameDetailsViewController *frameDetails = [[FrameDetailsViewController alloc] initWithCollectionViewLayout:flow];
        frameDetails.topContainer = topContainer;
        [self.navigationController pushViewController:frameDetails animated:animated];
    }
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
    self.buttonRefresh.hidden = YES;
    [self.activityIndicator startAnimating];
}

- (void)stopAnimating
{
    self.buttonRefresh.hidden = NO;
    [self.activityIndicator stopAnimating];
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

//
//  LanguagesTableViewController.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 25/11/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "LanguagesTableViewController.h"
#import "ChapterListTableViewController.h"
#import "LanguageCell.h"
#import "Constants.h"
#import "CoreDataClasses.h"
#import "UFWNotifications.h"
#import "CommunicationHandler.h"

@interface LanguagesTableViewController () {}

@property (nonatomic,strong) NSMutableArray *selectedIndexArray;
@property (nonatomic,strong) NSArray *languages;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UIButton *refreshButton;

@end

@implementation LanguagesTableViewController
{
    BOOL _viewDidAppearOnce;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForNotifications];
    
    self.navigationItem.title = @"Unfolding Word";
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor =TABBAR_COLOR;
    self.navigationController.navigationBar.translucent = YES;
    
    self.selectedIndexArray = [NSMutableArray array];
    
    self.languages = [UFWLanguage allLanguages];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _viewDidAppearOnce = YES;
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
    // Add one for refresh row in top of the table view
    return [self.languages count] +1 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *currentTag = [NSNumber numberWithInt:(int)indexPath.row] ;
    if([self.selectedIndexArray containsObject:currentTag])
    {
        static NSString *CellIdentifier = @"LanguageCell";
        //
        static LanguageCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        });
        
        [self configureImageCell:sizingCell atIndexPath:indexPath];
        return [self calculateHeightForConfiguredSizingCell:sizingCell];
        

    }
    else if(indexPath.row == [self.languages count])
    {
        static NSString *CellIdentifier = @"LanguageCellFooter";
        //LanguageCellFooter
        static UITableViewCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        });
        
        [self configureFooterCell:sizingCell];
        return [self calculateHeightForConfiguredSizingCell:sizingCell];
    }
    else
    {
         return 60;
    }
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}

- (void)configureFooterCell:(UITableViewCell *)cell
{
    
    UILabel *label1 = (UILabel*)[cell viewWithTag:101];
    label1.preferredMaxLayoutWidth =self.view.frame.size.width - 60;
    
    UILabel *label2 = (UILabel*)[cell viewWithTag:102];
    label2.preferredMaxLayoutWidth =self.view.frame.size.width - 100;
    
    UILabel *label3 = (UILabel*)[cell viewWithTag:103];
    label3.preferredMaxLayoutWidth =self.view.frame.size.width - 100;
    
    UILabel *label4 = (UILabel*)[cell viewWithTag:104];
    label4.preferredMaxLayoutWidth =self.view.frame.size.width - 100;
}

- (void)configureImageCell:(LanguageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UFWLanguage *language = self.languages[indexPath.row];
        cell.languageLabel.text = [NSString stringWithFormat:@" %@ [ %@ ]",language.language_string,language.language];
    cell.detailTextView.preferredMaxLayoutWidth = self.view.frame.size.width - 100;
    cell.detailTextView.attributedText =(NSAttributedString*) [self getFormatedString:language];
    cell.levelImageView.image = [self getCheckingLevelImage:language.checking_level];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    /* Create custom view to display section header... */
    UIButton *refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    refreshButton.translatesAutoresizingMaskIntoConstraints = NO;
    [refreshButton setImage:[UIImage imageNamed:@"RefreshButton"] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(onRefreshTouched:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:refreshButton];
    NSArray *refreshConstraints = [self constraintsToCenterView:refreshButton inView:view];
    [view addConstraints:refreshConstraints];
    self.refreshButton = refreshButton;
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.translatesAutoresizingMaskIntoConstraints = NO;
    activityView.hidesWhenStopped = YES;
    [activityView stopAnimating];
    [view addSubview:activityView];
    NSArray *activityConstraints = [self constraintsToCenterView:activityView inView:view];
    [view addConstraints:activityConstraints];
    self.activityIndicatorView = activityView;
    
    [view setBackgroundColor:BG_GREEN_COLOR]; //your background color...
    return view;
}

- (NSArray *)constraintsToCenterView:(UIView *)subview inView:(UIView *)containerView
{
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:containerView.frame.size.width];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:containerView.frame.size.width];
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    return @[widthConstraint, heightConstraint, centerXConstraint, centerYConstraint];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     if(indexPath.row == [self.languages count])
     {
         static NSString *CellIdentifier = @"LanguageCellFooter";
         UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
         return cell;
     }

    static NSString *CellIdentifier = @"LanguageCell";
    LanguageCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [self configureImageCell:cell atIndexPath:indexPath];
    cell.infoButton.tag = indexPath.row;
    [cell.infoButton addTarget:self action:@selector(onInfoTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    NSMutableAttributedString *text =  [[NSMutableAttributedString alloc]
     initWithAttributedString: cell.detailTextView.attributedText];
    
    UFWLanguage *language = self.languages[indexPath.row];

    if (language.isSelected.boolValue)
    {
        [cell.languageLabel setTextColor:SELECTION_BLUE_COLOR];
        [text addAttribute:NSForegroundColorAttributeName
                     value:SELECTION_BLUE_COLOR
                     range:NSMakeRange(0, [text length])];
        [cell.detailTextView setAttributedText: text];
        
    }
    else
    {
        [cell.languageLabel setTextColor:NORMAL_TEXT_COLOR];
        [text addAttribute:NSForegroundColorAttributeName
                     value:NORMAL_TEXT_COLOR
                     range:NSMakeRange(0, [text length])];
        [cell.detailTextView setAttributedText: text];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UFWLanguage *language = self.languages[indexPath.row];
    [language setAsSelectedLanguage];
    [self.tableView reloadData];
}



-(void)onInfoTouched:(id)sender
{
    [self.tableView beginUpdates];
    
    NSNumber *currentTag = [NSNumber numberWithInt:(int)[sender tag]] ;
    if([self.selectedIndexArray containsObject:currentTag])
    {
        [self.selectedIndexArray removeObject:currentTag];
    }
    else{
        [self.selectedIndexArray addObject:currentTag];
    }
    
    [self.tableView endUpdates];
}



-(NSMutableAttributedString *)getFormatedString:(UFWLanguage  *)language
{
    
    
    NSString *text = [NSString stringWithFormat:@"Checking Entity: \n\t %@ \n\nChecking Level: \n\t %@ \n\nVersion:\n\t %@\n\nPublish Date:\n\t %@",language.checking_entity,language.checking_level,language.version,language.publish_date];
    
    NSMutableAttributedString *detail = [[NSMutableAttributedString alloc] initWithString:text];
    [detail addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:FONT_HELVETICA_N_LIGHT size:12]
                   range:[text rangeOfString:text]];
    [detail addAttribute:NSFontAttributeName
                  value:[UIFont fontWithName:FONT_HELVETICA_N_LIGHT size:14]
                  range:[text rangeOfString:language.checking_entity]];
    [detail addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:FONT_HELVETICA_N_LIGHT size:14]
                   range:[text rangeOfString:[NSString stringWithFormat:@"%@",language.checking_level]]];
    [detail addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:FONT_HELVETICA_N_LIGHT size:14]
                   range:[text rangeOfString:language.version]];
    [detail addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:FONT_HELVETICA_N_LIGHT size:14]
                   range:[text rangeOfString:language.publish_date]];
    return detail;
}


-(UIImage*)getCheckingLevelImage:(NSString*)levelString
{
    NSInteger level = [levelString integerValue];
    
    switch (level)
    {
        case 1:
            return [UIImage imageNamed:@"level1Cell"];
            break;
        case 2:
            return [UIImage imageNamed:@"level2Cell"];
            break;
        case 3:
            return [UIImage imageNamed:@"level3Cell"];
            break;
            
        default:
            break;
    }
    return nil;
}

#pragma mark - Updating

-(void)onRefreshTouched:(id)sender
{
    [self triggerRefresh];
}

- (void)triggerRefresh
{
    [self startAnimating];
    [CommunicationHandler update];
}

- (void)downloadDoneNotification:(NSNotification *)notification
{
    self.languages = [UFWLanguage allLanguages];
    [self stopAnimating];
    [self.tableView reloadData];
}

- (void)startAnimating
{
    self.refreshButton.hidden = YES;
    [self.activityIndicatorView startAnimating];
}

- (void)stopAnimating
{
    self.refreshButton.hidden = NO;
    [self.activityIndicatorView stopAnimating];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showChapterListID"]) //to check whether the performing segue
    {
        NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
        UFWLanguage *language = self.languages[selectedIndex.row];
        ChapterListTableViewController *chapterList = (ChapterListTableViewController*)[segue destinationViewController];
        chapterList.bible = language.bible;
        chapterList.title = language.bible.chapters_string;
        self.navigationItem.title = language.bible.languages_string;
    }
}

@end

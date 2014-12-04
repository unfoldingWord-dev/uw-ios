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
#import "BiblicalModel.h"
#import "LanguageModel.h"
#import "DataHandler.h"
#import "Constants.h"

#define LANGUAGE_TITLE @"Languages"

@interface LanguagesTableViewController ()
{
}
@property (nonatomic,assign) NSInteger selectedIndex;
@property (nonatomic,strong) NSMutableArray *selectedIndexArray;
@property (nonatomic,strong) NSMutableArray *languageArray;




@end

@implementation LanguagesTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.navigationController.navigationItem.title = LANGUAGE_TITLE ;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor =TABBAR_COLOR;
    self.navigationController.navigationBar.translucent = YES;
    

 
    
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    self.selectedIndex = -1 ;
    self.selectedIndexArray = [NSMutableArray array];
    [self fetchLanguagesFromLocal];
}

- (void)orientationChanged:(NSNotification *)notification
{
    [self.tableView reloadData];
}


-(void)fetchLanguagesFromLocal
{
    self.languageArray = [[DataHandler getLanguageList] mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section
    // AQdd one for refresh row in top of the table view
    return [self.languageArray count] +1 ;
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
    else if(indexPath.row == [self.languageArray count])
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
    LanguageModel *language = (LanguageModel *)[self.languageArray objectAtIndex:indexPath.row];
    cell.languageLabel.text = [NSString stringWithFormat:@" %@ [ %@ ]",language.language_string,language.language];
    cell.detailTextView.preferredMaxLayoutWidth = self.view.frame.size.width - 100;
    cell.detailTextView.attributedText =(NSAttributedString*) [self getFormatedString:language];
  
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    /* Create custom view to display section header... */
    UIButton *refreshButton = [[UIButton alloc] initWithFrame:CGRectMake((tableView.frame.size.width/2.0)-22,0, 44, 44)];
    [refreshButton setImage:[UIImage imageNamed:@"RefreshButton"] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(onRefreshTouched:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:refreshButton];
    [view setBackgroundColor:BG_GREEN_COLOR]; //your background color...
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
     if(indexPath.row == [self.languageArray count])
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
    
    
    if(self.selectedIndex ==indexPath.row)
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
    self.selectedIndex = indexPath.row;
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



-(NSMutableAttributedString *)getFormatedString:(LanguageModel *)lModel
{
    
    NSString *text = [NSString stringWithFormat:@"Checking Entity: \n\t %@ \n\nChecking Level: \n\t %@ \n\nVersion:\n\t %@\n\nPublish Date:\n\t %@",lModel.checking_entity,lModel.checking_level,lModel.version,lModel.publish_date];
    
    NSMutableAttributedString *detail = [[NSMutableAttributedString alloc] initWithString:text];
    [detail addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:@"HelveticaNeue-Light" size:12]
                   range:[text rangeOfString:text]];
    [detail addAttribute:NSFontAttributeName
                  value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]
                  range:[text rangeOfString:lModel.checking_entity]];
    [detail addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]
                   range:[text rangeOfString:lModel.checking_level]];
    [detail addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]
                   range:[text rangeOfString:lModel.version]];
    [detail addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]
                   range:[text rangeOfString:lModel.publish_date]];

    

    return detail;
}



-(void)onRefreshTouched:(id)sender
{
    
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if([[segue identifier] isEqualToString:@"showChapterListID"])//to check whether the performing segue 
    {
        NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
        LanguageModel *language = (LanguageModel *)[self.languageArray objectAtIndex:selectedIndex.row];
        ChapterListTableViewController *chapterList = (ChapterListTableViewController*)[segue destinationViewController];
        chapterList.bModel  = [DataHandler getChaptersList:language.language] ;
        chapterList.title = language.language_string;
        self.navigationItem.title = chapterList.bModel.languages_title;
       

        
    }
    
  
}

@end

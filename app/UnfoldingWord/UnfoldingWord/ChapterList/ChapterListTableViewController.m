//
//  ChapterListTableViewController.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 01/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "ChapterListTableViewController.h"
#import "ChapterCell.h"
#import "ChapterFrameModel.h"
#import "DataHandler.h"
#import "UIImageView+AFNetworking.h"
#import "FrameModel.h"
#import "FrameDetailsViewController.h"

@interface ChapterListTableViewController ()

@property (nonatomic,strong) NSMutableArray *chapterArray;

@end

@implementation ChapterListTableViewController

static NSString *CellIdentifier = @"ChapterCellID";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self getChapters];
}

-(void)getChapters
{
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"chapter_number" ascending:YES]];
    NSArray *sortedArray = [self.bModel.chapters sortedArrayUsingDescriptors:sortDescriptors];
    
    self.chapterArray = [[NSMutableArray alloc] initWithArray:sortedArray];
    [self.tableView reloadData];
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
    // Return the number of rows in the section.
    return [self.chapterArray count];
}
////////

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

        static ChapterCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        });
        
        [self configureImageCell:sizingCell atIndexPath:indexPath];
        return [self calculateHeightForConfiguredSizingCell:sizingCell];

}



- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}

- (void)configureImageCell:(ChapterCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    ChapterFrameModel *chapter = [self.chapterArray objectAtIndex:indexPath.row];
    
    cell.chapter_titleLabel.text = chapter.chapter_title;
    cell.chapter_detailLabel.text = chapter.chapter_reference;
    
    FrameModel *frameModel = [chapter.frames firstObject];
    NSString *thumImageUrlString = frameModel.frame_image;
    [cell.chapter_thumb setImageWithURL:[NSURL URLWithString:thumImageUrlString] placeholderImage:[UIImage imageNamed:[thumImageUrlString lastPathComponent]]];
    cell.chapter_titleLabel.preferredMaxLayoutWidth = self.view.frame.size.width - 200;
    cell.chapter_detailLabel.preferredMaxLayoutWidth = self.view.frame.size.width - 200;
    
}

////////


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChapterCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureImageCell:cell atIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
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


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([[segue identifier] isEqualToString:@"showFrameDetailsID"])//to check whether the performing segue
    {
        NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
        ChapterFrameModel *chapter = (ChapterFrameModel *)[self.chapterArray objectAtIndex:selectedIndex.row];
        FrameDetailsViewController *frameDetails = (FrameDetailsViewController*)[segue destinationViewController];
        frameDetails.frameList = [NSArray arrayWithArray:(NSArray*)chapter.frames];
    }
    
    
}


@end

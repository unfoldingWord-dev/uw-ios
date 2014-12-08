//
//  ChapterListTableViewController.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 01/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "ChapterListTableViewController.h"
#import "ChapterCell.h"
#import "UIImageView+AFNetworking.h"
#import "FrameDetailsViewController.h"
#import "DWImageGetter.h"
#import "CoreDataClasses.h"
#import "Constants.h"
@interface ChapterListTableViewController ()

@property (nonatomic,strong) NSArray *chapters;

@end

@implementation ChapterListTableViewController

static NSString *CellIdentifier = @"ChapterCellID";

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = [ChapterCell estimatedHeight];
    self.chapters = [self.bible sortedChapters];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chapters count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static ChapterCell *sizingCell = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sizingCell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            sizingCell.hidden = YES;
            [self.view addSubview:sizingCell];
        });
    
    CGRect correctSize = sizingCell.frame;
    correctSize.size.width = self.tableView.frame.size.width;
    sizingCell.frame = correctSize;
    
    UFWChapter *chapter = self.chapters[indexPath.row];

    sizingCell.chapter_titleLabel.text = chapter.title;
    sizingCell.chapter_detailLabel.text = chapter.reference;
    return [sizingCell calculatedHeight];
}

- (void)configureImageCell:(ChapterCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UFWChapter *chapter = self.chapters[indexPath.row];
    
    cell.chapter_titleLabel.text = chapter.title;
    cell.chapter_detailLabel.text = chapter.reference;
    
    UIColor *textColor = ([chapter.bible.currentChapter isEqual:chapter]) ? SELECTION_BLUE_COLOR : [UIColor blackColor];
    cell.chapter_titleLabel.textColor = textColor;
    cell.chapter_detailLabel.textColor = textColor;
    
    UFWFrame *firstFrame = [[chapter sortedFrames] firstObject] ;
    cell.chapter_thumb.image = nil; // Don't want it to flash from a reused cell
    
    __weak typeof(self) weakself = self;
    [[DWImageGetter sharedInstance] retrieveImageWithURLString:firstFrame.imageUrl completionBlock:^(NSString *originalUrl, UIImage *image) {
        // Must double check that the image hasn't been recycled for a different chapter
        NSIndexPath *currentIP = [weakself.tableView indexPathForCell:cell];
        UFWChapter *currentChapter = [weakself.chapters objectAtIndex:currentIP.row];
        UFWFrame *currentFrame = [[currentChapter sortedFrames] firstObject];
        if ([currentFrame.imageUrl isEqualToString:originalUrl]) {
            cell.chapter_thumb.image = image;
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChapterCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self configureImageCell:cell atIndexPath:indexPath];
        
    return cell;
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showFrameDetailsID"])//to check whether the performing segue
    {
        NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
        UFWChapter *chapter = self.chapters[selectedIndex.row];
        chapter.bible.currentChapter = chapter;
        FrameDetailsViewController *frameDetails = (FrameDetailsViewController*)[segue destinationViewController];
        frameDetails.chapter = chapter;
    }
}


@end

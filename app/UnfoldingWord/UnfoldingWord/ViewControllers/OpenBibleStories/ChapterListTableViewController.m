//
//  ChapterListTableViewController.m
//  UnfoldingWord
//
//  Created by Acts Media Inc. on 01/12/14.
//  Copyright (c) 2014 Distant Shores Media All rights reserved.
//

#import "ChapterListTableViewController.h"
#import "ChapterCell.h"
#import "FrameDetailsViewController.h"
#import "DWImageGetter.h"
#import "UWCoreDataClasses.h"
#import "Constants.h"
#import "UFWSelectionTracker.h"
#import "UINavigationController+UFWNavigationController.h"

@interface ChapterListTableViewController ()
@property (nonatomic,strong) OpenContainer *openContainer;
@property (nonatomic,strong) NSArray *chapters;
@property (nonatomic, strong) NSString *chapterCellId;
@property (nonatomic, copy) ChapterPickerCompletion completion;
@end

@implementation ChapterListTableViewController

+ (UIViewController *)navigationChapterPickerCompletion:(ChapterPickerCompletion)completion;
{
    ChapterListTableViewController *pickerVC = [[ChapterListTableViewController alloc] init];
    pickerVC.completion = completion;
    return [UINavigationController navigationControllerWithUFWBaseViewController:pickerVC];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = [ChapterCell estimatedHeight];
    self.navigationItem.title = NSLocalizedString(@"chapters", nil);
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    self.chapterCellId = NSStringFromClass([ChapterCell class]);
    UINib *chapterNib = [UINib nibWithNibName:self.chapterCellId bundle:nil];
    [self.tableView registerNib:chapterNib forCellReuseIdentifier:self.chapterCellId];
}

- (void)setOpenContainer:(OpenContainer *)openContainer
{
    _openContainer = openContainer;
    self.chapters = [openContainer.chapters.allObjects sortedArrayUsingComparator:^NSComparisonResult(OpenChapter *chap1, OpenChapter *chap2) {
        return [@(chap1.number.integerValue) compare:@(chap2.number.integerValue)];
    }];
    [UFWSelectionTracker setJSONTOC:openContainer.toc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UWTOC *toc = [UFWSelectionTracker TOCforJSON];
    [self setOpenContainer:toc.openContainer];
    [self.tableView reloadData];
    
    NSInteger selectedChapterIndex = [UFWSelectionTracker chapterNumberJSON] - 1;
    if (selectedChapterIndex >= 0 && selectedChapterIndex < self.chapters.count) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:selectedChapterIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
    }
}

#pragma mark - Cancel
- (void)cancel:(id)sender
{
    self.completion(YES, nil);
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
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:self.chapterCellId];
        sizingCell.hidden = YES;
        [self.view addSubview:sizingCell];
    });
    
    CGRect correctSize = sizingCell.frame;
    correctSize.size.width = self.tableView.frame.size.width;
    sizingCell.frame = correctSize;
    
    OpenChapter *chapter = self.chapters[indexPath.row];
    sizingCell.chapter_titleLabel.text = chapter.title;
    sizingCell.chapter_detailLabel.text = chapter.reference;
    return [sizingCell calculatedHeight];
}

- (void)configureImageCell:(ChapterCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    OpenChapter *chapter = self.chapters[indexPath.row];
    
    cell.chapter_titleLabel.text = chapter.title;
    cell.chapter_detailLabel.text = chapter.reference;
    
    NSInteger chapterNumber = chapter.number.integerValue;
    NSInteger selectedChapter = [UFWSelectionTracker chapterNumberJSON];
    
    UIColor *textColor = (chapterNumber == selectedChapter) ? SELECTION_BLUE_COLOR : [UIColor blackColor];
    cell.chapter_titleLabel.textColor = textColor;
    cell.chapter_detailLabel.textColor = textColor;
    
    NSArray *frames = [chapter.frames.allObjects sortedArrayUsingComparator:^NSComparisonResult(OpenFrame *frame1, OpenFrame *frame2) {
        return [frame1.uid compare:frame2.uid];
    }];

    OpenFrame *firstFrame = nil;
    if (frames.count) {
        firstFrame = frames[0];
    }
    cell.chapter_thumb.image = nil; // Don't want it to flash from a reused cell
    
    __weak typeof(self) weakself = self;
    [[DWImageGetter sharedInstance] retrieveImageWithURLString:firstFrame.imageUrl completionBlock:^(NSString *originalUrl, UIImage *image) {
        // Must double check that the image hasn't been recycled for a different chapter
        NSIndexPath *currentIP = [weakself.tableView indexPathForCell:cell];
        OpenChapter *currentChapter = [weakself.chapters objectAtIndex:currentIP.row];
        NSArray *frames = [currentChapter.frames.allObjects sortedArrayUsingComparator:^NSComparisonResult(OpenFrame *frame1, OpenFrame *frame2) {
            return [frame1.uid compare:frame2.uid];
        }];
        OpenFrame *currentFrame = (frames.count) ? [frames firstObject] : nil;
        if (currentFrame == nil || originalUrl == nil) {
            return;
        }
        else if ([currentFrame.imageUrl isEqualToString:originalUrl]) {
            cell.chapter_thumb.image = image;
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChapterCell *cell = [tableView dequeueReusableCellWithIdentifier:self.chapterCellId forIndexPath:indexPath];
    [self configureImageCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger oldChapterNumber = [UFWSelectionTracker chapterNumberJSON];
    NSInteger currentChapterNumber = indexPath.row + 1;
    if (oldChapterNumber != currentChapterNumber) {
        [UFWSelectionTracker setChapterJSON:currentChapterNumber];
        [UFWSelectionTracker setFrameJSON:0];
        OpenChapter *chapter = self.chapters[indexPath.row];
        self.completion(NO, chapter);
    }
    else {
        self.completion(YES, nil);
    }

}

@end

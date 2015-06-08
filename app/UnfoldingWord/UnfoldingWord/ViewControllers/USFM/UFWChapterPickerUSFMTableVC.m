//
//  UFWChapterPickerUSFMTableVC.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/13/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWChapterPickerUSFMTableVC.h"
#import "UFWBookPickerUSFMVC.h"
#import "UWCoreDataClasses.h"
#import "Constants.h"
#import "ACTSimpleChapterNumberCell.h"

@interface UFWChapterPickerUSFMTableVC ()
@property (nonatomic, assign) NSInteger numberOfChapters;
@property (nonatomic, strong) NSString *cellIdChapter;
@end

@implementation UFWChapterPickerUSFMTableVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    self.cellIdChapter = NSStringFromClass([ACTSimpleChapterNumberCell class]);
    UINib *chapterNib = [UINib nibWithNibName:self.cellIdChapter bundle:nil];
    [self.tableView registerNib:chapterNib forCellReuseIdentifier:self.cellIdChapter];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setToc:(UWTOC *)toc
{
    _toc = toc;
    self.numberOfChapters = toc.usfmInfo.numberOfChapters.integerValue;
    self.navigationItem.title = toc.title;
}

#pragma mark - Cancel
- (void)cancel:(id)sender
{
    self.completion(YES, nil, 0);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfChapters;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACTSimpleChapterNumberCell *cell = [self.tableView dequeueReusableCellWithIdentifier:self.cellIdChapter forIndexPath:indexPath];
    cell.labelChapter.text = [NSString stringWithFormat:@"Chapter %ld", (long)(indexPath.row+1)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger chapter = indexPath.row + 1;
    self.completion(NO, self.toc, chapter);
}

@end

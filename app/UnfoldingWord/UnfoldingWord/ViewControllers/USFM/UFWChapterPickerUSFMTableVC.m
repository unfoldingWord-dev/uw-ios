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

@interface UFWChapterPickerUSFMTableVC ()
@property (nonatomic, assign) NSInteger numberOfChapters;
@end

@implementation UFWChapterPickerUSFMTableVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = bbi;
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Default"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Default"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Chapter %ld", (long)(indexPath.row+1)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger chapter = indexPath.row + 1;
    self.completion(NO, self.toc, chapter);
}

@end

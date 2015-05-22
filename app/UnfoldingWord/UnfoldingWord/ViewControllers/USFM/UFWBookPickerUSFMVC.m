//
//  UFWBookPickerUSFMVC.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/12/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWBookPickerUSFMVC.h"
#import "UWCoreDataClasses.h"
#import "Constants.h"
#import "UINavigationController+UFWNavigationController.h"
#import "UFWChapterPickerUSFMTableVC.h"
#import "UFWSelectionTracker.h"
#import "LanguageInfoController.h"

@interface UFWBookPickerUSFMVC ()
@property (nonatomic, copy) BookPickerCompletion completion;
@property (nonatomic, strong) UWVersion *version;
@property (nonatomic, strong) NSArray *arrayOfTOCs;

@end

@implementation UFWBookPickerUSFMVC

+ (UIViewController *)navigationBookPickerWithVersion:(UWVersion *)version completion:(BookPickerCompletion)completion;
{
    UFWBookPickerUSFMVC *pickerVC = [[UFWBookPickerUSFMVC alloc] init];
    pickerVC.version = version;
    pickerVC.completion = completion;
    return [UINavigationController navigationControllerWithUFWBaseViewController:pickerVC];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    
    self.navigationItem.title = [LanguageInfoController nameForLanguageCode:self.version.language.lc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UWTOC *selectedToc = [UFWSelectionTracker TOCforUSFM];
    if (selectedToc != nil) {
        NSInteger index = [self.arrayOfTOCs indexOfObject:selectedToc];
        if (index >= 0 && index < self.arrayOfTOCs.count) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
        }
    }
}

- (void)setVersion:(UWVersion *)version
{
    _version = version;
    self.arrayOfTOCs = [self.version sortedTOCs];
}

#pragma mark - Cancel
- (void)cancel:(id)sender
{
    self.completion(YES, nil, 0);
} 

#pragma mark - Tableview

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfTOCs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Default"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Default"];
    }
    UWTOC *toc = self.arrayOfTOCs[indexPath.row];
    UWTOC *selectedToc = [UFWSelectionTracker TOCforUSFM];
    cell.textLabel.text = toc.title;
    cell.textLabel.textColor = ([toc isEqual:selectedToc]) ? SELECTION_BLUE_COLOR : TEXT_COLOR_NORMAL;
    cell.textLabel.font = FONT_MEDIUM;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UFWChapterPickerUSFMTableVC *chapterPicker = [[UFWChapterPickerUSFMTableVC alloc] init];
    chapterPicker.toc = self.arrayOfTOCs[indexPath.row];
    chapterPicker.completion = self.completion;
    [self.navigationController pushViewController:chapterPicker animated:YES];
}

@end

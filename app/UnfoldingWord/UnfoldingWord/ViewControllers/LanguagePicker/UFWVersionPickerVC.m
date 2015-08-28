//
//  UFWLanguagePickerVC.m
//  UnfoldingWord
//
//  Created by David Solberg on 5/7/15.
//  Copyright (c) 2015 Acts Media Inc. All rights reserved.
//

#import "UFWVersionPickerVC.h"
#import "ACTLabelButton.h"
#import "UFWLanguageNameCell.h"
#import "UFWVersionCell.h"
#import "UWCoreDataClasses.h"
#import "LanguageInfoController.h"
#import "Constants.h"
#import "UINavigationController+UFWNavigationController.h"
#import "UFWSelectionTracker.h"

@interface UFWVersionPickerVC () <ACTLabelButtonDelegate, CellExpandableDelegate>

@property (nonatomic, strong) NSArray *arrayLanguages;
@property (nonatomic, strong) NSMutableArray *arrayLanguagesSelected;
@property (nonatomic, strong) NSArray *arrayOfRowObjects;
@property (nonatomic, strong) NSMutableDictionary *dictionaryOfVersionExpandedStates;

@property (nonatomic, strong) NSString *cellLanguage;
@property (nonatomic, strong) NSString *cellVersion;

@property (nonatomic, copy) VersionPickerCompletion completion;
@property (nonatomic, strong) UWTOC *currentTOC;
@property (nonatomic, assign) BOOL isSide;
@end

@implementation UFWVersionPickerVC

+ (UIViewController *)navigationLanguagePickerWithTopContainer:(UWTopContainer *)topContainer isSide:(BOOL)isSide completion:(VersionPickerCompletion)completion;
{
    UFWVersionPickerVC *pickerVC = [[UFWVersionPickerVC alloc] init];
    pickerVC.isSide = isSide;
    pickerVC.topContainer = topContainer;
    pickerVC.completion = completion;
    return [UINavigationController navigationControllerWithUFWBaseViewController:pickerVC];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.navigationItem.title = self.topContainer.title;
    
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    // Register the cells for our tableview
    self.cellLanguage = NSStringFromClass([UFWLanguageNameCell class]);
    UINib *languageNib = [UINib nibWithNibName:self.cellLanguage bundle:nil];
    [self.tableView registerNib:languageNib forCellReuseIdentifier:self.cellLanguage];
    
    self.cellVersion = NSStringFromClass([UFWVersionCell class]);
    UINib *versionNib = [UINib nibWithNibName:self.cellVersion bundle:nil];
    [self.tableView registerNib:versionNib forCellReuseIdentifier:self.cellVersion];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDownloadComplete:) name:kNotificationDownloadCompleteForVersion object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationVersionContentDeleted:) name:kNotificationVersionContentDelete object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.currentTOC.version.language != nil) {
        NSInteger index = [self.arrayOfRowObjects indexOfObject:self.currentTOC.version.language];
        if (index >= 0 && index < self.arrayOfRowObjects.count) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:animated];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setTopContainer:(UWTopContainer *)topContainer
{
    // Make matching arrays to know which is selected.
    _topContainer = topContainer;
    self.arrayLanguages = topContainer.sortedLanguages;

    if (topContainer.isUSFM == YES) {
        if (self.isSide == YES) {
            self.currentTOC = [UFWSelectionTracker TOCforUSFMSide];
        }
        else {
            self.currentTOC = [UFWSelectionTracker TOCforUSFM];
        }
    }
    else {
        if (self.isSide == YES) {
            self.currentTOC = [UFWSelectionTracker TOCforJSONSide];
        }
        else {
            self.currentTOC = [UFWSelectionTracker TOCforJSON];
        }
    }

    self.dictionaryOfVersionExpandedStates = [NSMutableDictionary new];

    UWLanguage *selectedLanguage = self.currentTOC.version.language;
    NSMutableArray *array = [NSMutableArray new];

    for (UWLanguage *language in self.arrayLanguages) {
        [array addObject:@([language isEqual:selectedLanguage])];
    }
    self.arrayLanguagesSelected = array;
    
    [self resetRowObjects];
}

#pragma mark - Cancel
- (void)cancel:(id)sender
{
    self.completion(YES, nil);
}

#pragma mark = Notifications
- (void)notificationDownloadComplete:(NSNotification *)notification
{
    [self reloadCellWithVersionId:notification.userInfo[kKeyVersionId]];
}

- (void)notificationVersionContentDeleted:(NSNotification *)notification
{
    [self reloadCellWithVersionId:notification.userInfo[kKeyVersionId]];
}

- (void)reloadCellWithVersionId:(NSString *)versionId
{
    if ( ! [versionId isKindOfClass:[NSString class]]) {
        NSAssert2(NO, @"%s: Called with an incorrect version id %@", __PRETTY_FUNCTION__, versionId);
        return;
    }
    
    int i = 0;
    for (id object in self.arrayOfRowObjects) {
        if ([object isKindOfClass:[UWVersion class]]) {
            UWVersion *version = object;
            if ([version.objectID.URIRepresentation.absoluteString isEqualToString:versionId]) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            }
        }
        i++;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfRowObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = self.arrayOfRowObjects[indexPath.row];
    
    if ([object isKindOfClass:[UWLanguage class]]) {
        UWLanguage *language = (UWLanguage *)object;
        UFWLanguageNameCell *languageCell = [tableView dequeueReusableCellWithIdentifier:self.cellLanguage forIndexPath:indexPath];
        languageCell.labelButtonLanguageName.text = [LanguageInfoController nameForLanguageCode:language.lc];
        languageCell.labelButtonLanguageName.font = FONT_LIGHT;
        languageCell.labelButtonLanguageName.direction = ([self isLanguageSelected:language]) ? ArrowDirectionDown : ArrowDirectionUp;
        languageCell.labelButtonLanguageName.delegate = self;
        languageCell.labelButtonLanguageName.matchingObject = language;
        languageCell.labelButtonLanguageName.colorHover = [UIColor lightGrayColor];
        
        if ([language isEqual:self.currentTOC.version.language]) {
            languageCell.labelButtonLanguageName.colorNormal = SELECTION_BLUE_COLOR;
        }
        else {
            languageCell.labelButtonLanguageName.colorNormal = [UIColor blackColor];
        }
        
        return languageCell;
    }
    else if ([object isKindOfClass:[UWVersion class]]) {
        UWVersion *version = (UWVersion *)object;
        UFWVersionCell *versionCell = [tableView dequeueReusableCellWithIdentifier:self.cellVersion forIndexPath:indexPath];
        versionCell.delegate = self;
        versionCell.version = version;
        versionCell.isExpanded = [self isVersionExpanded:version];
        versionCell.isSelected = [version isEqual:self.currentTOC.version];
        return versionCell;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = self.arrayOfRowObjects[indexPath.row];
    if ([object isKindOfClass:[UWLanguage class]]) {
        return 44.0f;
    }
    else if ([object isKindOfClass:[UWVersion class]]) {
        UWVersion *version = (UWVersion *)object;
        return [UFWVersionCell heightForVersion:version expanded:[self isVersionExpanded:version] forWidth:self.tableView.frame.size.width];
    }
    else {
        NSAssert1(NO, @"no height for %@", object);
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UWVersion *version = self.arrayOfRowObjects[indexPath.row];
    if ([version isKindOfClass:[UWVersion class]]) {
        if ([version isAllDownloaded]) {
            self.completion(NO, version);
        }
        else {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"This item has not been downloaded yet. Press the download button first.", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles: nil] show];
        }
    }
}

- (BOOL)isVersionExpanded:(UWVersion *)version
{
    NSNumber *expanded = self.dictionaryOfVersionExpandedStates[version.objectID.URIRepresentation.absoluteString];
    return expanded.boolValue;
}

/// We're not using real headers b/c they don't do enough, so we create fake headers. This method recalculates which item to show based on the current state of the tableview selections.
- (void)resetRowObjects
{
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0 ; i < self.arrayLanguages.count ; i++) {
        UWLanguage *language = self.arrayLanguages[i];
        [array addObject:language];
        if ( ((NSNumber *)self.arrayLanguagesSelected[i]).boolValue) {
            [array addObjectsFromArray:language.sortedVersions];
        }
    }
    self.arrayOfRowObjects = array;
}

- (BOOL)isLanguageSelected:(UWLanguage *)language
{
    NSInteger index = [self.arrayLanguages indexOfObject:language];
    NSNumber *selected = self.arrayLanguagesSelected[index];
    return selected.boolValue;
}

#pragma mark - Expandable Cell Methods

- (void)cellDidChangeExpandedState:(UFWVersionCell *)cell
{
    UWVersion *version = cell.version;
    NSString *key = version.objectID.URIRepresentation.absoluteString;
    NSNumber *expanded =self.dictionaryOfVersionExpandedStates[key];
    if (expanded == nil || expanded.boolValue == NO) {
        self.dictionaryOfVersionExpandedStates[key] = @(YES);
    }
    else {
        [self.dictionaryOfVersionExpandedStates removeObjectForKey:key];
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Label Button Delegate

- (void)labelButtonPressed:(ACTLabelButton *)labelButton;
{
    id matchingObject = labelButton.matchingObject;
    NSParameterAssert(matchingObject);
    
    // Find out whether to expand or contract the version cells.
    BOOL shouldInsert = NO;
    NSInteger index = [self.arrayLanguages indexOfObject:matchingObject];
    if (index >=0 && index < self.arrayLanguagesSelected.count) {
        BOOL selected = ((NSNumber *)self.arrayLanguagesSelected[index]).boolValue;
        shouldInsert = (selected) ? NO : YES;
        NSNumber *selectedNum = (selected) ? @(NO) : @(YES);
        [self.arrayLanguagesSelected replaceObjectAtIndex:index withObject:selectedNum];
    }
    
    // Make an array of indices that will be added or deleted.
    UWLanguage *language = self.arrayLanguages[index];
    NSInteger rowIndex = [self.arrayOfRowObjects indexOfObject:language] + 1;

    NSInteger versionCount = language.versions.count;
    NSMutableArray *changesIndexPaths = [NSMutableArray new];
    for (int i = 0 ; i < versionCount ; i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:rowIndex+i inSection:0];
        [changesIndexPaths addObject:ip];
    }
    
    // Reset the items so the insert/delete has the correct number.
    [self resetRowObjects];
    
    if (shouldInsert) {
        [self.tableView insertRowsAtIndexPaths:changesIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [self.tableView deleteRowsAtIndexPaths:changesIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    labelButton.direction = (shouldInsert) ? ArrowDirectionDown : ArrowDirectionUp;
}

@end

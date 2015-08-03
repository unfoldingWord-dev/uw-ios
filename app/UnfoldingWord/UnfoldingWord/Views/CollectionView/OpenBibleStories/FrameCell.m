//
//  FrameCell.m
//  UnfoldingWord
//

#import "FrameCell.h"
#import "Constants.h"
#import "ACTLabelButton.h"
#import "NSString+Trim.h"

static NSInteger const kTagVersionBBI = 1111;
static NSInteger const kTagStatusBBI = 1112;
static NSInteger const kTagShareBBI = 1113;


@interface FrameCell () <ACTLabelButtonDelegate>

@property (nonatomic, weak) IBOutlet UIView *viewTextBackground;
@property (nonatomic, weak) IBOutlet UIView *viewTextBackgroundSide;

@property (weak, nonatomic) IBOutlet UIImageView *frame_Image;
@property (nonatomic, strong) NSLayoutConstraint *constraintImageRatio;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintMainToRight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *constraintSideToRight;

@property (nonatomic, weak) IBOutlet UIToolbar *toolBarMain;
@property (nonatomic, weak) IBOutlet UIToolbar *toolBarSide;

@end

@implementation FrameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)adjustColors
{
    self.backgroundColor = BACKGROUND_GRAY;
    self.viewTextBackground.backgroundColor = TABBAR_COLOR_TRANSPARENT;
    self.viewTextBackgroundSide.backgroundColor = TABBAR_COLOR_TRANSPARENT;
}

- (void)setup
{
    [self adjustColors];
    [self createButtonsForToolBar:self.toolBarMain];
    [self createButtonsForToolBar:self.toolBarSide];
}

- (void)setIsShowingSide:(BOOL)isShowingSide animated:(BOOL)animated
{
    UILayoutPriority required = 999;
    UILayoutPriority basicallyNothing = 1;
    
    if (isShowingSide == YES) {
        self.constraintMainToRight.priority = basicallyNothing;
        self.constraintSideToRight.priority = required;
    } else {
        self.constraintMainToRight.priority = required;
        self.constraintSideToRight.priority = basicallyNothing;
    }
    
    [self setNeedsUpdateConstraints];
    
    CGFloat duration = (animated == YES) ? 0.5 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];

    } completion:^(BOOL finished) {
        [self createButtonsForToolBar:self.toolBarMain];
        [self createButtonsForToolBar:self.toolBarSide];
    }];
}

- (void)setFrameImage:(UIImage *)image
{
    if ( ! image) {
        self.frame_Image.image = nil;
        return;
    }
    if (self.constraintImageRatio == nil) {
        CGFloat ratio = image.size.width / image.size.height ;
        NSLayoutConstraint *ratioConstraint = [NSLayoutConstraint constraintWithItem:self.frame_Image attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.frame_Image attribute:NSLayoutAttributeHeight multiplier:ratio constant:0];
        [self.contentView addConstraint:ratioConstraint];
        self.constraintImageRatio = ratioConstraint;
    }
    self.frame_Image.image = image;
}

- (void)createButtonsForToolBar:(UIToolbar *)toolbar
{
    // Add bar button items
    UIBarButtonItem *bbiVersion = [self labelBBIWithTitle:NSLocalizedString(@"Version", nil)];
    
    UIBarButtonItem *bbiStatus = [self statusBBIWithImage:nil];
    
    UIBarButtonItem *bbiSpacer =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *bbiShare = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(userRequestedSharing:)];
    bbiShare.tag = kTagShareBBI;
    
    toolbar.items = @[bbiVersion, bbiSpacer, bbiStatus, bbiShare];
}

- (UIBarButtonItem *)labelBBIWithTitle:(NSString *)title
{
    // Add bar button items
    ACTLabelButton *labelButton = [[ACTLabelButton alloc] initWithFrame:CGRectMake(0, 0, 80, 30)];
    labelButton.text = title;
    
    CGFloat availableWidth = self.toolBarMain.frame.size.width - 100.0f; // need 100 for other elements on the bar.
    CGFloat specifiedWidth = fminf([labelButton.text widthUsingFont:labelButton.font] + [ACTLabelButton widthForArrow], availableWidth);
    CGRect finalRect = labelButton.bounds;
    finalRect.size.width = specifiedWidth;
    labelButton.frame = finalRect;
    
    labelButton.delegate = self;
    labelButton.adjustsFontSizeToFitWidth = YES;
    labelButton.minimumScaleFactor = 0.8;
    labelButton.direction = ArrowDirectionDown;
    labelButton.colorNormal = [UIColor whiteColor];
    labelButton.colorHover = [UIColor lightGrayColor];
    labelButton.userInteractionEnabled = YES;
    UIBarButtonItem *bbiVersion = [[UIBarButtonItem alloc] initWithCustomView:labelButton];
    bbiVersion.tag = kTagVersionBBI;
    return bbiVersion;
}

- (UIBarButtonItem *)statusBBIWithImage:(UIImage *)image
{
    if (image == nil) {
        // We want some type of placeholder.
        image = [UIImage imageNamed:LEVEL_3_REVERSE];
    }
    UIButton *buttonStatus = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
    [buttonStatus setImage:image forState:UIControlStateNormal];
    [buttonStatus addTarget:self action:@selector(showPopOverStatusInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *bbiStatus = [[UIBarButtonItem alloc] initWithCustomView:buttonStatus];
    bbiStatus.tag = kTagStatusBBI;
    return bbiStatus;
}

#pragma mark - Outside Methods

- (void)setVersionName:(NSString *)name isSide:(BOOL)isSide
{
    UIToolbar *toolbar = (isSide == YES) ? self.toolBarSide : self.toolBarMain;
    NSInteger index = [self indexOfTag:kTagVersionBBI inToolBar:toolbar];
    UIBarButtonItem *item = [self labelBBIWithTitle:name];
    [self replaceItemInToolbar:toolbar atIndex:index withItem:item];
}

- (void)setStatusImage:(UIImage *)image isSide:(BOOL)isSide
{
    UIToolbar *toolbar = (isSide == YES) ? self.toolBarSide : self.toolBarMain;
    NSInteger index = [self indexOfTag:kTagStatusBBI inToolBar:toolbar];
    UIBarButtonItem *item = [self statusBBIWithImage:image];
    [self replaceItemInToolbar:toolbar atIndex:index withItem:item];
}

- (void)replaceItemInToolbar:(UIToolbar *)toolbar atIndex:(NSInteger)index withItem:(UIBarButtonItem *)item
{
    if (index < 0 || index >= toolbar.items.count) {
        NSAssert3(NO, @"%s: Could not find the bbi with index %ld in toolbar %@", __PRETTY_FUNCTION__, (long)index, toolbar);
        return;
    }
    
    NSMutableArray *items = toolbar.items.mutableCopy;
    [items replaceObjectAtIndex:index withObject:item];
    toolbar.items = items;
}

#pragma mark - User Actions

- (void)userRequestedSharing:(UIBarButtonItem *)bbi
{
    BOOL isSide = [self isSide:bbi];
    [self.delegate showSharing:self view:nil isSide:isSide];
}

- (void)showPopOverStatusInfo:(UIButton *)button
{
    BOOL isSide = [self isObject:button fromToolbar:self.toolBarSide];
    [self.delegate showPopOverStatusInfo:self view:button isSide:isSide];
}

- (void)labelButtonPressed:(ACTLabelButton *)labelButton
{
    BOOL isSide = [self isObject:labelButton fromToolbar:self.toolBarSide];
    [self.delegate showVersionSelector:self view:labelButton isSide:isSide];
}

#pragma mark - Helpers / Internal

- (NSInteger)indexOfTag:(NSInteger)tag inToolBar:(UIToolbar *)toolbar
{
    __block NSInteger versionIndex = -1;
    [toolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem *bbi, NSUInteger index, BOOL *stop) {
        if (bbi.tag == tag) {
            versionIndex = index;
            *stop = YES;
        }
    }];
    return versionIndex;
}

- (BOOL)isSide:(UIBarButtonItem *)bbi
{
    BOOL isSide = [self isObject:bbi fromToolbar:self.toolBarSide];
    BOOL isMain = [self isObject:bbi fromToolbar:self.toolBarMain];
    NSAssert2( (isSide || isMain) && (isMain != isSide), @"%s: Incorrect match for bbi %@", __PRETTY_FUNCTION__, bbi);
    return isSide;
}

- (BOOL)isObject:(id)object fromToolbar:(UIToolbar *)toolbar
{
    for (UIBarButtonItem *item in toolbar.items) {
        if ([item isEqual:object]) {
            return YES;
        }
        if ([item respondsToSelector:@selector(customView)] && [item.customView isEqual:object]) {
            return YES;
        }
    }
    return NO;
}



@end

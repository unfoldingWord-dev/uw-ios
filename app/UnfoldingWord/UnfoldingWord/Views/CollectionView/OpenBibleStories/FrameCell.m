//
//  FrameCell.m
//  UnfoldingWord
//

#import "FrameCell.h"
#import "Constants.h"
#import "ACTLabelButton.h"
#import "NSString+Trim.h"

@interface FrameCell ()

@property (weak, nonatomic) IBOutlet UIImageView *frame_Image;
@property (nonatomic, strong) NSLayoutConstraint *constraintImageRatio;

// Used to show and hide the side diglot view
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *constraintSideBySide;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *constraintMainOnly;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintMainTextHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSideTextHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextViewHeightRatio;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintSpaceBelowImage;

@property (nonatomic, weak) IBOutlet UIView *viewTextBackground;
@property (nonatomic, weak) IBOutlet UIView *viewTextBackgroundSide;

@property (nonatomic, strong) NSString *versionNameMain;
@property (nonatomic, strong) NSString *versionNameSide;

@end

@implementation FrameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupCellView];
}

- (CGFloat)heightForText:(NSString *)text usingFont:(UIFont *)font width:(CGFloat)width
{
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGRect boundingTextRect = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    CGFloat height = ceilf(boundingTextRect.size.height);
    return ceil(height);
}

- (CGFloat)heightForTextView:(UITextView *)textView {
    return [self heightForText:textView.text usingFont:textView.font width:textView.frame.size.width];
}

- (void)updateConstraints {
    [self forceUpdateConstraints];
}

- (void)forceUpdateConstraints
{
    [super updateConstraints];
    [self layoutIfNeeded];
    BOOL active =  (self.frame.size.width > self.frame.size.height) ? YES : NO;
    self.constraintMainTextHeight.active = active;
    self.constraintSideTextHeight.active = active;
    self.constraintTextViewHeightRatio.active = active;
    self.constraintSpaceBelowImage.active = !active;
    if (active) {
        [self adjustConstraints];
    }
    [super updateConstraints];
    [self layoutIfNeeded];

}

- (void)adjustConstraints {
    CGFloat height = [self heightForTextView:self.textView_contentMain];
    if ([self isSide]) {
        height = fmax(height, [self heightForTextView:self.textView_contentSide]);
    }
    height += 4 + 4 + 14; // 4 is top margin, 4 is bottom margin, 14 is because textviews are inset
    self.constraintSideTextHeight.constant = height;
    self.constraintMainTextHeight.constant = height;
}

- (void)adjustColors
{
    self.backgroundColor = [UIColor lightGrayColor];
    self.viewTextBackground.backgroundColor = TABBAR_COLOR_TRANSPARENT;
    self.viewTextBackgroundSide.backgroundColor = TABBAR_COLOR_TRANSPARENT;
}

- (void)setupCellView
{
    [self adjustColors];
    [self setIsShowingSide:YES animated:NO];
}

- (void)setIsShowingSide:(BOOL)isShowingSide animated:(BOOL)animated
{
    self.constraintMainOnly.active = !isShowingSide;
    self.constraintSideBySide.active = isShowingSide;
    
    CGFloat duration = (animated == YES) ? 0.5 : 0.0;
    [UIView animateWithDuration:duration animations:^{
        [self forceUpdateConstraints];
    } completion:^(BOOL finished) {
        self.textView_contentMain.contentOffset = CGPointZero;
        self.textView_contentSide.contentOffset = CGPointZero;
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

- (BOOL)isSide
{
    return self.constraintSideBySide.isActive;
}


@end

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

@property (nonatomic, weak) IBOutlet UIView *viewTextBackground;
@property (nonatomic, weak) IBOutlet UIView *viewTextBackgroundSide;

@property (nonatomic, strong) NSString *versionNameMain;
@property (nonatomic, strong) NSString *versionNameSide;

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
    self.backgroundColor = [UIColor lightGrayColor];
    self.viewTextBackground.backgroundColor = TABBAR_COLOR_TRANSPARENT;
    self.viewTextBackgroundSide.backgroundColor = TABBAR_COLOR_TRANSPARENT;
}

- (void)setup
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
        [self layoutIfNeeded];
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

- (BOOL)isSide:(UIBarButtonItem *)bbi
{
    return self.constraintSideBySide.active;
}


@end

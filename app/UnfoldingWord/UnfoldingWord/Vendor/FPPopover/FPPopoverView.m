//
//  FPPopoverView.m
//
//  Created by Alvise Susmel on 1/4/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//
//  https://github.com/50pixels/FPPopover


#import "FPPopoverView.h"
#import "ARCMacros.h"
#import "NSLayoutConstraint+DWSExtensions.h"

#define FP_POPOVER_ARROW_HEIGHT 14.0
#define FP_POPOVER_ARROW_BASE 24.0
#define FP_POPOVER_RADIUS 10.0

//iVars
@interface FPPopoverView()
{
    //default FPPopoverArrowDirectionUp
    FPPopoverArrowDirection _arrowDirection;
    UIView *_contentView;
}

@property (nonatomic, strong) NSArray *contentConstraints;
@end


@interface FPPopoverView(Private)
//-(void)setupViews;
@end


@implementation FPPopoverView
@synthesize relativeOrigin;
@synthesize tint = _tint;
@synthesize draw3dBorder = _draw3dBorder;
@synthesize border = _border;

-(void)dealloc
{
#ifdef FP_DEBUG
    NSLog(@"FPPopoverView dealloc");
#endif

    SAFE_ARC_RELEASE(_titleLabel);
    SAFE_ARC_SUPER_DEALLOC();
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //we need to set the background as clear to see the view below
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        self.layer.shadowOpacity = 0.7;
        self.layer.shadowRadius = 5;
        self.layer.shadowOffset = CGSizeMake(-3, 3);

        //to get working the animations
        self.contentMode = UIViewContentModeRedraw;

        //3d border default is on
        self.draw3dBorder = YES;
        
        //border
        self.border = YES;
        
        self.tint = FPPopoverDefaultTint;
        
//        [self setupViews];
    }
    return self;
}

#pragma mark setters
-(void)setArrowDirection:(FPPopoverArrowDirection)arrowDirection
{
    _arrowDirection = arrowDirection;
    [self updateContentViewConstraints];
    [self setNeedsDisplay];
}

-(FPPopoverArrowDirection)arrowDirection
{
    return _arrowDirection;
}
-(void)addContentView:(UIView *)contentView
{
    if (_contentView != contentView)
    {
        [_contentView removeFromSuperview];
        _contentView = contentView;
        _contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_contentView];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

-(void)setBorder:(BOOL)border
{
    _border = border;
    //NO BORDER
    if(self.border == NO) {
        _contentView.clipsToBounds = YES;
        self.clipsToBounds = YES;
        self.draw3dBorder = NO;
        _contentView.layer.cornerRadius = FP_POPOVER_RADIUS;
    }
}

#pragma mark drawing

//the content with the arrow
-(CGPathRef)newContentPathWithBorderWidth:(CGFloat)borderWidth arrowDirection:(FPPopoverArrowDirection)direction
{
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    CGFloat ah = FP_POPOVER_ARROW_HEIGHT; //is the height of the triangle of the arrow
    CGFloat aw = FP_POPOVER_ARROW_BASE/2.0; //is the 1/2 of the base of the arrow
    CGFloat radius = FP_POPOVER_RADIUS;
    CGFloat b = borderWidth;
    
    //NO BORDER
    if(self.border == NO) {
        b = 10.0;
    }
    
    CGRect rect;
    if(direction == FPPopoverArrowDirectionUp)
    {
        
        rect.size.width = w - 2*b;
        rect.size.height = h - ah - 2*b;
        rect.origin.x = b;
        rect.origin.y = ah + b;        
    }
    else if(direction == FPPopoverArrowDirectionDown)
    {
        rect.size.width = w - 2*b;
        rect.size.height = h - ah - 2*b;
        rect.origin.x = b;
        rect.origin.y = b;                
    }
    
    
    else if(direction == FPPopoverArrowDirectionRight)
    {
        rect.size.width = w - ah - 2*b;
        rect.size.height = h - 2*b;
        rect.origin.x = b;
        rect.origin.y = b;                
    }
    else if(direction == FPPopoverArrowDirectionLeft)
    {
        rect.size.width = w - ah - 2*b;
        rect.size.height = h - 2*b;
        rect.origin.x = ah + b;
        rect.origin.y = b;
    }
    
    //NO ARROW
    else
    {
        rect.size.width = w - 2*b;
        rect.size.height = h - 2*b;
        rect.origin.x = b;
        rect.origin.y = b;        
    }
    
    //the arrow will be near the origin
    CGFloat ax = self.relativeOrigin.x - aw; //the start of the arrow when UP or DOWN
    if (ax < aw + b)
        ax = aw + b;
    else if (ax + 2*aw + 2*b > self.bounds.size.width)
        ax = self.bounds.size.width - 2*aw - 2*b;

    CGFloat ay = self.relativeOrigin.y - aw; //the start of the arrow when RIGHT or LEFT
    if(ay < aw + b)
        ay = aw + b;
    else if (ay +2*aw + 2*b > self.bounds.size.height)
        ay = self.bounds.size.height - 2*aw - 2*b;
    
    
    //ROUNDED RECT
    // arrow UP
    CGRect  innerRect = CGRectInset(rect, radius, radius);
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;    
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
    
    //drawing the border with arrow
    CGMutablePathRef path = CGPathCreateMutable();

    CGPathMoveToPoint(path, NULL, innerRect.origin.x, outside_top);
 
    //top arrow
    if(direction == FPPopoverArrowDirectionUp)
    {
        CGPathAddLineToPoint(path, NULL, ax, ah+b);
        CGPathAddLineToPoint(path, NULL, ax+aw, b);
        CGPathAddLineToPoint(path, NULL, ax+2*aw, ah+b);
        
    }

    CGPathAddLineToPoint(path, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(path, NULL, outside_right, outside_top, outside_right, inside_top, radius);

    //right arrow
    if(direction == FPPopoverArrowDirectionRight)
    {
        CGPathAddLineToPoint(path, NULL, outside_right, ay);
        CGPathAddLineToPoint(path, NULL, outside_right + ah+b, ay + aw);
        CGPathAddLineToPoint(path, NULL, outside_right, ay + 2*aw);
    }
       

	CGPathAddLineToPoint(path, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(path, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);

    //down arrow
    if(direction == FPPopoverArrowDirectionDown)
    {
        CGPathAddLineToPoint(path, NULL, ax+2*aw, outside_bottom);
        CGPathAddLineToPoint(path, NULL, ax+aw, outside_bottom + ah);
        CGPathAddLineToPoint(path, NULL, ax, outside_bottom);
    }

	CGPathAddLineToPoint(path, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(path, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
    
    //left arrow
    if(direction == FPPopoverArrowDirectionLeft)
    {
        CGPathAddLineToPoint(path, NULL, outside_left, ay + 2*aw);
        CGPathAddLineToPoint(path, NULL, outside_left - ah-b, ay + aw);
        CGPathAddLineToPoint(path, NULL, outside_left, ay);
    }
    

	CGPathAddLineToPoint(path, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(path, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);

    
    CGPathCloseSubpath(path);
    
    return path;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGPathRef contentPath = [self newContentPathWithBorderWidth:2.0 arrowDirection:_arrowDirection];
    
    //internal border
    CGContextAddPath(ctx, contentPath);
    CGContextClosePath(ctx);
    CGContextSetRGBStrokeColor(ctx, 1., 1., 1., 1.0);
    CGContextSetLineWidth(ctx, 5);
    CGContextSetLineCap(ctx,kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    CGContextStrokePath(ctx);
    CGContextAddPath(ctx, contentPath);
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 1.0);
    CGContextFillPath(ctx);
    CGPathRelease(contentPath);
}

-(void)updateContentViewConstraints
{
    if (self.contentConstraints) {
        [self removeConstraints:self.contentConstraints];
    }

    NSArray *newContraints = nil;
    
    if(_arrowDirection == FPPopoverArrowDirectionUp)
    {
        newContraints = [NSLayoutConstraint constraintsForView:_contentView insideView:self topMargin:30 bottomMargin:10 leftMargin:10 rightMargin:10];
    }
    else if(_arrowDirection == FPPopoverArrowDirectionDown)
    {
        newContraints = [NSLayoutConstraint constraintsForView:_contentView insideView:self topMargin:10 bottomMargin:30 leftMargin:10 rightMargin:10];
    }
    
    
    else if(_arrowDirection == FPPopoverArrowDirectionRight)
    {
        newContraints = [NSLayoutConstraint constraintsForView:_contentView insideView:self topMargin:10 bottomMargin:10 leftMargin:10 rightMargin:30];
    }

    else if(_arrowDirection == FPPopoverArrowDirectionLeft)
    {
        newContraints = [NSLayoutConstraint constraintsForView:_contentView insideView:self topMargin:10 bottomMargin:10 leftMargin:10 + FP_POPOVER_ARROW_HEIGHT rightMargin:10];
    }
    
    else if(_arrowDirection == FPPopoverNoArrow)
    {
        newContraints = [NSLayoutConstraint constraintsForView:_contentView insideView:self topMargin:10 bottomMargin:10 leftMargin:10 rightMargin:30];
    }

    [self addConstraints:newContraints];
    self.contentConstraints = newContraints;
}

@end

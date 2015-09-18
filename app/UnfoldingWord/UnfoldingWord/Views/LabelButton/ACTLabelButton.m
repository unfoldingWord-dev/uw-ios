//
//  ACTLabelButton.m
//  LocationMapper
//
//  Created by David Solberg on 12/22/14.
//  Copyright (c) 2014 David Solberg. All rights reserved.
//

#import "ACTLabelButton.h"

static CGFloat const arrowOffset = 8.0f;
static CGFloat const arrowSpace = 14.0f;

@interface ACTLabelButton ()
@property (nonatomic, assign) BOOL isHovering;
@property (nonatomic, strong) UIColor *normalColor;
@end

@implementation ACTLabelButton

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userInteractionEnabled = YES;
}

- (CGSize)sizeForText:(NSString *)text usingFont:(UIFont *)font
{
    NSDictionary *attributes = @{NSFontAttributeName:font};
    CGRect boundingTextRect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    CGFloat height = ceilf(boundingTextRect.size.height);
    CGFloat width = ceilf(boundingTextRect.size.width);
    return CGSizeMake(width, height);
}

-(CGSize)intrinsicContentSize
{
    if (self.isHidingArrow == YES) {
        return [super intrinsicContentSize];
    }
    else {
        CGSize size = [self sizeForText:self.text usingFont:self.font];
        size.width +=  arrowSpace + arrowOffset;
        return size;
    }
}

+ (CGFloat)widthForArrow
{
    return arrowOffset + arrowSpace;
}

-(void)setColorNormal:(UIColor *)colorNormal
{
    self.textColor = colorNormal;
    _colorNormal = colorNormal;
}

- (void)setDirection:(ArrowDirection)direction
{
    if (_direction == direction) {
        return;
    }
    _direction = direction;
    [self setNeedsDisplay];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self highlight];
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if ( point.x > 0 && point.x < self.frame.size.width && point.y > 0 && point.y < self.frame.size.height) {
        [self highlight];
    }
    else {
        [self unhighlight];
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if ( point.x > 0 && point.x < self.frame.size.width && point.y > 0 && point.y < self.frame.size.height) {
        [self.delegate labelButtonPressed:self];
    }
    
    [self unhighlight];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self unhighlight];
}

- (void)highlight
{
        self.isHovering = YES;
        self.textColor = self.colorHover;
}

- (void)unhighlight
{
    self.textColor = self.colorNormal;
    self.isHovering = NO;
}

-(void)drawTextInRect:(CGRect)rect
{
    if (self.isHidingArrow == YES) {
        [super drawTextInRect:rect];
        return;
    }
    
    // Adjust the rect out of the way of the arrow.
    CGFloat actualWidth = self.frame.size.width;
    CGFloat drawWidth = actualWidth - arrowSpace - arrowOffset;
    CGRect newRect = rect;
    newRect.size.width = drawWidth;
    [super drawTextInRect:newRect];

    CGFloat height = 8.5f;
    CGFloat xOrigin = newRect.size.width + arrowOffset;
    CGFloat yOrigin = ceilf( (newRect.size.height / 2.0f) - (height / 2.0f));
    
    UIColor* color = nil;
    if (self.isHovering) {
        color = self.colorHover;
    }
    else {
        color = self.colorNormal;
    }
    
    UIBezierPath* path = [UIBezierPath bezierPath];
    
    CGFloat halfArrowWidth = arrowSpace/2.0f;
    if (self.direction == ArrowDirectionUp) {
        [path moveToPoint: CGPointMake(xOrigin+halfArrowWidth, yOrigin+0)];
        [path addLineToPoint: CGPointMake(xOrigin+arrowSpace, yOrigin+height)];
        [path addLineToPoint: CGPointMake(xOrigin+0, yOrigin+height)];
    }
    else if (self.direction == ArrowDirectionDown) {
        [path moveToPoint: CGPointMake(xOrigin+halfArrowWidth, yOrigin+height)];
        [path addLineToPoint: CGPointMake(xOrigin+arrowSpace, yOrigin+0)];
        [path addLineToPoint: CGPointMake(xOrigin+0, yOrigin+0)];
    }
    else if (self.direction == ArrowDirectionNone) {
        CGFloat diamondWidth = 10.0f;
        CGFloat diamondOrigin = ceil((arrowSpace-diamondWidth)/2.0f) - 1.0f;
        CGFloat halfDiamondWidth = diamondWidth / 2.0f;
        [path moveToPoint: CGPointMake(xOrigin+diamondOrigin, yOrigin+(height/2.0f))];
        [path addLineToPoint: CGPointMake(xOrigin+diamondOrigin+halfDiamondWidth, yOrigin+0)];
        [path addLineToPoint: CGPointMake(xOrigin+diamondOrigin+diamondWidth, yOrigin+(height/2.0f))];
        [path addLineToPoint: CGPointMake(xOrigin+diamondOrigin+halfDiamondWidth, yOrigin+height)];
    }
    
    [path closePath];
    [color setFill];
    [path fill];

}

@end

//
//  NSLayoutConstraint+DWSExtensions.m
//  LocationMapper
//
//  Created by David Solberg on 6/25/13.
//  Copyright (c) 2013 David Solberg. All rights reserved.
//

#import "NSLayoutConstraint+DWSExtensions.h"

static NSString *const kIdentifierHeight = @"height";


@implementation NSLayoutConstraint (DWSExtensions)

+ (NSArray *)constraintsToCenterView:(UIView *)subview insideView:(UIView *)containerView
{
    NSLayoutConstraint *centerXConstraint = [[self class] constraintToHorizontallyCenterView:subview insideView:containerView];
    NSLayoutConstraint *centerYConstraint = [[self class] constraintToVerticallyCenterView:subview insideView:containerView];
    
    return [[self class] addIfNecessaryWidthAndHeightConstraintsToView:subview toConstraints:@[centerXConstraint, centerYConstraint]];
}

+ (NSArray *)constraintsToCenterView:(UIView *)subview insideView:(UIView *)containerView width:(CGFloat)width height:(CGFloat)height
{
    if ([[self class] viewHasInstrinicContentSize:subview]) {
        NSLog(@"\n\nWARNING: Specifying the width and height for view %@, which has an intrinsic content size.\n\n", subview);
    }

    NSLayoutConstraint *centerXConstraint = [[self class] constraintToHorizontallyCenterView:subview insideView:containerView];
    NSLayoutConstraint *centerYConstraint = [[self class] constraintToVerticallyCenterView:subview insideView:containerView];
    NSLayoutConstraint *heightConstraint = [[self class] constraintForView:subview forHeight:height];
    NSLayoutConstraint *widthConstraint = [[self class] constraintForView:subview forWidth:width];
    
    return @[centerXConstraint, centerYConstraint, widthConstraint, heightConstraint];
}

+ (NSArray *)constraintsTopAnchorView:(UIView *)subview insideView:(UIView *)containerView height:(CGFloat)height
{
    if ([[self class] viewHasInstrinicContentSize:subview]) {
        NSLog(@"\n\nWARNING: Specifying the width and height for view %@, which has an intrinsic content size.\n\n", subview);
    }
    
    NSLayoutConstraint *topConstraint = [[self class] constraintForView:subview insideView:containerView withTopMargin:0];
    NSLayoutConstraint *heightConstraint = [[self class] constraintForView:subview forHeight:height];
    NSLayoutConstraint *leftConstraint = [[self class] constraintForView:subview insideView:containerView withLeftMargin:0];
    NSLayoutConstraint *rightConstraint = [[self class] constraintForView:subview insideView:containerView withRightMargin:0];
    
    return @[topConstraint, heightConstraint, leftConstraint, rightConstraint];
}

+ (NSArray *)constraintsBottomAnchorView:(UIView *)subview insideView:(UIView *)containerView height:(CGFloat)height
{
    if ([[self class] viewHasInstrinicContentSize:subview]) {
        NSLog(@"\n\nWARNING: Specifying the width and height for view %@, which has an intrinsic content size.\n\n", subview);
    }
    
    NSLayoutConstraint *bottomConstraint = [[self class] constraintForView:subview insideView:containerView withBottomMargin:0];
    NSLayoutConstraint *heightConstraint = [[self class] constraintForView:subview forHeight:height];
    NSLayoutConstraint *leftConstraint = [[self class] constraintForView:subview insideView:containerView withLeftMargin:0];
    NSLayoutConstraint *rightConstraint = [[self class] constraintForView:subview insideView:containerView withRightMargin:0];
    
    return @[bottomConstraint, heightConstraint, leftConstraint, rightConstraint];
}

+ (NSArray *)constraintsForView:(UIView *)subview insideView:(UIView *)containerView topMargin:(CGFloat)topMargin bottomMargin:(CGFloat)bottomMargin leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin
{
    NSLayoutConstraint *topConstraint = [[self class] constraintForView:subview insideView:containerView withTopMargin:topMargin];
    NSLayoutConstraint *bottomConstraint = [[self class] constraintForView:subview insideView:containerView withBottomMargin:bottomMargin];
    NSLayoutConstraint *leftConstraint = [[self class] constraintForView:subview insideView:containerView withLeftMargin:leftMargin];
    NSLayoutConstraint *rightConstraint = [[self class] constraintForView:subview insideView:containerView withRightMargin:rightMargin];
    
    return @[topConstraint, bottomConstraint, leftConstraint, rightConstraint];
}

+ (NSArray *)constraintsForView:(UIView *)subview insideScrollView:(UIView *)scrollView topMargin:(CGFloat)topMargin leftMargin:(CGFloat)leftMargin
{
    NSLayoutConstraint *topConstraint = [[self class] constraintForView:subview insideView:scrollView withTopMargin:topMargin];
    NSLayoutConstraint *leftConstraint = [[self class] constraintForView:subview insideView:scrollView withLeftMargin:leftMargin];
    NSLayoutConstraint *heightConstraint = [[self class] constraintForView:subview forHeight:subview.frame.size.height];
    NSLayoutConstraint *widthConstraint = [[self class] constraintForView:subview forWidth:subview.frame.size.width];
    return @[topConstraint, heightConstraint, leftConstraint, widthConstraint];
}

+ (NSArray *)constraintsToPutView:(UIView *)currentView belowView:(UIView *)existingView padding:(CGFloat)padding withContainerView:(UIView *)containerView leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin
{
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:currentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:existingView attribute:NSLayoutAttributeBottom multiplier:1 constant:padding];
    
    NSLayoutConstraint *heightConstraint = [[self class] constraintForView:currentView forHeight:currentView.frame.size.height];
    
    NSLayoutConstraint *leftConstraint = [[self class] constraintForView:currentView insideView:containerView withLeftMargin:leftMargin];
    NSLayoutConstraint *rightConstraint = [[self class] constraintForView:currentView insideView:containerView withRightMargin:rightMargin];
    
    return @[topConstraint, heightConstraint, leftConstraint, rightConstraint];
}

+ (NSArray *)constraintsForView:(UIView *)subview insideView:(UIView *)containerView topMargin:(CGFloat)topMargin leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin height:(CGFloat)height
{
    NSLayoutConstraint *topConstraint = [[self class] constraintForView:subview insideView:containerView withTopMargin:topMargin];
    NSLayoutConstraint *leftConstraint = [[self class] constraintForView:subview insideView:containerView withLeftMargin:leftMargin];
    NSLayoutConstraint *rightConstraint = [[self class] constraintForView:subview insideView:containerView withRightMargin:rightMargin];
    NSLayoutConstraint *heightConstraint = [[self class] constraintForView:subview forHeight:height];
    
    return @[topConstraint, leftConstraint, rightConstraint, heightConstraint];
}

+ (NSArray *)constraintsForView:(UIView *)subview insideView:(UIView *)containerView topMargin:(CGFloat)topMargin leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin minimumHeight:(CGFloat)height
{
    NSLayoutConstraint *topConstraint = [[self class] constraintForView:subview insideView:containerView withTopMargin:topMargin];
    NSLayoutConstraint *leftConstraint = [[self class] constraintForView:subview insideView:containerView withLeftMargin:leftMargin];
    NSLayoutConstraint *rightConstraint = [[self class] constraintForView:subview insideView:containerView withRightMargin:rightMargin];
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:height];
    
    return @[topConstraint, leftConstraint, rightConstraint, heightConstraint];
}


+ (NSArray *)constraintsToHorizontallyCenterView:(UIView *)subview insideView:(UIView *)containerView withBottomMargin:(CGFloat)bottomMargin
{
    NSLayoutConstraint *centerXConstraint = [[self class] constraintToHorizontallyCenterView:subview insideView:containerView];
    NSLayoutConstraint *bottomConstraint = [[self class] constraintForView:subview insideView:containerView withBottomMargin:bottomMargin];
    
    return [[self class] addIfNecessaryWidthAndHeightConstraintsToView:subview toConstraints:@[centerXConstraint, bottomConstraint]];
}

+ (NSArray *)constraintsToHorizontallyCenterView:(UIView *)subview insideView:(UIView *)containerView withTopMargin:(CGFloat)topMargin
{
    NSLayoutConstraint *centerYConstraint = [[self class] constraintToHorizontallyCenterView:subview insideView:containerView];
    NSLayoutConstraint *topConstraint = [[self class] constraintForView:subview insideView:containerView withTopMargin:topMargin];
    
    return [[self class] addIfNecessaryWidthAndHeightConstraintsToView:subview toConstraints:@[centerYConstraint, topConstraint]];
}

+ (NSArray *)constraintsForSizedView:(UIView *)subview insideView:(UIView *)containerView topMargin:(CGFloat)topMargin leftMargin:(CGFloat)leftMargin
{
    NSLayoutConstraint *topConstraint = [self constraintForView:subview insideView:containerView withTopMargin:topMargin];
    NSLayoutConstraint *leftConstraint = [self constraintForView:subview insideView:containerView withLeftMargin:leftMargin];
    NSLayoutConstraint *widthConstraint = [self constraintForView:subview forWidth:subview.frame.size.width];
    NSLayoutConstraint *heightConstraint = [self constraintForView:subview forHeight:subview.frame.size.height];
    return @[topConstraint, leftConstraint, widthConstraint, heightConstraint];
}

+ (NSArray *)constraintsToCenterPositionView:(UIView *)bottomView belowView:(UIView *)topView withVerticalSpacing:(CGFloat)verticalSpacing
{
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeBottom  multiplier:1 constant:verticalSpacing];
    NSLayoutConstraint *widthConstraint = [self constraintForView:bottomView forWidth:bottomView.frame.size.width];
    NSLayoutConstraint *heightConstraint = [self constraintForView:bottomView forHeight:bottomView.frame.size.height];
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:bottomView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:topView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    return @[topConstraint, widthConstraint, heightConstraint, centerXConstraint];
}

+ (NSArray *) constraintsToRightPinView:(UIView *)rightView insideView:(UIView *)containerView withMargin:(CGFloat)margin
{
    NSLayoutConstraint *widthConstraint = [self constraintForView:rightView forWidth:rightView.frame.size.width];
    NSLayoutConstraint *heightConstraint = [self constraintForView:rightView forHeight:rightView.frame.size.height];
    NSLayoutConstraint *leftConstraint = [self constraintForView:rightView insideView:containerView withRightMargin:margin];
    NSLayoutConstraint *centerYConstraint = [[self class] constraintToVerticallyCenterView:rightView insideView:containerView];
    return @[widthConstraint, heightConstraint, leftConstraint, centerYConstraint];
}

+ (NSArray *) constraintsToLeftPinView:(UIView *)rightView insideView:(UIView *)containerView withMargin:(CGFloat)margin
{
    NSLayoutConstraint *widthConstraint = [self constraintForView:rightView forWidth:rightView.frame.size.width];
    NSLayoutConstraint *heightConstraint = [self constraintForView:rightView forHeight:rightView.frame.size.height];
    NSLayoutConstraint *leftConstraint = [self constraintForView:rightView insideView:containerView withLeftMargin:margin];
    NSLayoutConstraint *centerYConstraint = [[self class] constraintToVerticallyCenterView:rightView insideView:containerView];
    return @[widthConstraint, heightConstraint, leftConstraint, centerYConstraint];
}


+ (NSArray *)constraintsToPositionView:(UIView *)rightView toTheRightOfView:(UIView *)leftView withMargin:(CGFloat)leftMargin
{
     NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:rightView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:leftView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:rightView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:leftView attribute:NSLayoutAttributeRight multiplier:1 constant:leftMargin];
    return @[centerYConstraint, leftConstraint];
}


#pragma mark - Helper Methods

+ (NSArray *)addIfNecessaryWidthAndHeightConstraintsToView:(UIView *)subview toConstraints:(NSArray *)constraintsArray
{
    if ([[self class] viewHasInstrinicContentSize:subview]) {
        return constraintsArray;
    }
    else {
        NSLayoutConstraint *heightConstraint = [[self class] constraintForView:subview forHeight:subview.frame.size.height];
        NSLayoutConstraint *widthConstraint = [[self class] constraintForView:subview forWidth:subview.frame.size.width];
        return [constraintsArray arrayByAddingObjectsFromArray:@[heightConstraint, widthConstraint]];
    }
}

+ (NSLayoutConstraint *)constraintForView:(UIView *)subview insideView:(UIView *)containerView withBottomMargin:(CGFloat)bottomMargin
{
    return [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:-bottomMargin];
}

+ (NSLayoutConstraint *)constraintForView:(UIView *)subview insideView:(UIView *)containerView withTopMargin:(CGFloat)topMargin
{
    return [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeTop multiplier:1 constant:topMargin];
}

+ (NSLayoutConstraint *)constraintForView:(UIView *)subview insideView:(UIView *)containerView withLeftMargin:(CGFloat)leftMargin
{
    return [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeLeft multiplier:1 constant:leftMargin];
}

+ (NSLayoutConstraint *)constraintForView:(UIView *)subview insideView:(UIView *)containerView withRightMargin:(CGFloat)rightMargin
{
    return [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeRight multiplier:1 constant:-rightMargin];
}

+ (NSLayoutConstraint *)constraintToHorizontallyCenterView:(UIView *)subview insideView:(UIView *)containerView
{
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    return centerXConstraint;
}

+ (NSLayoutConstraint *)constraintToVerticallyCenterView:(UIView *)subview insideView:(UIView *)containerView
{
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    return centerYConstraint;
}

+ (NSLayoutConstraint *)constraintForView:(UIView *)subview forWidth:(CGFloat)width
{
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:width];
    
    return widthConstraint;
}

+ (NSLayoutConstraint *)constraintForView:(UIView *)subview forHeight:(CGFloat)height
{
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1. constant:height];
//    heightConstraint.identifier = kIdentifierHeight;
    
    return heightConstraint;
}

#pragma mark - Check for intrinsic content size

+ (BOOL)viewHasInstrinicContentSize:(UIView *)view
{
    CGSize size = [view intrinsicContentSize];
    if (size.height == UIViewNoIntrinsicMetric || size.width == UIViewNoIntrinsicMetric) {
        return NO;
    }
    return YES;
}

+ (NSLayoutConstraint *)heightConstraintFromArray:(NSArray *)constraintArray
{
    
    
    for (NSLayoutConstraint *constraint in constraintArray) {
        
        if (constraint.firstAttribute == NSLayoutAttributeHeight && constraint.secondAttribute == NSLayoutAttributeNotAnAttribute) {
            return constraint;
        }
        
//        if ([constraint.identifier isEqualToString:kIdentifierHeight]) {
//            return constraint;
//        }
    }
    return nil;
}


+ (NSLayoutConstraint *)topConstraintFromArray:(NSArray *)constraintArray
{
    for (NSLayoutConstraint *constraint in constraintArray) {
        
        if (constraint.firstAttribute == NSLayoutAttributeTop && constraint.secondAttribute == NSLayoutAttributeTop) {
            return constraint;
        }
    }
    return nil;
}

+ (NSLayoutConstraint *)bottomConstraintFromArray:(NSArray *)constraintArray
{
    for (NSLayoutConstraint *constraint in constraintArray) {
        
        if (constraint.firstAttribute == NSLayoutAttributeBottom && constraint.secondAttribute == NSLayoutAttributeBottom) {
            return constraint;
        }
    }
    return nil;
}



@end

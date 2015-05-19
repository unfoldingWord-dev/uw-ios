//
//  NSLayoutConstraint+DWSExtensions.h
//  LocationMapper
//
//  Created by David Solberg on 6/25/13.
//  Copyright (c) 2013 David Solberg. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSLayoutConstraint (DWSExtensions)

+ (NSArray *)constraintsToCenterView:(UIView *)subview insideView:(UIView *)containerView;

+ (NSArray *)constraintsToCenterView:(UIView *)subview insideView:(UIView *)containerView width:(CGFloat)width height:(CGFloat)height;

+ (NSArray *)constraintsForView:(UIView *)subview insideView:(UIView *)containerView topMargin:(CGFloat)topMargin bottomMargin:(CGFloat)bottomMargin leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;

+ (NSArray *)constraintsToHorizontallyCenterView:(UIView *)subview insideView:(UIView *)containerView withBottomMargin:(CGFloat)bottomMargin;

+ (NSArray *)constraintsToHorizontallyCenterView:(UIView *)subview insideView:(UIView *)containerView withTopMargin:(CGFloat)topMargin;

/// Constraints to put a view below another view.
+ (NSArray *)constraintsToPutView:(UIView *)currentView belowView:(UIView *)existingView padding:(CGFloat)padding withContainerView:(UIView *)containerView leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;

/// Constraints for scrollView
+ (NSArray *)constraintsForView:(UIView *)subview insideScrollView:(UIView *)scrollView topMargin:(CGFloat)topMargin leftMargin:(CGFloat)leftMargin;

// One off methods
+ (NSArray *)constraintsForView:(UIView *)subview insideView:(UIView *)containerView topMargin:(CGFloat)topMargin leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin height:(CGFloat)height;

// Set a minimum height
+ (NSArray *)constraintsForView:(UIView *)subview insideView:(UIView *)containerView topMargin:(CGFloat)topMargin leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin minimumHeight:(CGFloat)height;

+ (NSArray *)constraintsTopAnchorView:(UIView *)subview insideView:(UIView *)containerView height:(CGFloat)height;

+ (NSArray *)constraintsForSizedView:(UIView *)subview insideView:(UIView *)containerView topMargin:(CGFloat)topMargin leftMargin:(CGFloat)leftMargin;

+ (NSArray *)constraintsToCenterPositionView:(UIView *)bottomView belowView:(UIView *)topView withVerticalSpacing:(CGFloat)verticalSpacing;

+ (NSArray *)constraintsToPositionView:(UIView *)rightView toTheRightOfView:(UIView *)leftView withMargin:(CGFloat)leftMargin;


+ (NSArray *) constraintsToRightPinView:(UIView *)rightView insideView:(UIView *)containerView withMargin:(CGFloat)margin;
+ (NSArray *) constraintsToLeftPinView:(UIView *)rightView insideView:(UIView *)containerView withMargin:(CGFloat)margin;



/// Special method to get the height constraint in an array. This works with any array of constraints returned from this category, but does NOT generally check for heights in other constraint arrays.
+ (NSLayoutConstraint *)heightConstraintFromArray:(NSArray *)constraintArray;


+ (NSLayoutConstraint *)topConstraintFromArray:(NSArray *)constraintArray;
+ (NSLayoutConstraint *)bottomConstraintFromArray:(NSArray *)constraintArray;

@end

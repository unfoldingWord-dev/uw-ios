//
//  NSLayoutConstraint+DWSExtensions.h
//  LocationMapper
//
//  Created by David Solberg on 6/25/13.
//  Copyright (c) 2013 David Solberg. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSLayoutConstraint (DWSExtensions)

+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsToCenterView:(UIView * __nonnull)subview insideView:(UIView * __nonnull)containerView;

+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsToCenterView:(UIView * __nonnull)subview insideView:(UIView * __nonnull)containerView width:(CGFloat)width height:(CGFloat)height;

+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsForView:(UIView * __nonnull)subview insideView:(UIView * __nonnull)containerView topMargin:(CGFloat)topMargin bottomMargin:(CGFloat)bottomMargin leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;

+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsToHorizontallyCenterView:(UIView * __nonnull)subview insideView:(UIView * __nonnull)containerView withBottomMargin:(CGFloat)bottomMargin;

+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsToHorizontallyCenterView:(UIView * __nonnull)subview insideView:(UIView * __nonnull)containerView withTopMargin:(CGFloat)topMargin;

/// Constraints to put a view below another view.
+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsToPutView:(UIView * __nonnull)currentView belowView:(UIView * __nonnull)existingView padding:(CGFloat)padding withContainerView:(UIView * __nonnull)containerView leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;

/// Constraints to put a view below another view, but uses the intrinsic height.
+ (NSArray <NSLayoutConstraint *>  * __nonnull)constraintsToFloatView:(UIView * __nonnull)currentView belowView:(UIView * __nonnull)existingView padding:(CGFloat)padding withContainerView:(UIView * __nonnull)containerView leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin;

/// Constraints for scrollView
+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsForView:(UIView * __nonnull)subview insideScrollView:(UIView * __nonnull)scrollView topMargin:(CGFloat)topMargin leftMargin:(CGFloat)leftMargin;

// One off methods
+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsForView:(UIView * __nonnull)subview insideView:(UIView * __nonnull)containerView topMargin:(CGFloat)topMargin leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin height:(CGFloat)height;

// Set a minimum height
+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsForView:(UIView * __nonnull)subview insideView:(UIView * __nonnull)containerView topMargin:(CGFloat)topMargin leftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin minimumHeight:(CGFloat)height;

+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsTopAnchorView:(UIView * __nonnull)subview insideView:(UIView * __nonnull)containerView height:(CGFloat)height;
+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsBottomAnchorView:(UIView * __nonnull)subview insideView:(UIView * __nonnull)containerView height:(CGFloat)height;


+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsForSizedView:(UIView * __nonnull)subview insideView:(UIView * __nonnull)containerView topMargin:(CGFloat)topMargin leftMargin:(CGFloat)leftMargin;

+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsToCenterPositionView:(UIView * __nonnull)bottomView belowView:(UIView * __nonnull)topView withVerticalSpacing:(CGFloat)verticalSpacing;

+ (NSArray <NSLayoutConstraint *>  * _Nullable)constraintsToPositionView:(UIView * __nonnull)rightView toTheRightOfView:(UIView * __nonnull)leftView withMargin:(CGFloat)leftMargin;


+ (NSArray <NSLayoutConstraint *>  * _Nullable) constraintsToRightPinView:(UIView * __nonnull)rightView insideView:(UIView * __nonnull)containerView withMargin:(CGFloat)margin;
+ (NSArray <NSLayoutConstraint *>  * _Nullable) constraintsToLeftPinView:(UIView * __nonnull)rightView insideView:(UIView * __nonnull)containerView withMargin:(CGFloat)margin;



/// Special method to get the height constraint in an array. This works with any array of constraints returned from this category, but does NOT generally check for heights in other constraint arrays.
+ (NSLayoutConstraint * _Nullable)heightConstraintFromArray:(NSArray * __nonnull)constraintArray;


+ (NSLayoutConstraint * _Nullable)topConstraintFromArray:(NSArray * __nonnull)constraintArray;
+ (NSLayoutConstraint * _Nullable)bottomConstraintFromArray:(NSArray * __nonnull)constraintArray;

@end

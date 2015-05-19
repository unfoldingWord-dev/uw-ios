//
//  UIViewController+DWSExtensions.h
//

#import <UIKit/UIKit.h>

@interface UIViewController (DWSExtensions)

/*!
 @method
- (void)autoAddChildViewController:(UIViewController *)viewController toViewInSelf:(UIView *)view
 @param  (UIViewController *)viewController
 The view controller you want as a child of the calling viewcontroller. You will need to separately retain a reference to the view controller (usually using a strong property for it).
 @param  (UIView *)viewInSelf
 This is the view in the parent (calling) view controller in which you want to place the child view controller's view inside of another view. Your child view controller's view will be changed to fit viewInSelf's bounds.
 @brief Convenience method to add a child view controller. It takes care of setting the frame to fit and notifying the child view controller with the willMoveToParentViewController: and didMoveToParentViewController:
 */
- (void)autoAddChildViewController:(UIViewController *)viewController toViewInSelf:(UIView *)viewInSelf;


/// Fade out the waiting view created with the fadeInWaitingViewWithShortTitle: method. Does nothing if there is no waiting view.
- (void)fadeOutWaitingView;

/// Fades in a waiting view with the specified title. The title must be less than 20 characters. If the shortTitle is nil or it is too long, the default title will be "Loading..." If the view is already present, the title is updated.
- (void)fadeInWaitingViewWithShortTitle:(NSString *)shortTitle;

/// Whether the waiting view is being shown. This returns YES anytime it is visible, including during the animate in/out.
- (BOOL)isShowingWaitingView;

@end

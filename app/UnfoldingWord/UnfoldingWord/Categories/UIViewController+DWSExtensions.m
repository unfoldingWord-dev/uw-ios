//
//  UIViewController+DWSExtensions.m
//

#import "UIViewController+DWSExtensions.h"
#import "NSLayoutConstraint+DWSExtensions.h"
#import <objc/runtime.h>

static const void *WaitingViewKey = &WaitingViewKey;
static const NSInteger WAITING_LABEL_TAG = 1389;

@implementation UIViewController (DWSExtensions)

- (void)autoAddChildViewController:(UIViewController *)viewController toViewInSelf:(UIView *)viewInSelf
{
    [viewController willMoveToParentViewController:self];
    viewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [viewInSelf addSubview:viewController.view];
    NSArray *constraints = [NSLayoutConstraint constraintsForView:viewController.view insideView:viewInSelf topMargin:0 bottomMargin:0 leftMargin:0 rightMargin:0];
    [viewInSelf addConstraints:constraints];
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
}


#pragma mark - Waiting indicator

- (BOOL)isShowingWaitingView
{
    return ([self retrieveWaitingViewIfAvailable] == nil) ? NO : YES;
}

- (void)setWaitingView:(UIView *)waitingView {
    objc_setAssociatedObject(self, WaitingViewKey, waitingView, OBJC_ASSOCIATION_RETAIN);
    
}

- (UIView *)waitingView {
    return [self waitingViewWithShortTitle:nil];
}

- (UIView *)waitingViewWithShortTitle:(NSString *)shortTitle {
    UIView *waitingView = [self retrieveWaitingViewIfAvailable];
    if ( ! waitingView) {
        UIView *createdWaitingView = [self addWaitingIndicatorToMainViewWithShortTitle:shortTitle];
        [self setWaitingView:createdWaitingView];
        waitingView = [self retrieveWaitingViewIfAvailable];
    }
    
    NSAssert2([waitingView isKindOfClass:[UIView class]], @"%s: The waiting view did not get created properly: %@!", __PRETTY_FUNCTION__, waitingView);
    return waitingView;
}

- (UIView *)retrieveWaitingViewIfAvailable
{
    UIView *waitingView = objc_getAssociatedObject(self, WaitingViewKey);
    if (waitingView && [waitingView isKindOfClass:[UIView class]]) {
        return waitingView;
    }
    else {
        return nil;
    }
}


- (UIView *)addWaitingIndicatorToMainViewWithShortTitle:(NSString *)shortTitle
{
    UIView *completeWaitingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    completeWaitingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    completeWaitingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:completeWaitingView];
    NSArray *backgroundBlockedConstraints = [NSLayoutConstraint constraintsForView:completeWaitingView insideView:self.view topMargin:0 bottomMargin:0 leftMargin:0 rightMargin:0];
    [self.view addConstraints:backgroundBlockedConstraints];
    
    UIView *backgroundShadedBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 60)];
    backgroundShadedBox.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.75];
    backgroundShadedBox.layer.cornerRadius = 15.0f;
    backgroundShadedBox.translatesAutoresizingMaskIntoConstraints = NO;
    [completeWaitingView addSubview:backgroundShadedBox];
    NSArray *constraints = [NSLayoutConstraint constraintsToCenterView:backgroundShadedBox insideView:completeWaitingView];
    [completeWaitingView addConstraints:constraints];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = [self checkedTitleFromTitle:shortTitle];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.tag = WAITING_LABEL_TAG;
    [backgroundShadedBox addSubview:label];
    NSArray *labelconstraints = [NSLayoutConstraint constraintsToCenterView:label insideView:backgroundShadedBox];
    [backgroundShadedBox addConstraints:labelconstraints];
    
    return completeWaitingView;
}


- (void)fadeOutWaitingView
{
    if ([self isShowingWaitingView]) {
        UIView *waitingView = [self waitingView];
        [UIView animateWithDuration:0.25 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            waitingView.layer.opacity = 0.0f;
        } completion:^(BOOL finished) {
            [waitingView removeFromSuperview];
            [self setWaitingView:nil];
        }];
    }
}

- (void)fadeInWaitingViewWithShortTitle:(NSString *)shortTitle
{
    if ([self isShowingWaitingView]) {
        UIView *existingWaitingView = [self waitingView];
        UILabel *waitingLabel = (UILabel *)[existingWaitingView viewWithTag:WAITING_LABEL_TAG];
        if (waitingLabel && [waitingLabel isKindOfClass:[UILabel class]]) {
            waitingLabel.text = [self checkedTitleFromTitle:shortTitle];
        }
        else {
            NSAssert2(NO, @"%s: The waiting label was not found: %@", __PRETTY_FUNCTION__, waitingLabel);
        }
    }
    else {
        UIView *waitingView = [self waitingViewWithShortTitle:shortTitle];
        waitingView.layer.opacity = 0.0;
        [UIView animateWithDuration:0.25 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
            waitingView.layer.opacity = 1.0f;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (NSString *)checkedTitleFromTitle:(NSString *)shortTitle
{
    if ( ! [shortTitle isKindOfClass:[NSString class]] || shortTitle.length >= 20) {
        return @"Loading...";
    }
    else {
        return shortTitle;
    }
}

@end

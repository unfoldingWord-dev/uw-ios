//
//  FPPopoverController.m
//
//  Created by Alvise Susmel on 1/5/12.
//  Copyright (c) 2012 Fifty Pixels Ltd. All rights reserved.
//
//  https://github.com/50pixels/FPPopover


#import "FPPopoverController.h"
#import "NSLayoutConstraint+DWSExtensions.h"
#import "UIViewController+DWSExtensions.h"

//ivars
@interface FPPopoverController()
{
    FPTouchView *_touchView;
    FPPopoverView *_contentView;
    UIViewController *_viewController;
    UIWindow *_window;
    UIView *_fromView;
    UIDeviceOrientation _deviceOrientation;
    
    BOOL _shadowsHidden;
    CGColorRef _shadowColor;
}
@end


//private methods
@interface FPPopoverController(Private)
-(CGPoint)originFromView:(UIView*)fromView;


-(CGFloat)parentWidth;
-(CGFloat)parentHeight;

#pragma mark Space management
/* This methods help the controller to found a proper way to display the view.
 * If the "from point" will be on the left, the arrow will be on the left and the 
 * view will be move on the right of the from point.
 */

-(CGRect)bestArrowDirectionAndFrameFromView:(UIView*)v;

@end

@implementation FPPopoverController
@synthesize delegate = _delegate;
@synthesize contentView = _contentView;
@synthesize touchView = _touchView;
@synthesize contentSize = _contentSize;
@synthesize origin = _origin;
@synthesize arrowDirection = _arrowDirection;
@synthesize tint = _tint;
@synthesize border = _border;
@synthesize alpha = _alpha;

-(void)addObservers
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];   
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:)
     name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willPresentNewPopover:) name:@"FPNewPopoverPresented" object:nil];
    
    _deviceOrientation = [UIDevice currentDevice].orientation;
    
}

- (UIViewController *)internalVC
{
    return _viewController;
}

-(void)removeObservers
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_viewController removeObserver:self forKeyPath:@"title"];
}

-(void)dealloc
{
    [self removeObservers];
    if(_shadowColor) CGColorRelease(_shadowColor);
    
#ifdef FP_DEBUG
    NSLog(@"FPPopoverController dealloc");
#endif

    SAFE_ARC_RELEASE(_contentView);
    SAFE_ARC_RELEASE(_touchView);
    self.delegate = nil;
    
    SAFE_ARC_RELEASE(_viewController);
    _viewController = nil;
    
    SAFE_ARC_SUPER_DEALLOC();
}

-(id)initWithViewController:(UIViewController*)viewController
				   delegate:(id<FPPopoverControllerDelegate>)delegate
                    maxSize:(CGSize)maxSize
{
    self = [super init];
    if(self)
    {
		self.delegate = delegate;
        
        self.alpha = 1.0;
        self.arrowDirection = FPPopoverArrowDirectionAny;
        self.view.userInteractionEnabled = YES;
        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view.clipsToBounds = NO;
        _border = YES;
        
        _touchView = [[FPTouchView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        _touchView.backgroundColor = [UIColor blackColor];
        _touchView.layer.opacity = .25;
        _touchView.clipsToBounds = NO;
        _touchView.translatesAutoresizingMaskIntoConstraints = NO;
        NSArray *touchViewConstraints = [NSLayoutConstraint constraintsForView:_touchView insideView:self.view topMargin:0 bottomMargin:0 leftMargin:0 rightMargin:0];
        [self.view addSubview:_touchView];
        [self.view addConstraints:touchViewConstraints];
        
#if __has_feature(objc_arc)
        //ARC on
        id bself = self;
#else
        //ARC off
        __block id bself = self;
#endif
        
        [_touchView setTouchedOutsideBlock:^{
            [bself dismissPopoverAnimated:YES];
        }];
        
        CGFloat widthMargin = 20.0f;
        CGFloat heightMargin = 40.0f;
        
        CGSize innerContentSize = viewController.view.frame.size;
        
        innerContentSize.height = fmin(innerContentSize.height, maxSize.height);
        innerContentSize.width = fmin(innerContentSize.width, maxSize.width);
        
        innerContentSize.width += widthMargin;
        innerContentSize.height += heightMargin;

        self.contentSize = innerContentSize; //default size

        _contentView = [[FPPopoverView alloc] initWithFrame:CGRectMake(0, 0, self.contentSize.width, self.contentSize.height)];
        
        _viewController = SAFE_ARC_RETAIN(viewController);
        
        [self.view addSubview:_contentView];
        
        [_viewController willMoveToParentViewController:self];
        [_contentView addContentView:_viewController.view];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
        
        //setting contentview
        _contentView.clipsToBounds = NO;
        
        [_viewController addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}


-(void)setTint:(FPPopoverTint)tint
{
    _contentView.tint = tint;
    [_contentView setNeedsDisplay];
}

-(FPPopoverTint)tint
{
    return _contentView.tint;
}

#pragma mark - View lifecycle

-(void)setupView
{
    self.view.frame = CGRectMake(0, 0, [self parentWidth], [self parentHeight]);
    
    //view position, size and best arrow direction
    [self bestArrowDirectionAndFrameFromView:_fromView];

    [_contentView setNeedsDisplay];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //initialize and load the content view
    [_contentView setArrowDirection:FPPopoverArrowDirectionUp];
    [_contentView addContentView:_viewController.view];

    [self setupView];
    [self addObservers];
}

#pragma mark Orientation

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if ([_viewController respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)])
		return [_viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
	return YES;
}


#pragma mark presenting

-(CGFloat)parentWidth
{
    return _parentView.bounds.size.width;
    //return UIDeviceOrientationIsPortrait(_deviceOrientation) ? _parentView.frame.size.width : _parentView.frame.size.height;
}
-(CGFloat)parentHeight
{
    return _parentView.bounds.size.height;
    //return UIDeviceOrientationIsPortrait(_deviceOrientation) ? _parentView.frame.size.height : _parentView.frame.size.width;
}

-(void)presentPopoverFromPoint:(CGPoint)fromPoint
{
    self.origin = fromPoint;
    
    //NO BORDER
    if (self.border == NO)
    {
        _viewController.title = nil;
        _viewController.view.clipsToBounds = YES;
    }
    
    _contentView.relativeOrigin = [_parentView convertPoint:fromPoint toView:_contentView];

    [self.view removeFromSuperview];
    NSArray *windows = [UIApplication sharedApplication].windows;
    if(windows.count > 0)
    {
          _parentView=nil;
        _window = [windows objectAtIndex:0];
        //keep the first subview
        if(_window.subviews.count > 0)
        {
            _parentView = [_window.subviews objectAtIndex:0];
            [_parentView addSubview:self.view];
            [_viewController viewDidAppear:YES];
        }
        
   }
    else
    {
        [self dismissPopoverAnimated:NO];
    }
    
    
    
    [self setupView];
    self.view.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        
        self.view.alpha = self.alpha;
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FPNewPopoverPresented" object:self];
    
    //navigation controller bar fix
    if([_viewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *nc = (UINavigationController*)_viewController;
        UINavigationBar *b = nc.navigationBar;
        CGRect bar_frame = b.frame;
        bar_frame.origin.y = 0;
        b.frame = bar_frame;
    }
}


-(CGPoint)originFromView:(UIView*)fromView
{
    CGPoint p;
    if([_contentView arrowDirection] == FPPopoverArrowDirectionUp ||
       [_contentView arrowDirection] == FPPopoverNoArrow)
    {
        p.x = fromView.frame.origin.x + fromView.frame.size.width/2.0;
        p.y = fromView.frame.origin.y + fromView.frame.size.height;
    }
    else if([_contentView arrowDirection] == FPPopoverArrowDirectionDown)
    {
        p.x = fromView.frame.origin.x + fromView.frame.size.width/2.0;
        p.y = fromView.frame.origin.y;        
    }
    else if([_contentView arrowDirection] == FPPopoverArrowDirectionLeft)
    {
        p.x = fromView.frame.origin.x + fromView.frame.size.width;
        p.y = fromView.frame.origin.y + fromView.frame.size.height/2.0;
    }
    else if([_contentView arrowDirection] == FPPopoverArrowDirectionRight)
    {
        p.x = fromView.frame.origin.x;
        p.y = fromView.frame.origin.y + fromView.frame.size.height/2.0;
    } else {
        p.x = 0;
        p.y = 0;
    }

    return p;
}

-(void)presentPopoverFromView:(UIView*)fromView
{
    SAFE_ARC_RELEASE(_fromView);
    _fromView = SAFE_ARC_RETAIN(fromView);
    [self presentPopoverFromPoint:[self originFromView:_fromView]];
}

-(void)dismissPopover
{
    [self.view removeFromSuperview];
    if([self.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)])
    {
        [self.delegate popoverControllerDidDismissPopover:self];
    }
     _window=nil;
     _parentView=nil;
    
}

-(void)dismissPopoverAnimated:(BOOL)animated {
	[self dismissPopoverAnimated:animated completion:nil];
}

-(void)dismissPopoverAnimated:(BOOL)animated completion:(FPPopoverCompletion)completionBlock
{
    if(animated)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self dismissPopover];
			if (completionBlock)
				completionBlock();
        }];
    }
    else
    {
        [self dismissPopover];
		if (completionBlock)
			completionBlock();
    }
         
}

-(void)setOrigin:(CGPoint)origin
{
    _origin = origin;
}

#pragma mark observing



-(void)deviceOrientationDidChange:(NSNotification*)notification
{
	_deviceOrientation = [UIDevice currentDevice].orientation;

	BOOL shouldResetView = NO;

    //iOS6 has a new orientation implementation.
    //we ask to reset the view if is >= 6.0
	if ([_viewController respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)] &&
        [[[UIDevice currentDevice] systemVersion] floatValue] < 6.0)
	{
		UIInterfaceOrientation interfaceOrientation;
		switch (_deviceOrientation)
		{
			case UIDeviceOrientationLandscapeLeft:
				interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
				break;
			case UIDeviceOrientationLandscapeRight:
				interfaceOrientation = UIInterfaceOrientationLandscapeRight;
				break;
			case UIDeviceOrientationPortrait:
				interfaceOrientation = UIInterfaceOrientationPortrait;
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				interfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
				break;
			default:
				return;	// just ignore face up / face down, etc.
		}
	}
	else
	{
		shouldResetView = YES;
	}

	if (shouldResetView)
		[UIView animateWithDuration:0.2 animations:^{
			[self setupView]; 
		}];
}

-(void)willPresentNewPopover:(NSNotification*)notification
{
    if(notification.object != self)
    {
        if([self.delegate respondsToSelector:@selector(presentedNewPopoverController:shouldDismissVisiblePopover:)])
        {
            [self.delegate presentedNewPopoverController:notification.object
                             shouldDismissVisiblePopover:self];
        }
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == _viewController && [keyPath isEqualToString:@"title"])
    {
        [_contentView setNeedsDisplay];
    }
}


#pragma mark Space management

-(CGRect)bestArrowDirectionAndFrameFromView:(UIView*)v
{
    // thanks @Niculcea
    // If we presentFromPoint with _fromView nil will calculate based on self.orgin with 2x2 size.
    // Fix for presentFromPoint from avolovoy's FPPopover fork
    float width = 2.0f;
    float height = 2.0f;
    CGPoint p = CGPointMake(self.origin.x, self.origin.y);
    
    if (v != nil) {
        p = [v.superview convertPoint:v.frame.origin toView:self.view];
        width = v.frame.size.width;
        height = v.frame.size.height;
    }
    
    
    CGFloat ht = p.y; //available vertical space on top of the view
    CGFloat hb = [self parentHeight] -  (p.y + v.frame.size.height); //on the bottom
    CGFloat wl = p.x; //on the left
    CGFloat wr = [self parentWidth] - (p.x + v.frame.size.width); //on the right
    
    CGFloat best_h = MAX(ht, hb); //much space down or up ?
    CGFloat best_w = MAX(wl, wr);
    
    CGRect r;
    r.size = self.contentSize;

    FPPopoverArrowDirection bestDirection;
    
    //if the user wants vertical arrow, check if the content will fit vertically 
    if(FPPopoverArrowDirectionIsVertical(self.arrowDirection) || 
       (self.arrowDirection == FPPopoverArrowDirectionAny)) // Prefer vertical popovers.
    {

        //ok, will be vertical
        if(ht == best_h || self.arrowDirection == FPPopoverArrowDirectionDown)
        {
            //on the top and arrow down
            bestDirection = FPPopoverArrowDirectionDown;
            
            r.origin.x = p.x + v.frame.size.width/2.0 - r.size.width/2.0;
            r.origin.y = p.y - r.size.height;
        }
        else
        {
            //on the bottom and arrow up
            bestDirection = FPPopoverArrowDirectionUp;

            r.origin.x = p.x + v.frame.size.width/2.0 - r.size.width/2.0;
            r.origin.y = p.y + v.frame.size.height;
        }
    }
    else
    {
        //ok, will be horizontal
        //the arrow must NOT be forced to left
        if((wl == best_w || self.arrowDirection == FPPopoverArrowDirectionRight) && self.arrowDirection != FPPopoverArrowDirectionLeft)
        {
            //on the left and arrow right
            bestDirection = FPPopoverArrowDirectionRight;

            r.origin.x = p.x - r.size.width;
            r.origin.y = p.y + v.frame.size.height/2.0 - r.size.height/2.0;
        }
        else
        {
            //on the right then arrow left
            bestDirection = FPPopoverArrowDirectionLeft;

            r.origin.x = p.x + v.frame.size.width;
            r.origin.y = p.y + v.frame.size.height/2.0 - r.size.height/2.0;
        }
    }
    
    //need to moved left ?
    if(r.origin.x + r.size.width > [self parentWidth])
    {
        r.origin.x = [self parentWidth] - r.size.width;
    }
    
    //need to moved right ?
    else if(r.origin.x < 0)
    {
        r.origin.x = 0;
    }
    
    //need to move up?
    if(r.origin.y < 0)
    {
        r.origin.y = 0;
    }
    
    //need to be resized horizontally ?
    if(r.origin.x + r.size.width > [self parentWidth])
    {
        r.size.width = [self parentWidth] - r.origin.x;
    }
    
    //need to be resized vertically ?
    if(r.origin.y + r.size.height > [self parentHeight])
    {
        r.size.height = [self parentHeight] - r.origin.y;
    }
    
    
    if([[UIApplication sharedApplication] isStatusBarHidden] == NO)
    {
        if(r.origin.y <= 20) r.origin.y += 20;
    }

    //check if the developer wants and arrow
    if(self.arrowDirection != FPPopoverNoArrow)
        _contentView.arrowDirection = bestDirection;
    
    //no arrow
    else _contentView.arrowDirection = FPPopoverNoArrow;

    //using the frame calculated
    _contentView.frame = r;

    self.origin = CGPointMake(p.x + v.frame.size.width/2.0, p.y + v.frame.size.height/2.0);
    _contentView.relativeOrigin = [_parentView convertPoint:self.origin toView:_contentView];

    return r;
}


-(void)setShadowsHidden:(BOOL)hidden
{
    _shadowsHidden = hidden;
    if(hidden)
    {
        _contentView.layer.shadowOpacity = 0;
        _contentView.layer.shadowRadius = 0;
        _contentView.layer.shadowOffset = CGSizeMake(0, 0);
        _shadowColor = CGColorRetain(_contentView.layer.shadowColor);
        _contentView.layer.shadowColor = nil;
    }
    else
    {
        _contentView.layer.shadowOpacity = 0.7;
        _contentView.layer.shadowRadius = 5;
        _contentView.layer.shadowOffset = CGSizeMake(-3, 3);
        _contentView.layer.shadowColor = _shadowColor;
        if(_shadowColor)
        {
            CGColorRelease(_shadowColor);
            _shadowColor=nil;
        }
    }
}

#pragma mark 3D Border

-(void)setBorder:(BOOL)border
{
    _border = border;
    _contentView.border = border;
    [_contentView setNeedsDisplay];
}

#pragma mark Transparency
-(void)setAlpha:(CGFloat)alpha
{
    _alpha = alpha;
    self.view.alpha = alpha;
}




@end

//
//  MainViewController.m
//  ice
//
//  Created by Vicent Tsai on 15/10/25.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MainViewController.h"
#import "SlideMenuViewController.h"

#define SLIDE_TIMING .25

@interface MainViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) SlideMenuViewController *slideMenuViewController;
@property (nonatomic, assign) BOOL showingSlideMenu;

@property (nonatomic, assign) BOOL showMenu;
@property (nonatomic, assign) CGPoint preVelocity;

@property (nonatomic, strong) UIView *overlayView;

@end

@implementation MainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"\u2630"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(btnMoveMenuRight:)];
        bbi.tag = 1;
        navItem.leftBarButtonItem = bbi;
    }

    return self;
}

- (void)loadView
{
    self.view = [[UIScrollView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.overlayView = [[UIView alloc] initWithFrame:self.navigationController.view.frame];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = 0.2;

    [self setupGestures];
}

#pragma mark - Setup View

- (void)resetMainView
{
    if (self.slideMenuViewController != nil) {
        [self.slideMenuViewController.view removeFromSuperview];
        self.slideMenuViewController = nil;

        [self.overlayView removeFromSuperview];

        self.navigationItem.leftBarButtonItem.tag = 1;
        self.showingSlideMenu = NO;
    }
}


#pragma mark - Button Actions

- (void)btnMoveMenuRight:(id)sender
{
    UIButton *button = sender;
    switch (button.tag) {
        case 0: {
            [self moveMenuToOriginalPosition];
            break;
        }

        case 1: {
            [self moveMenuRight];
            break;
        }

        default:
            break;
    }
}

#pragma mark - Menu Actions

- (void)moveMenuToOriginalPosition
{
    UIView *childView = [self getSlideMenuView];

    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         childView.frame = CGRectOffset(childView.frame, -childView.frame.size.width, 0);
                         self.overlayView.alpha = 0.2;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                         }
                     }];
}

- (void)moveMenuRight
{
    UIView *childView = [self getSlideMenuView];

    [UIView animateWithDuration:SLIDE_TIMING delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         childView.frame = CGRectMake(0, 0,
                                                      childView.frame.size.width, childView.frame.size.height);
                         self.overlayView.alpha = 0.7;
                     } completion:^(BOOL finished) {
                         if (finished) {
                             self.navigationItem.leftBarButtonItem.tag = 0;
                         }
                     }];
}

#pragma mark - Setup View

- (UIView *)getSlideMenuView
{
    if (self.slideMenuViewController == nil) {
        self.slideMenuViewController = [[SlideMenuViewController alloc] initWithNibName:@"SlideMenuViewController" bundle:nil];

        [self.view addSubview:self.slideMenuViewController.view];

        [self addChildViewController:self.slideMenuViewController];
        [self.slideMenuViewController didMoveToParentViewController:self];

        self.slideMenuViewController.view.frame = CGRectOffset(self.slideMenuViewController.view.frame,
                                                               -self.slideMenuViewController.view.frame.size.width, 0);

        [self setupSlideMenuGestures:self.slideMenuViewController.view];
    }

    self.showingSlideMenu = YES;

    UIView *view = self.slideMenuViewController.view;

    [self.view addSubview:self.overlayView];
    [self.view bringSubviewToFront:view];

    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOpacity = 0.8;
    view.layer.shadowOffset = CGSizeMake(.2, .2);

    return view;
}

#pragma mark - Swipe Gesture Setup/Actions
#pragma mark - setup

- (void)setupGestures
{
    UIScreenEdgePanGestureRecognizer *edgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc]
                                                           initWithTarget:self
                                                           action:@selector(screenEdgeSwiped:)];
    edgePanRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:edgePanRecognizer];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(mainViewTapped:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)setupSlideMenuGestures:(UIView *)menuView
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(movelMenu:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];

    [menuView addGestureRecognizer:panRecognizer];
}

- (void)movelMenu:(UIGestureRecognizer *)sender
{
    [[[(UITapGestureRecognizer *)sender view] layer] removeAllAnimations];

    CGPoint translatedPoint = [(UIPanGestureRecognizer *)sender translationInView:self.view];
    CGPoint velocity = [(UIPanGestureRecognizer *)sender velocityInView:self.view];

    if (sender.state == UIGestureRecognizerStateEnded) {
        if (velocity.x > 0) {
            NSLog(@"gesture went right");
        } else {
            NSLog(@"gesture went left");
        }

        if (!self.showMenu) {
            [self moveMenuToOriginalPosition];
        } else {
            if (self.showingSlideMenu) {
                [self moveMenuRight];
            }
        }
    }

    if (sender.state == UIGestureRecognizerStateChanged) {
        self.showMenu = sender.view.center.x > 0;

        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [(UIPanGestureRecognizer *)sender setTranslation:CGPointZero inView:self.view];

        self.preVelocity = velocity;

        if (sender.view.frame.origin.x >= 0) {
            sender.view.frame = CGRectMake(0, sender.view.frame.origin.y,
                                           sender.view.frame.size.width, sender.view.frame.size.height);
        }
    }

}

- (void)screenEdgeSwiped:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized) {
        if (!self.showingSlideMenu) {
            [self moveMenuRight];
        }
    }
}

- (void)mainViewTapped:(UIGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self.view];
    if (self.showingSlideMenu) {
        if (CGRectContainsPoint(self.view.frame, location) &&
            !CGRectContainsPoint(self.slideMenuViewController.view.frame, location)) {
            [self moveMenuToOriginalPosition];
        }
    }
}

@end
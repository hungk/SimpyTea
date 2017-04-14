//
//  TimerGraphViewController.m
//  SimplyTea
//
//  Created by Ken Hung on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimerGraphViewController.h"
#import "Infusion.h"
#import "TeaDatabase.h"
#import "iOSVersionCheckUtility.h"

@interface TimerGraphViewController ()
    - (void) setupTimerViewsWithFrameSize;
    - (void) resizeTimerViewsWithFrame: (CGRect) frame;
    - (void) favoritesCallBack: (id) sender;
    - (void) timerToggleCallback: (id) sender;
@end

@implementation TimerGraphViewController
@synthesize graphScrollView, timerGraphScrollView, currentTea, timerScrollView, timerArray, timerViewArray, currentTimerIndex, fadingTitle, graphTimeLabel, graphInfusionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTea: (Tea*) teaObject 
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {        
        // Custom initialization
        self.currentTea = teaObject;
        self.title = self.currentTea.subType1;
        self.timerArray = [[[NSMutableArray alloc] init] autorelease];
        self.timerViewArray = [[[NSMutableArray alloc] init] autorelease];
        self.currentTimerIndex = 0;
    }
    return self;
}

- (void) setupTimerViewsWithFrameSize {
    // relative into the timerScrollView
    CGRect frameSize = CGRectMake(0, 0, self.timerScrollView.bounds.size.width, self.timerScrollView.bounds.size.height);
    
    for (int i = 0; i < [self.currentTea.infusions count]; i++) {
        Timer * timer = [[Timer alloc] initWithNotficationTarget: self andCountdownTime: ((Infusion *)[self.currentTea.infusions objectAtIndex: i]).infusionSeconds];
        timer.tag = i;
        
        TimerView * timerView = [[TimerView alloc] initWithFrame: CGRectMake(frameSize.size.width * i, frameSize.origin.y, frameSize.size.width, frameSize.size.height)];
        [timerView.playPauseButton addTarget: self action: @selector(playPauseAction:) forControlEvents: UIControlEventTouchUpInside];
        timerView.playPauseButton.tag = i;
        [timerView.resetButton addTarget: self action: @selector(resetAction:) forControlEvents: UIControlEventTouchUpInside];
        timerView.resetButton.tag = i;
        timerView.infusionNumberLabel.text = [NSString stringWithFormat: @"Infusion %d", i + 1];
        timerView.timerLabel.text = [Timer timeToDateString: ((Infusion *)[self.currentTea.infusions objectAtIndex: i]).infusionSeconds];
        
        [self.timerArray addObject: timer];
        [self.timerViewArray addObject: timerView];
        
        [self.timerScrollView addSubview: timerView];
        [timerView release];
        [timer release];
    }
    
    self.timerScrollView.pagingEnabled = YES;
    self.timerScrollView.bounces = NO;
    self.timerScrollView.contentSize = CGSizeMake(frameSize.size.width * [self.currentTea.infusions count], frameSize.size.height);
}

- (void) resizeTimerViewsWithFrame: (CGRect) frame {
    int i = 0;

    for (TimerView * timerView in self.timerViewArray) {
        timerView.frame = CGRectMake(frame.size.width * i, frame.origin.y, frame.size.width, frame.size.height);
        [timerView updateViewWithFrame: frame]; // resize buttons
        i++;
    }
    NSLog(@"GSV frame: %f %f %f %f", self.graphScrollView.frame.origin.x, self.graphScrollView.frame.origin.y, self.graphScrollView.frame.size.width, self.graphScrollView.frame.size.height);
    self.timerScrollView.frame = CGRectMake(0, self.graphScrollView.frame.size.height, frame.size.width, frame.size.height);
    self.timerScrollView.contentSize = CGSizeMake(frame.size.width * [self.currentTea.infusions count], frame.size.height);
    
    // reposition timerScrollView to be at the same infusion timer after rotation
    CGRect timerBounds = self.timerScrollView.bounds;
    
    NSLog(@"current timer index: %d",self.currentTimerIndex);
    self.timerScrollView.bounds = CGRectMake(self.currentTimerIndex * timerBounds.size.width, timerBounds.origin.y, timerBounds.size.width, timerBounds.size.height);
}

- (void) resetAction: (id) sender {
    UIButton * button = (UIButton*)sender;
    Timer * timer = (Timer*)[self.timerArray objectAtIndex: button.tag];
    TimerView * timerView = [self.timerViewArray objectAtIndex: button.tag];
    
    [timer resetTimerAndClearTimeSincePause: YES];
    //[timer startTimer];
    [timerView setIsPlaying: NO];
}

- (void) playPauseAction: (id) sender {
    UIButton * button = (UIButton*)sender;
    Timer * timer = (Timer*)[self.timerArray objectAtIndex: button.tag];
    TimerView * timerView = [self.timerViewArray objectAtIndex: button.tag];
    
    [timerView setIsPlaying: ![timerView isPlaying]];
    
    if ([timerView isPlaying]) {
        [timer startTimer];
    } else {
        [timer pauseTimer];
    }
    
    
   // [self.graphScrollView toggleGraphEditability];
   // self.timerScrollView.scrollEnabled = !self.timerScrollView.scrollEnabled;
}

- (void) timerUpdatedWithReamingTime: (NSTimeInterval) timeRemaining calledByTimer: (Timer *)timer{
    TimerView * timerView = [self.timerViewArray objectAtIndex: timer.tag];
    
    timerView.timerLabel.text = [Timer timeToDateString: timeRemaining];
    
    // play sound
    if (timeRemaining == 0) {
        NSString *path;
        
        if (timer.tag == 0) {
            path = [[NSBundle mainBundle] pathForResource:@"Resonant Chime - 32bit" ofType:@"wav"];
        } else if (timer.tag == 1) {
            path = [[NSBundle mainBundle] pathForResource:@"Bell Chord - 32bit" ofType:@"wav"];
        } else {
            path = [[NSBundle mainBundle] pathForResource:@"Bell (long) - 32bit" ofType:@"wav"];
        }
        
        AVAudioPlayer* theAudio=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:NULL];
        theAudio.delegate = self;
        [theAudio play];
    }
}

#pragma mark - InfusionChangeNotification Protocol Methods
- (void) infusionChangeAtInfusion: (Infusion *) infusion timeChange: (BOOL) didTimeChange {
    // NOTE / TO DO: assumption that the Timer, TimerView, Infusions are all lined up in theri respective arrays.
    // In other words, their order matters when redetermining which Infusion corresponds to which Timer and TimerView
    // in their arrays. Index alligned
    
    if (didTimeChange) {
        // Find infusion index - assuming infusionNumber is never less than 0 and infusion number is 1 indexing
        Timer * timer = [self.timerArray objectAtIndex: infusion.infusionNumber - 1];
        TimerView * timerView = [self.timerViewArray objectAtIndex: infusion.infusionNumber - 1];
        
        // TO DO: Add flag in Timer class so TimerViews can query for play state
        [timerView setIsPlaying: NO]; 
        [timer setNewCountdownAndResetTimer: infusion.infusionSeconds];
        
        [timer notifyTargetWithRemainingTime];
    } else {
        // Move TimerView to correct infusion timer - GraphView will automatically highlight
        CGRect bounds = self.timerScrollView.bounds;
        NSInteger x_offset = (infusion.infusionNumber - 1) * bounds.size.width;
        
        self.currentTimerIndex = infusion.infusionNumber - 1;
 
        // Animate to new TimerView
        self.timerScrollView.bounds = CGRectMake(x_offset, bounds.origin.y, bounds.size.width, bounds.size.height);
        
        TimerView * view = [self.timerViewArray objectAtIndex: self.currentTimerIndex];
    
        UIColor * color = view.timerView.backgroundColor;
        view.timerView.backgroundColor = [UIColor whiteColor];
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        view.timerView.backgroundColor = color;
        [UIView commitAnimations];
    }
}

- (void) shouldDisableScrolling: (BOOL) disableScrolling {
    if (disableScrolling) {
        self.timerGraphScrollView.canCancelContentTouches = NO;
        self.graphScrollView.canCancelContentTouches = NO;
    } else {
        self.timerGraphScrollView.canCancelContentTouches = YES;
        self.graphScrollView.canCancelContentTouches = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.timerGraphScrollView.tag = 0;
    //self.graphScrollView.tag = 1;
    self.timerScrollView.tag = 2;
    
    // Do any additional setup after loading the view from its nib.
    self.timerGraphScrollView.pagingEnabled = NO;
    self.timerGraphScrollView.bounces = NO;
    
    [self.graphScrollView initializeGraphViewWithTea: self.currentTea notificationTarget: self];

    [self setupTimerViewsWithFrameSize];
    
    // TO DO: clear magic numbers and clean up
    UIImage* image;
    // Set toggling of favorites
    if (self.currentTea.isFavorite) {
         image = [UIImage imageNamed:@"last-step-assets-star2-04.png"];
    } else {
         image = [UIImage imageNamed:@"last-step-assets-star2-08.png"];
    }
    
    NSMutableArray * rightButtonList = [NSMutableArray array];
    CGRect frameimg = CGRectMake(0, 0, 35, 35);
    
    UIButton *favButton = [[[UIButton alloc] initWithFrame:frameimg] autorelease];
    [favButton setBackgroundImage:image forState:UIControlStateNormal];
    [favButton addTarget:self action:@selector(favoritesCallBack:) forControlEvents:UIControlEventTouchUpInside];
    [favButton setShowsTouchWhenHighlighted:YES]; // highlighting when touched
    
    UIBarButtonItem *favBarButton = [[[UIBarButtonItem alloc] initWithCustomView:favButton] autorelease];
    [rightButtonList addObject: favBarButton];
    
    UIButton *toggleButton = [[[UIButton alloc] initWithFrame:frameimg] autorelease];
    [toggleButton  setBackgroundImage:image forState:UIControlStateNormal];
    [toggleButton addTarget:self action:@selector(timerToggleCallback:) forControlEvents: UIControlEventTouchUpInside];
    [toggleButton setShowsTouchWhenHighlighted:YES]; // highlighting when touched
    
    UIBarButtonItem *toggleBarButton = [[[UIBarButtonItem alloc] initWithCustomView:toggleButton] autorelease];
    [rightButtonList addObject: toggleBarButton];
    
    [self.navigationItem setRightBarButtonItems: rightButtonList animated: YES];
    
    self.timerGraphScrollView.contentSize = CGSizeMake(self.graphScrollView.bounds.size.width, self.graphScrollView.bounds.size.height + self.timerScrollView.bounds.size.height);
    
    self->timerScrollViewHeight = 164; // preserve the portrait height of timerScrollView
}

- (void) favoritesCallBack: (id) sender {
    UIButton * button = (UIButton*)sender;
    
    self.currentTea.isFavorite = !self.currentTea.isFavorite;
    
    UIImage* image;
    // Set toggling of favorites
    if (self.currentTea.isFavorite) {
        image = [UIImage imageNamed:@"last-step-assets-star2-04.png"];
    } else {
        image = [UIImage imageNamed:@"last-step-assets-star2-08.png"];
    }
    
    [[TeaDatabase sharedTeaDatabase] updateTableEntryID: self.currentTea.databaseID withFavorite: self.currentTea.isFavorite inDatabase: self.currentTea.databaseType];
    
    [button setBackgroundImage:image forState:UIControlStateNormal];
}

- (void) timerToggleCallback: (id) sender {
    static BOOL toggle = YES;
    
    CGRect bounds = self.timerGraphScrollView.bounds;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat animationDuration = 0.4f;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (toggle) {
            [UIView animateWithDuration: animationDuration
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.timerGraphScrollView.bounds = CGRectMake(bounds.origin.x, self.timerScrollView.frame.origin.y, bounds.size.width, bounds.size.height);
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        } else {
            [UIView animateWithDuration: animationDuration
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.timerGraphScrollView.bounds = CGRectMake(bounds.origin.x, 0, bounds.size.width, bounds.size.height);
                             }
                             completion:^(BOOL finished) {
                                 
                             }];
        }
        
        toggle = !toggle;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    CGRect screenSize = [UIScreen mainScreen].bounds;
    CGRect frame;

    // This is called first so graphScrollView can set it's frame. then timer views use that updated frame in their calculations
    [self.graphScrollView didRotateFromInterfaceOrientation: fromInterfaceOrientation];
        
    // Now in landscape
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
        // Landscape 52 is the toolbar height
        NSInteger toolbarHeight = 0;
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            toolbarHeight = 64;
        else
            toolbarHeight = 52;
        
        frame = CGRectMake(0, 0, screenSize.size.height, screenSize.size.width - toolbarHeight);
    } else {
        // Portrait
        frame = CGRectMake(0, 0, screenSize.size.width, self->timerScrollViewHeight);
    }

    [self resizeTimerViewsWithFrame: frame];
    self.timerGraphScrollView.contentSize = CGSizeMake(self.graphScrollView.frame.size.width, self.graphScrollView.frame.size.height + frame.size.height);
    
    self.timerScrollView.scrollEnabled = YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    CGRect screenSize = [UIScreen mainScreen].bounds;
    self.timerScrollView.scrollEnabled = NO;
// TO DO; move the timer scroll view off screen before rotating for a smoother transition.
//    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
//        CGRect frame = self.timerScrollView.frame;
//        self.timerScrollView.frame = CGRectMake(frame.origin.x, screenSize.size.width, frame.size.width, frame.size.height);
//    }
}

#pragma mark - Scroll view delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    // Both scroll views call this handle carefully
    
    // timerScrollView
    if (scrollView.tag == 2) {
        NSInteger index = 0;;
        
        // TO DO: if you scroll hard enough, it will skip one iteration of highlight, but then reposition back one iteration
        // e.g. highlight from infusion 1 to infusion 3 then back to 2
        if (lastContentOffset < scrollView.contentOffset.x) {
            index = (int)(self.timerScrollView.bounds.origin.x / self.timerScrollView.bounds.size.width);
        } else if (lastContentOffset >= scrollView.contentOffset.x) {
            index = (int)ceil(self.timerScrollView.bounds.origin.x / self.timerScrollView.bounds.size.width);
        }
        
        if (self.currentTimerIndex < index) {
            [self.graphScrollView incrementGraphInfusionHighlight];
            
            self.currentTimerIndex = index;
        } else if (self.currentTimerIndex > index) {
            [self.graphScrollView decrementGraphInfusionHighlight];
            
            self.currentTimerIndex = index;
        }
        
        lastContentOffset = scrollView.contentOffset.x;
    }
}

- (void) dealloc {    
    [graphScrollView release];
    [timerGraphScrollView release];
    
    [currentTea release];
    
    [timerScrollView release];
    
    [timerArray release];
    [timerViewArray release];
    
    [fadingTitle release];
    [graphTimeLabel release];
    [graphInfusionLabel release];
    
    [super dealloc];
}
@end

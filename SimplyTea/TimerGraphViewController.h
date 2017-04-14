//
//  TimerGraphViewController.h
//  SimplyTea
//
//  Created by Ken Hung on 9/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"
#import "Timer.h"
#import "Tea.h"
#import "TimerView.h"
#import "GraphScrollView.h"

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface TimerGraphViewController : UIViewController <TimerNotificationProtocol, InfusionChangedNotificationProtocol, UIScrollViewDelegate, AVAudioPlayerDelegate> {
    BOOL shouldShowPlay;
    CGRect timerViewFrameInPortrait;
    NSInteger lastContentOffset;
    NSInteger timerScrollViewHeight;
}

@property (nonatomic, retain) IBOutlet UIScrollView * timerGraphScrollView, * timerScrollView;
@property (nonatomic, retain) IBOutlet GraphScrollView * graphScrollView;
@property (nonatomic, retain) Tea * currentTea;
@property (nonatomic, assign) NSInteger currentTimerIndex; // used to keep track of where the scroll view bounds should be after rotation

@property (nonatomic, retain) NSMutableArray * timerArray;
@property (nonatomic, retain) NSMutableArray * timerViewArray;

@property (nonatomic, retain) UILabel * fadingTitle, * graphTimeLabel, * graphInfusionLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTea: (Tea*) teaObject;

- (void) resetAction: (id) sender;
- (void) playPauseAction: (id) sender;
@end

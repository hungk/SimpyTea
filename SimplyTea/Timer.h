//
//  Timer.h
//  SimplyTea
//
//  Created by Ken Hung on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Timer;

// This protocol is used to synchronize Timer and TimerViews through a ViewController
@protocol TimerNotificationProtocol
    @required
        // Check if timeRemaining is 0
        - (void) timerUpdatedWithReamingTime: (NSTimeInterval) timeRemaining calledByTimer: (Timer *) timer;
@end

@interface Timer : NSObject

@property (nonatomic, assign) NSTimer * timer;
// Date to determine elapsed time during updates
@property (nonatomic, retain) NSDate * startDate;
// Time to start counting down from
@property (nonatomic, assign) NSTimeInterval countdownTime, timeSincePause;
@property (nonatomic, retain) id<TimerNotificationProtocol> notificationTarget;
@property (nonatomic, assign) NSInteger tag;

- (id) initWithNotficationTarget: (id<TimerNotificationProtocol>) target andCountdownTime: (NSTimeInterval) timeToCountdown;

- (void) startTimer;
- (void) pauseTimer;
- (void) resetTimerAndClearTimeSincePause: (BOOL) clearTimeSincePause;
- (void) stopTimer;
- (void) setNewCountdownAndResetTimer: (NSTimeInterval) timerToCountdown;
- (void) notifyTargetWithRemainingTime;

+ (NSString *) timeToDateString: (NSTimeInterval) time;
@end

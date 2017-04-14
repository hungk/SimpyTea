//
//  Timer.m
//  SimplyTea
//
//  Created by Ken Hung on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Timer.h"

// Need to add alittle bit of time to the count down time due to function call delays
#define TIMER_ERROR_CORRECTION 0

@implementation Timer
@synthesize timer, startDate, countdownTime, notificationTarget, timeSincePause, tag;

// DO NOT USE init
- (id) init {
    if (self = [super init]) {

    }
    
    return self;
}

- (id) initWithNotficationTarget: (id<TimerNotificationProtocol>) target andCountdownTime: (NSTimeInterval) timeToCountdown {
    if (self = [super init]) {
        self.notificationTarget = target;
        self.countdownTime = timeToCountdown + TIMER_ERROR_CORRECTION;
        self.timeSincePause = 0;
        self.tag = 0;
        
       // [self startTimer];
        // [self resetTimer];
        // [self notifyTargetWithRemainingTime];
    }
    
    return self;
}

- (void) startTimer {
    if (!self.timer || ![self.timer isValid]) {
        [self resetTimerAndClearTimeSincePause: NO];
    }
    
  //  [self notifyTargetWithRemainingTime];
    // Scheduling a timer will cause it to automatically be placed in the run loop to be fired immediately following the intervals
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(notifyTargetWithRemainingTime) userInfo:nil repeats:YES];
    // Immediately tell NSTimer to call it's callback
    [self.timer fire];
}

- (void) pauseTimer {
    if (self.timer) {
        // Record pause time only if the timer was running
        if ([self.timer isValid]) {
            NSDate *currentDate = [NSDate date];
            NSTimeInterval elapsedTime = [currentDate timeIntervalSinceDate: self.startDate];
            
            self.timeSincePause = elapsedTime + self.timeSincePause;
        }
        
        [self stopTimer];
    }
}

- (void) resetTimerAndClearTimeSincePause: (BOOL) clearTimeSincePause {
    [self stopTimer];
    
    if (clearTimeSincePause) {
        self.timeSincePause = 0;
    }
    
    self.startDate = [NSDate date];
    [self notifyTargetWithRemainingTime];
}

- (void) stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void) setNewCountdownAndResetTimer: (NSTimeInterval) timerToCountdown {
    if (timerToCountdown > 0) {
        [self resetTimerAndClearTimeSincePause: YES];
        self.countdownTime = timerToCountdown + TIMER_ERROR_CORRECTION;
    }
}

- (void) notifyTargetWithRemainingTime {
    NSDate *currentDate = [NSDate date];

    // casting elapsed time reduces rounding inconsistencies between NSInteger and NSTimerInterval
    NSTimeInterval elapsedTime = (int)[currentDate timeIntervalSinceDate: self.startDate];
    NSTimeInterval difference = self.countdownTime - (elapsedTime + self.timeSincePause);

    if (difference <= 0) {
        [self stopTimer];
        
        difference = 0;
        
        // Timer has run out, no need to hold this anymore
        self.timeSincePause = 0;
    }
    
    if (self.notificationTarget)
        [self.notificationTarget timerUpdatedWithReamingTime: difference calledByTimer: self];
}

+ (NSString *) timeToDateString: (NSTimeInterval) time {
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970: time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString=[dateFormatter stringFromDate:timerDate];
    [dateFormatter release];
    
    return timeString;
}

- (void) dealloc {
    if (timer) {
        [timer invalidate];
    }
    
    timer = nil;
    [(UIViewController*)notificationTarget release];
    
    [startDate release];
    
    [super dealloc];
}

@end

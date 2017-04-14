//
//  TimerView.h
//  SimplyTea
//
//  Created by Ken Hung on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimerView : UIView {
    BOOL isPlaying;
}

@property (nonatomic, retain) IBOutlet UIView * timerView;
@property (nonatomic, retain) IBOutlet UILabel * timerLabel, * infusionNumberLabel;
@property (nonatomic, retain) IBOutlet UIButton * resetButton, * playPauseButton;

- (BOOL) isPlaying;
- (void) setIsPlaying: (BOOL) play;
- (void) updateViewWithFrame: (CGRect) frame;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;
@end

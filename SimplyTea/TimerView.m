//
//  TimerView.m
//  SimplyTea
//
//  Created by Ken Hung on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimerView.h"

@implementation TimerView
@synthesize timerView, timerLabel, infusionNumberLabel, resetButton, playPauseButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"TimerView" owner:self options:nil];
        [self addSubview: self.timerView];
        self->isPlaying = NO;
        [self.playPauseButton setBackgroundImage: [UIImage imageNamed: @"playbutton.png"] forState:UIControlStateNormal];
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [[NSBundle mainBundle] loadNibNamed:@"TimerView" owner:self options:nil];
    [self addSubview: self.timerView];
    self->isPlaying = NO;
    [self.playPauseButton setBackgroundImage: [UIImage imageNamed: @"playbutton.png"] forState:UIControlStateNormal];
}

- (BOOL) isPlaying {
    return self->isPlaying;
}

- (void) setIsPlaying: (BOOL) play {
    self->isPlaying = play;
    
    if (self->isPlaying) {
        [self.playPauseButton setBackgroundImage: [UIImage imageNamed: @"pause.png"] forState:UIControlStateNormal];
    } else {
        [self.playPauseButton setBackgroundImage: [UIImage imageNamed: @"playbutton.png"] forState:UIControlStateNormal];
    }
}

- (void) updateViewWithFrame: (CGRect) frame {
    self.playPauseButton.frame = frame;
    /*
    if (self->isPlaying) {
        [self.playPauseButton setImage: [TimerView imageWithImage: [UIImage imageNamed: @"pause.png"] scaledToSize: CGSizeMake(frame.size.width, frame.size.height)]  forState:UIControlStateNormal];
    } else {
        [self.playPauseButton setImage: [TimerView imageWithImage: [UIImage imageNamed: @"playbutton.png"] scaledToSize: CGSizeMake(frame.size.width, frame.size.height)] forState:UIControlStateNormal];
    }*/
    [self.playPauseButton setBackgroundImage: nil forState:UIControlStateNormal];
    
    if (self->isPlaying) {
        [self.playPauseButton setBackgroundImage: [UIImage imageNamed: @"pause.png"] forState:UIControlStateNormal];
    } else {
        [self.playPauseButton setBackgroundImage: [UIImage imageNamed: @"playbutton.png"] forState:UIControlStateNormal];
    }
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void) dealloc {
    [timerLabel release];
    [infusionNumberLabel release];
    [resetButton release];
    [playPauseButton release];
    [timerView release];
    
    [super dealloc];
}
@end

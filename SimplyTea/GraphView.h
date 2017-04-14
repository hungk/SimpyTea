//
//  GraphView.h
//  SimplyTea
//
//  Created by Ken Hung on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Infusion;
@class Graph;

@protocol InfusionChangedNotificationProtocol
    @required
        // Gives the target information about infusion data changes from touch events
        - (void) infusionChangeAtInfusion: (Infusion *) infusion timeChange: (BOOL) didTimeChange;
        // Tells the target to stop scrolling so it's touch events dont consume graph view touch events
        - (void) shouldDisableScrolling: (BOOL) disableScrolling;
@end

@interface GraphView : UIView {
    UIInterfaceOrientation currentOrientation;
    // When an infusion is highlited, this holds the base time before any changes
    NSInteger highlightedInfusionBaseTime;
    // When an infusion is highlighted, this holds the touch begin point
    CGPoint highlightedInfusionBasePoint;
    // Text layer
    CGLayerRef textLayer;
}

@property (nonatomic, assign) Infusion * currentInfusion;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, assign) NSInteger highlightedInfusionIndex;
@property (nonatomic, assign) BOOL isEditable; // turn touch handling on/off
@property (nonatomic, assign) id<InfusionChangedNotificationProtocol> notificationTarget;
@property (nonatomic, retain) Graph * graph;

// - (id) initWithFrame:(CGRect)frame andInfusions: (NSMutableArray *) infusionList notificationTarget: (id<InfusionChangedNotificationProtocol>) target;
- (id) initWithFrame:(CGRect)frame graph:(Graph *)graph notificationTarget:(id<InfusionChangedNotificationProtocol>)target;

- (void) refreshDisplay;
- (void) updateLayers;
@end

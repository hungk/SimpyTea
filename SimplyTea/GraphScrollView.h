//
//  GraphScrollView.h
//  SimplyTea
//
//  Created by Ken Hung on 9/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Graph;
@class Tea;
@class GraphOverlayView;
#import "GraphView.h"

@interface GraphScrollView : UIScrollView <UIScrollViewDelegate> {
    CGRect graphScrollViewBoundsInPortrait;
    NSInteger BAR_HEIGHT;
    // Keep track of our current page for paging buttons
    NSInteger currentPage;
}

@property (nonatomic, retain) UILabel * fadingTitle, * graphTimeLabel, * graphInfusionLabel;
@property (nonatomic, retain) Graph * graph;
@property (nonatomic, retain) GraphView * graphView;
@property (nonatomic, retain) GraphOverlayView * graphOverlayView;
@property (nonatomic, retain) UIButton * leftMoreButton, * rightMoreButton;

- (void) initializeGraphViewWithTea: (Tea *) tea notificationTarget: (id<InfusionChangedNotificationProtocol>) target;
- (void) toggleGraphEditability;
- (void) incrementGraphInfusionHighlight;
- (void) decrementGraphInfusionHighlight;
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

- (void) updateGraph;
@end

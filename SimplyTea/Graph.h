//
//  Graph.h
//  SimplyTea
//
//  Created by Ken Hung on 6/8/13.
//
//  Contains the parameters needed to render a graph with a specified Tea.
//

#import <Foundation/Foundation.h>

@class Tea;
@class Infusion;

typedef enum {
    GRAPH_TYPE_BAR,   // Bar Graph
    GRAPH_TYPE_POINT  // Point Graph
} GraphType;

@interface Graph : NSObject
@property (nonatomic, retain) Tea * tea;
@property (nonatomic, retain) NSString * XTitle, * YTitle, * graphTitle;
// Where the X and Y axis begin from coordinate 0.
@property (nonatomic, assign) NSInteger XOffset, YOffset, XVisualBaseline, YVisualBaseline;
// 1 unit of measure for X and Y: Ex 0, 1, 2, 3, ...
@property (nonatomic, assign) CGFloat XUnitLength, YUnitLength;
// 1 unit length displayed per graph notch: Ex 0, 10, 20, 30, ...
@property (nonatomic, assign) NSInteger XUnitDisplayLength, YUnitDisplayLength;
// The number of Unit Display Length Guides to show along the side and bottom of the graph
@property (nonatomic, assign) NSInteger XNotchDisplayCount, YNotchDisplayCount;
@property (nonatomic, assign) GraphType graphType;
// Width of each bar if the Graph Type is a bar graph
@property (nonatomic, assign) NSInteger graphBarWidth;
// Radius of each point if the Graph Type is a point graph
@property (nonatomic, assign) NSInteger graphPointRadius;
// Graph lines used to draw graphe guide lines.
@property (nonatomic, retain) NSMutableArray * graphLines;
@property (nonatomic, assign) BOOL enableGraphLines;
// The number of X notches to show per screen in a scroll view
@property (nonatomic, assign) NSInteger XNotchesPerView;
// Margins
@property (nonatomic, assign) NSInteger graphTopMargin;
// This is the infusion currently highlighted. GraphOverlayView draws the time lable, GraphView draws the line. GraphOverlayView
// KVOs this so it knows when to update itself whenever GraphView changes this value.
@property (nonatomic, assign) Infusion * highlightedInfusion;
// XVisualBaseline (used to draw highlighted time indicator) as the scroll view scrolls
@property (nonatomic, assign) NSInteger XScrollingVisualBaseline;

- (id) initWithTea: (Tea *) tea;

/**
 * This method needs to be called before trying to use any property data in this class otherwise 
 * the Graph data won't have a view space rect to calculate proper parameters.
 *
 * @return: CGRect: returns a new rect that optimizes all graph parameters to fit nicely and should be reapplied to 
 *                  the view that draws the graph
 */
- (CGRect) calculateGraphParametersInRect: (CGRect) rect;
- (NSMutableArray *) updateGraphLines;
- (void) updateHitBoxes;

- (void) resetDefaultGraph;
- (CGFloat) transformSecondsToGraphUnits: (NSInteger) seconds;
- (NSInteger) transformGraphUnitsToSeconds: (CGFloat) graphUnits;
@end

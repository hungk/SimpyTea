//
//  Graph.m
//  SimplyTea
//
//  Created by Ken Hung on 6/8/13.
//
//

#import "Graph.h"
#import "Tea.h"
#import "Infusion.h"
#import "Line.h"

@interface Graph (Priavte)

@end

@implementation Graph
@synthesize tea = tea_, XTitle = XTitle_, YTitle = YTitle_, XOffset = XOffset_, YOffset = YOffset_, graphTitle = graphTitle_, XVisualBaseline = XVisualBaseline_, YVisualBaseline = YVisualBaseline_, XUnitDisplayLength = XUnitDisplayLength_, YUnitDisplayLength = YUnitDisplayLength_, graphType = graphType_, graphBarWidth = graphBarWidth_, XUnitLength = XUnitLength_, YUnitLength = YUnitLength_, XNotchDisplayCount = XNotchDisplayCount_, YNotchDisplayCount = YNotchDisplayCount_, graphLines = graphLines_, XNotchesPerView = XNotchesPerView_, graphTopMargin = graphTopMargin_, highlightedInfusion = highlightedInfusion_, XScrollingVisualBaseline = XScrollingVisualBaseline_;

- (id) initWithTea: (Tea *) tea {
    if (self = [super init]) {
        self.tea = tea;
        [self resetDefaultGraph];
    }
    
    return self;
}

- (void) resetDefaultGraph {
    self.graphType = GRAPH_TYPE_BAR;
    self.XTitle = @"steep";
    self.YTitle = @"time";
    self.XOffset = 60;
    self.YOffset = 60;
    self.XVisualBaseline = self.XOffset;
    self.XScrollingVisualBaseline = self.XVisualBaseline;
    self.YVisualBaseline = self.YOffset - 15;
    self.graphTopMargin = 30;
    self.highlightedInfusion = nil;
    
    self.enableGraphLines = NO;
    
    if (self.tea) {
        self.YNotchDisplayCount = 3;
        self.XNotchDisplayCount = [self.tea.infusions count];
        self.XNotchesPerView = 5;
        self.graphTitle = self.tea.subType1;
    }
    
    // Call this after YNothcDisplayCount and XNotchdisplayCount are set.
    self.graphLines = [self updateGraphLines];
}

- (CGRect) calculateGraphParametersInRect: (CGRect) rect {
    [self resetDefaultGraph];
    
    CGRect viewSpace = rect; // NOTE if the rect extends beyond the view of the device, than 1 view will be calculated
                             // as whatever the passed in rect is.
    
    NSInteger remainingNotches =  self.XNotchDisplayCount - self.XNotchesPerView;
    // TO Do check against negative (if less infusions than notch count per view)
    
    // Given view space, calculate 1 unit for X and Y
    self.XUnitDisplayLength = (viewSpace.size.width - self.XOffset * 2) / self.XNotchesPerView;
    // -1 becuase we are giving space into n - 1 spaces, we are drawing n notches
    self.YUnitDisplayLength = (viewSpace.size.height - self.YOffset - self.graphTopMargin) / (self.YNotchDisplayCount - 1.0);
    
    self.graphBarWidth = self.XUnitDisplayLength * (2.0 / 3.0);
    
    // No negative increments allowed
    if (self.XUnitDisplayLength < 0) {
        self.XUnitDisplayLength = 0;
    }
    
    if (self.YUnitDisplayLength < 0) {
        self.YUnitDisplayLength = 0;
    }
    
    NSLog(@"W_Incre: %d H_Incre: %d width: %f height: %f reamining %d", self.XUnitDisplayLength, self.YUnitDisplayLength, viewSpace.size.width, viewSpace.size.height, remainingNotches);
    
    // calculate 1 unit of measure along the X and Y axis
    self.XUnitLength = self.XUnitDisplayLength / 60.0; // NOT CURRENTLY USED
    self.YUnitLength = self.YUnitDisplayLength / 60.0;
    
    self.graphLines = [self updateGraphLines];
    [self updateHitBoxes];

    return CGRectMake(rect.origin.x, rect.origin.y, self.XNotchDisplayCount * self.XUnitDisplayLength + 2 *self.XOffset, rect.size.height);
}

- (void) updateHitBoxes {
    CGSize hitBoxSize = CGSizeZero;
    
    if (self.graphType == GRAPH_TYPE_BAR) {
        // Calculate the hit boxes for each infusion.
        for (Infusion * infusion in self.tea.infusions) {
            hitBoxSize = CGSizeMake(self.graphBarWidth, [self transformSecondsToGraphUnits: infusion.infusionSeconds]);
            // hitBoxSize.width/ 2 is to position the middile of the box at the exact unit display notch
            infusion.hitBox = CGRectMake(infusion.infusionNumber * self.XUnitDisplayLength + self.XOffset - (hitBoxSize.width / 2),
                                         self.YOffset,
                                         hitBoxSize.width,
                                         hitBoxSize.height);
        }
    } else if (self.graphType == GRAPH_TYPE_POINT) {
        // Calculate hit boxes (use smaller of the two)
        if (self.XUnitDisplayLength < self.YUnitDisplayLength) {
            hitBoxSize = CGSizeMake(self.XUnitDisplayLength, self.XUnitDisplayLength);
        } else {
            hitBoxSize = CGSizeMake(self.YUnitDisplayLength, self.YUnitDisplayLength);
        }
        
        // Calculate the hit boxes for each infusion.
        for (Infusion * infusion in self.tea.infusions) {
            infusion.hitBox = CGRectMake(infusion.infusionNumber * self.XUnitDisplayLength + self.XOffset - (hitBoxSize.width / 2),
                                         [self transformSecondsToGraphUnits: infusion.infusionSeconds] + self.YOffset - (hitBoxSize.height / 2),
                                         hitBoxSize.width,
                                         hitBoxSize.height);
        }
    }
}

- (NSMutableArray *) updateGraphLines {
    NSMutableArray * coordinates = [[NSMutableArray alloc] init];
    
    for (int x = 0; x < self.XNotchDisplayCount; x++) {
        Line * line = [[[Line alloc] initWithStartPoint: CGPointMake(x * self.XUnitDisplayLength, 0) endPoint: CGPointMake(x * self.XUnitDisplayLength, self.YNotchDisplayCount * self.YUnitDisplayLength)] autorelease];
        [coordinates addObject: line];
    }
    
    for (int y = 0; y < self.YNotchDisplayCount; y++) {
        Line * line = [[[Line alloc] initWithStartPoint: CGPointMake(0, y * self.YUnitDisplayLength) endPoint: CGPointMake(self.XNotchDisplayCount * self.XUnitDisplayLength, y * self.YUnitDisplayLength)] autorelease];
        [coordinates addObject: line];
    }
    
    return [coordinates autorelease];
}

// if 1 second and y increment unit is 0.48, converts 60 seconds to 28.8 in Graph units long the y axis
- (CGFloat) transformSecondsToGraphUnits: (NSInteger) seconds {
    return seconds * self.YUnitLength;
}

- (NSInteger) transformGraphUnitsToSeconds: (CGFloat) graphUnits {
    return graphUnits / self.YUnitLength;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"Graph: Count: %d\nXOffset: %d\nYOffset: %d\nXVisualBaseline: %d\nYVisualBaseline: %d\nXunitLength: %f\nYUnitLength: %f\nXUnitDisplayLength: %d\nYUnitDisplayLength:  %d\nXNotchDisplayCount:  %d\nYNotchDisplayCount:  %d\ngraphBarWidth: %d\ngraphPointRadius: %d", [self.tea.infusions count], self.XOffset, self.YOffset, self.XVisualBaseline, self.YVisualBaseline, self.XUnitLength, self.YUnitLength, self.XUnitDisplayLength, self.YUnitDisplayLength, self.XNotchDisplayCount, self.YNotchDisplayCount, self.graphBarWidth, self.graphPointRadius];
}

- (void) dealloc {
    [tea_ release];
    [XTitle_ release];
    [YTitle_ release];
    [graphTitle_ release];
    [graphLines_ release];
    
    [super dealloc];
}
@end

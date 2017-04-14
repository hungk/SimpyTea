//
//  GraphOverlayView.h
//  SimplyTea
//
//  Created by Ken Hung on 6/9/13.
//
//

#import <UIKit/UIKit.h>

@class Graph;

@interface GraphOverlayView : UIView {
    CGLayerRef textLayer;
}

@property (nonatomic, retain) Graph * graph;

- (id) initWithFrame:(CGRect)frame graph:(Graph *)graph;
- (void) updateLayers;
@end

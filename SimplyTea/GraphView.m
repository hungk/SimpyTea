//
//  GraphView.m
//  SimplyTea
//
//  Created by Ken Hung on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GraphView.h"
#import "Line.h"
#import "Infusion.h"
#import "ViewUtilities.h"
#import "Graph.h"
#import "Tea.h"
#import <QuartzCore/QuartzCore.h>

@interface GraphView (Private)
    - (void) drawTextWithContext: (CGContextRef) context contextRect: (CGRect) contextRect;
    - (BOOL) isLandscapeOrientation;
    - (CGPoint) invertPointY: (CGPoint) point;
@end

@implementation GraphView
@synthesize currentInfusion, title, highlightedInfusionIndex, isEditable, notificationTarget, graph = graph_;

+ (Class) layerClass {
    return [CATiledLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // if this function is called (no infusions set) nothing will be drawn in the graph
        
        // Get orientation
        self->currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.userInteractionEnabled = YES;
        self.clearsContextBeforeDrawing = YES;
        self.autoresizesSubviews = YES;
        self.alpha = 1.0f;
        
        self.highlightedInfusionIndex = 0;
        self.isEditable = YES;
        
        // NSString *filePath = [[NSBundle mainBundle] pathForResource:@"bargraph" ofType:@"png"];
        // self->barImage =  CreateInflatedCGImageFromImageNamed(filePath);
        //  UIImage * image = [UIImage imageNamed:@"bargraph@2x.png"];
        //  self->barImage = [UIImage imageWithCGImage: image.CGImage scale: 1.0 orientation: UIImageOrientationDown].CGImage;
        
        self->textLayer = nil;
    }
    
    return self;
}

- (id) initWithFrame:(CGRect)frame graph:(Graph *)graph notificationTarget:(id<InfusionChangedNotificationProtocol>)target {
    if (self = [self initWithFrame: frame]) {
        self.notificationTarget = target;
        self.graph = graph;
        
        self.frame = [self.graph calculateGraphParametersInRect: frame];
        NSLog(@"New Frame: %f %f %f %f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{    
    // Drawing code
    Graph * graph = self.graph;
    
    // get the initial context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // save the current state
    // ++++++++++++++++
    CGContextSaveGState(context);
    
    // inverts y axis and moves origin to bottom left
    // invert for grid lines
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    // Draw Grid Lines
    if (self.graph.enableGraphLines) {
        for (Line * line in self.graph.graphLines) {
            // move the pen to the starting point
            CGContextMoveToPoint(context, line.startPoint.x + graph.XOffset, line.startPoint.y + graph.YOffset);
            // draw a line to another point
            CGContextAddLineToPoint(context, line.endPoint.x + graph.XOffset, line.endPoint.y + graph.YOffset);
        }

        CGContextStrokePath(context);
    }
    
    // restore the state
    // ----------------
    CGContextRestoreGState(context);
    
    // save the current state
    // ++++++++++++++++
    CGContextSaveGState(context);
    int index = 0;
    NSMutableArray * infusions = graph.tea.infusions;
    Infusion * highLightedInfusion = nil;
    // NOTE: The size of the CGLayer scales with performance
    CGLayerRef imageLayer = CGLayerCreateWithContext(context, CGSizeMake(20, 80), nil);
    CGContextRef layerContext = CGLayerGetContext(imageLayer);
    
    // Draw the bar image on a layer
    // inverts y axis and moves origin to top left (reverting the invert at top)
    // ++++++++++++++++
    CGContextSaveGState(layerContext);
    
    // Draw Graph Bars
   // CGContextDrawImage(layerContext, CGRectMake(0, 0, CGImageGetWidth(self->barImage), CGImageGetHeight(self->barImage)) , self->barImage);

    // Draw right side gradient
    CGFloat rColors [] = {
        255.0/255.0, 255.0/255.0, 64.0/255.0, 1.0,
        255.0/255.0, 255.0/255.0, 103.0/255.0, 1.0,
        255.0/255.0, 255.0/255.0, 142.0/255.0, 1.0,
        255.0/255.0, 255.0/255.0, 181.0/255.0, 1.0,
        255.0/255.0, 255.0/255.0, 221.0/255.0, 1.0
    };
    
    CGSize layerSize = CGLayerGetSize(imageLayer);
    CGRect rRect = CGRectMake(0, 0, layerSize.width, layerSize.height);
    
    CGColorSpaceRef rBaseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef rGradient = CGGradientCreateWithColorComponents(rBaseSpace, rColors, NULL, 5);
    CGColorSpaceRelease(rBaseSpace), rBaseSpace = NULL;
    
    CGContextAddRect(layerContext, rRect);
    CGContextClip(layerContext);
    
    // gradient is down to up
    CGPoint rStartPoint = CGPointMake(CGRectGetMidX(rRect), CGRectGetMinY(rRect));
    CGPoint rEndPoint = CGPointMake(CGRectGetMidX(rRect), CGRectGetMaxY(rRect));
    
    CGContextDrawLinearGradient(layerContext, rGradient, rStartPoint, rEndPoint, 0);
    CGGradientRelease(rGradient), rGradient = NULL;

    // http://www.raywenderlich.com/32925/core-graphics-tutorial-shadows-and-gloss
    /* Bar border - border gets clipped when scaling
    CGContextSetRGBStrokeColor(layerContext, 0.1, 0.1, 0.1, 0.2);
    CGContextSetRGBFillColor(layerContext, 0.1, 0.1, 0.1, 0.2);
    CGContextSetLineWidth(layerContext, 3.0f);
    CGRect borderRect = CGRectMake(0, 0, rRect.size.width, rRect.size.height);
    CGContextAddRect(layerContext, borderRect);
    CGContextDrawPath(layerContext, kCGPathStroke);
    */
    
    // restore the state
    // ----------------
    CGContextRestoreGState(layerContext);
    
    // save the current state
    // ++++++++++++++++
    CGContextSaveGState(context);
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -self.bounds.size.height);
    
    // Draw infusion points
    for (Infusion * infusion in infusions) {
        // TODO: invert color change
        // Draw Circle hit box indicator (infusion point)
        //       CGContextSetRGBFillColor(context, (0.4 + i) - (infusion.hitBox.origin.y * 0.002), 0, 0, 0.85);
        //       CGContextFillEllipseInRect(context, infusion.hitBox);
        //       CGContextStrokePath(context);
        
        CGContextDrawLayerInRect(context, infusion.hitBox, imageLayer);

        if (self.highlightedInfusionIndex == index) {
            highLightedInfusion = infusion;
        }
        
        index++;
    }
    
    // restore the state
    // ----------------
    CGContextRestoreGState(context);
    
    CGLayerRelease(imageLayer);
    
    // Draw all graph text
    // NOTE: text is drawn last so it will overlap everything else
    [self drawTextWithContext: context contextRect: self.bounds];
    
    // drawing this last so no graph elements will overlap it
    if (highLightedInfusion) {
        CGRect hitBox = highLightedInfusion.hitBox;
        CGFloat hitBoxTop = hitBox.origin.y + hitBox.size.height;
        CGFloat hitBoxRight = hitBox.origin.x + hitBox.size.width;
        
        // save the current state
        // ++++++++++++++++
        CGContextSaveGState(context);
        
        // inverts y axis and moves origin to top left (reverting the invert at top)
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -self.bounds.size.height);
        
        // Draw highlighting
        CGContextSetRGBFillColor(context, 0, 0.2, 0.1, 0.2);
        CGContextFillRect(context,  hitBox);
        CGContextStrokePath(context);
        
        // restore the state
        // ----------------
        CGContextRestoreGState(context);
        
        // Set this so that GraphOverlay can draw the time label for highlighted infusion
        self.graph.highlightedInfusion = highLightedInfusion;
        
        // save the current state
        // ++++++++++++++++
        CGContextSaveGState(context);
        
        CGContextSetRGBStrokeColor(context, 0.1, 0.1, 0.1, 0.2);
        CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 0.2);
        
        // inverts y axis and moves origin to top left (reverting the invert at top)
        CGContextScaleCTM(context, 1, -1);
        CGContextTranslateCTM(context, 0, -self.bounds.size.height);
        
        // Draw Timer Guide line
        CGContextMoveToPoint(context, graph.XScrollingVisualBaseline, hitBoxTop);
        CGContextAddLineToPoint(context, hitBoxRight, hitBoxTop);
        CGContextStrokePath(context);
        
        // restore the state
        // ----------------
        CGContextRestoreGState(context);
    }
    
    // restore the state
    // ----------------
    CGContextRestoreGState(context);
}

- (void) drawTextWithContext: (CGContextRef) context contextRect: (CGRect) contextRect
{
    // save the current state
    // ++++++++++++++++
    CGContextSaveGState(context);
    Graph * graph = self.graph;
    
    // Create a layer for X notch text and reuse it whenever we can
    // NOTE: The size of the CGLayer scales with performance
    if (!self->textLayer) {
        self->textLayer = CGLayerCreateWithContext(context, CGSizeMake(contextRect.size.width, graph.YVisualBaseline - 15), nil);
        CGContextRef layerContext = CGLayerGetContext(self->textLayer);
        
        // Draw the bar image on a layer
        // inverts y axis and moves origin to top left (reverting the invert at top)
        // ++++++++++++++++
        CGContextSaveGState(layerContext);
        
        // Create a layer for text
        CGContextSetRGBFillColor (layerContext, 0, 0, 0, 1);
        CGContextSetRGBStrokeColor (layerContext, 0, 0, 0, 1);
        
        // Have to give it a 0 transform otherwise weird stuff happens...
        CGAffineTransform myTextTransform = CGAffineTransformMakeRotation  (0 * M_PI/180);
        
        // Draw text for X Notch Display
        for (int i = 0; i <= [self.graph.tea.infusions count]; i++) {
            [ViewUtilities drawTextWithContext: layerContext withTransform: myTextTransform withText: [NSString stringWithFormat: @"%d", i] atPoint: CGPointMake(graph.XOffset + (i * graph.XUnitDisplayLength) - 2, 0) inBounds: CGRectMake(0, 0, contextRect.size.width, graph.YVisualBaseline - 15)]; // 15 and 2 is for spacing between baseline and text
        }
  
        // restore the state
        // ----------------
        CGContextRestoreGState(layerContext);
    }

    // Reuse layer for text
    CGContextDrawLayerInRect(context, CGRectMake(0, contextRect.size.height - graph.YVisualBaseline - 15, contextRect.size.width, graph.YVisualBaseline - 15), self->textLayer);
    
    // restore the state
    // ----------------
    CGContextRestoreGState(context);
}

- (void) refreshDisplay {
    [self setNeedsDisplay];
}

- (void) updateLayers {
    if (self->textLayer) {
        CGLayerRelease(self->textLayer);
        self->textLayer = nil;
    }
}

- (BOOL) isLandscapeOrientation {
    return UIInterfaceOrientationIsPortrait(self->currentOrientation) ? NO : YES;
}

#pragma mark - Touch Callbacks
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isEditable) {
        UITouch * touch = [touches anyObject];
        // invert y axis touch point (we invert y coordinate when drawing graph)
        CGPoint touchPoint = [self invertPointY: [touch locationInView: self]];
        
        NSLog(@"touch began %f %f num touch %d", touchPoint.x, touchPoint.y, [touches count]);
        
        if ([touches count] == 1) {
            // hit boxes are in the Infusions data structure
            NSMutableArray * touchHits = [ViewUtilities collisionWithObjects: self.graph.tea.infusions againstPoint: touchPoint];
            
            if ([touchHits count] > 0) {
                // get the first object hit
                self.currentInfusion = [touchHits objectAtIndex: 0];
                [self.notificationTarget shouldDisableScrolling: YES];
                
                [self.notificationTarget infusionChangeAtInfusion:self.currentInfusion timeChange: NO];
                self.highlightedInfusionIndex = self.currentInfusion.infusionNumber - 1;
                [self refreshDisplay]; // refresh to show highlight on touch down
                
                // Save base time and touch begin point to apply relative bar changes
                self->highlightedInfusionBaseTime = self.currentInfusion.infusionSeconds;
                self->highlightedInfusionBasePoint = touchPoint;
            }
            
            NSLog(@"hit count: %d", [touchHits count]);
        }
    }
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isEditable) {
        UITouch * touch = [touches anyObject];
        // invert y axis touch point (we invert y coordinate when drawing graph)
        CGPoint touchPoint = [self invertPointY: [touch locationInView: self]];
        
        // NSLog(@"touch moved %f %f num touch %d", touchPoint.x, touchPoint.y, [touches count]);

        if (self.currentInfusion && [touches count] == 1 && touchPoint.y - (self.currentInfusion.hitBox.size.height / 2) >= 0 && touchPoint.y - self.graph.YOffset >= 0) {
            self.currentInfusion.infusionSeconds = self->highlightedInfusionBaseTime + [self.graph transformGraphUnitsToSeconds: touchPoint.y - self->highlightedInfusionBasePoint.y /* - self.graph.YOffset*/];
            // TO DO: Don't update every infusion hit box everytime we move
            [self.graph updateHitBoxes];
            [self refreshDisplay];
            
            // Notify ViewController to change timer
            [self.notificationTarget infusionChangeAtInfusion:self.currentInfusion timeChange: YES];
        }
    }
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isEditable) {        
        NSLog(@"touch ended");
        self.currentInfusion = nil;
        [self.notificationTarget shouldDisableScrolling: NO];
    }
}

- (CGPoint) invertPointY: (CGPoint) point {
    return CGPointMake(point.x, self.bounds.size.height - point.y);
}

- (void) dealloc {
    currentInfusion = nil;
    notificationTarget = nil;
    [title release];
    
    if (self->textLayer) {
        CGLayerRelease(self->textLayer);
        self->textLayer = nil;
    }
    
    [super dealloc];
}
@end

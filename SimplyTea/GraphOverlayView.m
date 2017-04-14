//
//  GraphOverlayView.m
//  SimplyTea
//
//  Created by Ken Hung on 6/9/13.
//
//

#import "GraphOverlayView.h"
#import "Graph.h"
#import "Infusion.h"
#import <QuartzCore/QuartzCore.h>

@implementation GraphOverlayView
@synthesize graph = graph_;

+ (Class) layerClass {
    return [CATiledLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.userInteractionEnabled = NO;
        self.clearsContextBeforeDrawing = YES;
        self.autoresizesSubviews = YES;
        self.alpha = 1.0f;
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame graph:(Graph *)graph {
    if (self = [self initWithFrame: frame]) {
        self.graph = graph;
        [self.graph addObserver: self forKeyPath:@"highlightedInfusion" options:NSKeyValueObservingOptionNew context: nil];
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void) drawRect:(CGRect)rect {
    // get the initial context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context); // ===============
    
    [self drawContentFromLayerToContext: context contextRect: self.bounds];

    CGAffineTransform myTextTransform = CGAffineTransformMakeRotation  (0 * M_PI/180);
    
    // Draw time indicator text for highlighted infusion
    CGContextSetRGBStrokeColor(context, 0.1, 0.1, 0.1, 0.3);
    CGContextSetRGBFillColor(context, 0.1, 0.1, 0.1, 0.3);
    
    NSString * timeString = [NSString stringWithFormat:@"%d:%.2d", self.graph.highlightedInfusion.infusionSeconds / 60, self.graph.highlightedInfusion.infusionSeconds % 60];
    // TO DO: figure out text width and height
    NSInteger textWidth = 35;
    NSInteger textHeight = 6;
        
    [ViewUtilities drawTextWithContext: context withTransform: myTextTransform withText: timeString atPoint: CGPointMake(self.graph.XVisualBaseline - textWidth, self.graph.highlightedInfusion.hitBox.origin.y + self.graph.highlightedInfusion.hitBox.size.height - textHeight / 2) inBounds: self.bounds];
    
    CGContextRestoreGState(context); // ===================
}

- (void) drawContentFromLayerToContext: (CGContextRef) context contextRect: (CGRect) contextRect {
    // TO DO: no magic numbers
    // - 3 centers the mid point of the text along the grid ling
    // 35 is a magic number gestimating the length of text
    NSInteger textLength = 35;
    NSInteger textLengthY = 3;

    CGContextSaveGState(context); // ===============
    
    if (!self->textLayer) {
        self->textLayer = CGLayerCreateWithContext(context, contextRect.size, nil);
        CGContextRef layerContext = CGLayerGetContext(self->textLayer);
        
        // Draw the bar image on a layer
        // inverts y axis and moves origin to top left (reverting the invert at top)
        // ++++++++++++++++
        CGContextSaveGState(layerContext);
        
        // Draw side gradients
        CGFloat lColors [] = {
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 1.0,
            1.0, 1.0, 1.0, 0.8,
            1.0, 1.0, 1.0, 0.3
        };
        
        CGRect lRect = CGRectMake(0, 0, self.graph.XVisualBaseline, self.frame.size.height);
        
        // Draw left side gradient
        CGColorSpaceRef lBaseSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef lGradient = CGGradientCreateWithColorComponents(lBaseSpace, lColors, NULL, 4);
        CGColorSpaceRelease(lBaseSpace), lBaseSpace = NULL;
        
        CGContextAddRect(layerContext, lRect);
        CGContextClip(layerContext);
        
        CGPoint lStartPoint = CGPointMake(CGRectGetMinX(lRect), CGRectGetMidY(lRect));
        CGPoint lEndPoint = CGPointMake(CGRectGetMaxX(lRect), CGRectGetMidY(lRect));
        
        CGContextDrawLinearGradient(layerContext, lGradient, lStartPoint, lEndPoint, 0);
        CGGradientRelease(lGradient), lGradient = NULL;
        
        //  CGContextAddRect(context, lRect);
        //  CGContextDrawPath(context, kCGPathStroke);
        
        CGContextRestoreGState(layerContext); // ===============
        CGContextSaveGState(layerContext); // ===============
        
        // Draw right side gradient
        CGFloat rColors [] = {
            1.0, 1.0, 1.0, 0.0,
            1.0, 1.0, 1.0, 0.6,
            1.0, 1.0, 1.0, 0.9,
            1.0, 1.0, 1.0, 1.0
        };
        
        CGRect rRect = CGRectMake(self.frame.size.width - self.graph.XVisualBaseline, 0, self.graph.XVisualBaseline, self.frame.size.height);
        
        CGColorSpaceRef rBaseSpace = CGColorSpaceCreateDeviceRGB();
        CGGradientRef rGradient = CGGradientCreateWithColorComponents(rBaseSpace, rColors, NULL, 3);
        CGColorSpaceRelease(rBaseSpace), rBaseSpace = NULL;
        
        CGContextAddRect(layerContext, rRect);
        CGContextClip(layerContext);
        
        CGPoint rStartPoint = CGPointMake(CGRectGetMinX(rRect), CGRectGetMidY(rRect));
        CGPoint rEndPoint = CGPointMake(CGRectGetMaxX(rRect), CGRectGetMidY(rRect));
        
        CGContextDrawLinearGradient(layerContext, rGradient, rStartPoint, rEndPoint, 0);
        CGGradientRelease(rGradient), rGradient = NULL;
        
        // CGContextAddRect(context, rRect);
        // CGContextDrawPath(context, kCGPathStroke);
        
        CGContextRestoreGState(layerContext); // ===============
        
        // save the current state, as we'll overwrite this
        CGContextSaveGState(layerContext); // ===============
        
        // inverts y axis and moves origin to top left (reverting the invert at top)
        CGContextScaleCTM(layerContext, 1, -1);
        CGContextTranslateCTM(layerContext, 0, -self.bounds.size.height);
        
        CGContextSetRGBStrokeColor(layerContext, 0.1, 0.1, 0.1, 0.2);
        CGContextSetRGBFillColor(layerContext, 0.1, 0.1, 0.1, 0.2);
        
        // Draw YVisualBaseline
        CGContextMoveToPoint(layerContext, self.graph.XVisualBaseline, self.graph.YVisualBaseline);
        CGContextAddLineToPoint(layerContext, self.graph.XVisualBaseline, self.graph.YNotchDisplayCount * self.graph.YUnitDisplayLength - self.graph.graphTopMargin
                                + (self.graph.YOffset - self.graph.YVisualBaseline) - textLengthY);
        CGContextStrokePath(layerContext);
        
        // Draw XVisualBaseline
        CGContextMoveToPoint(layerContext, self.graph.XVisualBaseline, self.graph.YVisualBaseline);
        CGContextAddLineToPoint(layerContext, self.graph.XNotchDisplayCount * self.graph.XUnitDisplayLength, self.graph.YVisualBaseline);
        CGContextStrokePath(layerContext);
        
        CGContextRestoreGState(layerContext); // ===============
        
        CGContextSaveGState(layerContext); // ===============
        
        CGContextSetRGBStrokeColor(layerContext, 0.0, 0.8, 0.3, 0.8);
        CGContextSetRGBFillColor(layerContext, 0.0, 0.8, 0.3, 0.8);
        
        // Draw Y Title
        CGAffineTransform myTextTransform = CGAffineTransformMakeRotation  (M_PI * -90 /180);
        
        // TO DO: figure out text width and height
        NSInteger position = 10;
        [ViewUtilities drawTextWithContext: layerContext withTransform: myTextTransform withText: self.graph.YTitle atPoint: CGPointMake(position, self.frame.size.height / 2) inBounds:self.bounds];
        // Draw X Title
        myTextTransform = CGAffineTransformMakeRotation  (M_PI * 0 /180);
        [ViewUtilities drawTextWithContext: layerContext withTransform: myTextTransform withText: self.graph.XTitle atPoint: CGPointMake(self.frame.size.width / 2, position) inBounds: self.bounds];
        
        CGContextRestoreGState(layerContext); // ===============
        
        CGContextSaveGState(layerContext); // ================
        // Have to give it a 0 transform otherwise weird stuff happens...
        myTextTransform = CGAffineTransformMakeRotation  (0 * M_PI/180);
        
        for (int i = 0; i < self.graph.YNotchDisplayCount; i++) {
            [ViewUtilities drawTextWithContext: layerContext withTransform: myTextTransform withText: [NSString stringWithFormat: @"%d:00",  i] atPoint: CGPointMake(self.graph.XVisualBaseline - textLength, self.graph.YOffset + (i * self.graph.YUnitDisplayLength) - textLengthY) inBounds: self.bounds];
        }
        
        // draw title
        [ViewUtilities drawTextWithContext: layerContext withTransform: myTextTransform withText: self.graph.graphTitle atPoint: CGPointMake(self.bounds.size.width / 2, self.bounds.size.height - self.graph.graphTopMargin) inBounds: self.bounds];
        
        // restore the state
        // ----------------
        CGContextRestoreGState(layerContext);
    }
    
    // Reuse layer for text
    CGContextDrawLayerInRect(context, contextRect, self->textLayer);
    
    CGContextRestoreGState(context); // ===================
}

- (void) updateLayers {
    if (self->textLayer) {
        CGLayerRelease(self->textLayer);
        self->textLayer = nil;
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString: @"highlightedInfusion"]) {
        [self setNeedsDisplay];
    }
}

- (void) dealloc {
    [graph_ removeObserver: self forKeyPath: @"highlightedInfusion"];
    [graph_ release];
    
    if (self->textLayer) {
        CGLayerRelease(self->textLayer);
        self->textLayer = nil;
    }
    
    [super dealloc];
}

@end

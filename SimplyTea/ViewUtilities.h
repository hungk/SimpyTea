//
//  ViewUtilities.h
//  SimplyTea
//
//  Created by Ken Hung on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// Suppose to be a general utilities, but it's specific to Infusion class

#import <Foundation/Foundation.h>
@class Infusion;

typedef enum {
    POINT_SHAPE_CIRCLE,
    POINT_SHAPE_RECT,
    POINT_SHAPE_RECT_2 // Same as POINT_SHAPE_RECT but with a longer y min hit range
} PointShape;

@interface ViewUtilities : NSObject

+ (BOOL) collisionWithObject: (Infusion *) object againstPoint: (CGPoint) point;
+ (NSMutableArray *) collisionWithObjects: (NSArray *) objects againstPoint: (CGPoint) point;

+ (void) drawTextWithContext:(CGContextRef)context withTransform: (CGAffineTransform) transform withText: (NSString *) text atPoint: (CGPoint) point inBounds: (CGRect) bounds;
@end

/**
 * This take a compressed PNG and without uncompressing it, places it upon a new btmap then
 * returns a CGImageRef of it.
 *
 * NOTE: CGImageRelease MUST be called on the return when finished.
 */
CGImageRef CreateInflatedCGImageFromImageNamed(NSString *fileName);
CGImageRef CreateCGImageFromImageNamed(NSString *fileName);

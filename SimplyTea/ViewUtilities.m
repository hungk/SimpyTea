//
//  ViewUtilities.m
//  SimplyTea
//
//  Created by Ken Hung on 7/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewUtilities.h"
#import "Infusion.h"

@interface ViewUtilities (Private)

@end

@implementation ViewUtilities

// Returns a list of objects hit
+ (NSMutableArray *) collisionWithObjects: (NSArray *) objects againstPoint: (CGPoint) point {
    NSMutableArray * hitList = [[[NSMutableArray alloc] init] autorelease];
    
    for (Infusion * obj in objects) {
        if ([self collisionWithObject: obj againstPoint: point]) {
            [hitList addObject: obj];
        }
    }
    
    return hitList;
}

// Used to check touch point within the the bounds of a shape (i.e. Circle, square... etc)
+ (BOOL) collisionWithObject: (Infusion *) object againstPoint: (CGPoint) point {
    CGRect rect = object.hitBox;
    float xRadius = rect.size.width / 2;
    float yRadius = rect.size.height / 2;
    float xOrigShifted = (rect.origin.x + xRadius);
    float yOrigShifted = (rect.origin.y + yRadius);
    
    // Note: CGRect origin is at top left
    if (object.pointShape == POINT_SHAPE_CIRCLE) {
        float xDist, yDist, distance;
        
        // Point to Circle Test
        xDist = point.x - xOrigShifted;
        yDist = point.y - yOrigShifted;
        distance = sqrtf(xDist * xDist + yDist * yDist);
        
        if (distance <= MAX(xRadius, yRadius)) {
            return YES;
        }
    } else if (object.pointShape == POINT_SHAPE_RECT) {
        float xMin = xOrigShifted - xRadius;
        float xMax = xOrigShifted + xRadius;
        float yMin = yOrigShifted - yRadius;
        float yMax = yOrigShifted + yRadius;
        
        // Point to Box Test
        if (point.x <= xMax && point.x >= xMin && point.y <= yMax && point.y >= yMin) {
            return YES;
        }
    } else if (object.pointShape == POINT_SHAPE_RECT_2) {
        float xMin = xOrigShifted - xRadius;
        float xMax = xOrigShifted + xRadius;
        float yMin = yOrigShifted - 2 * yRadius;
        float yMax = yOrigShifted + yRadius;
        
        // Point to Box Test
        if (point.x <= xMax && point.x >= xMin && point.y <= yMax && point.y >= yMin) {
            return YES;
        }
    }
    
    return NO;
}

// NOTE: text box ORIGIN is BOTTOM LEFT
+ (void) drawTextWithContext:(CGContextRef)context withTransform: (CGAffineTransform) transform withText: (NSString *) text atPoint: (CGPoint) point inBounds: (CGRect) bounds {
    CGContextSaveGState(context);
    
    //inverts y axis and moves origin to bottom left
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    CGContextSelectFont (context, "Arial", 12, kCGEncodingMacRoman);
    CGContextSetCharacterSpacing (context, 2);
    CGContextSetTextDrawingMode (context, kCGTextFillStroke);
    
    // User transform parameter here
    CGContextSetTextMatrix (context, transform);
    CGContextShowTextAtPoint (context, point.x, point.y, [text UTF8String], [text length]);
    
    CGContextRestoreGState(context);
}

@end

/**
 * http://www.benmcdowell.com/blog/2012/01/12/speeding-up-cgcontextdrawimage-calls-in-ios-4/
 */
CGImageRef CreateInflatedCGImageFromImageNamed(NSString *fileName)
{
    /* NOT USED
    CGImageRef sourceImage = CreateCGImageFromImageNamed(fileName);
    
    //Parameters needed to create the bitmap context
    size_t width = CGImageGetWidth(sourceImage);
    size_t height = CGImageGetHeight(sourceImage);
    size_t bitsPerComponent = 8;    //Each component is 1 byte, so 8 bits
    size_t bytesPerRow = 4 * width; //Uncompressed RGBA is 4 bytes per pixel
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    //Create uncompressed context, draw the compressed source image into it
    //and save the resulting image.
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), sourceImage);
    CGImageRef inflatedImage = CGBitmapContextCreateImage(context);
    
    //Tidy up
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CGImageRelease(sourceImage);
    
    return inflatedImage;
     */
    return nil;
}

//iOS and Mac OS X compatible function to return a CGImageRef
//loaded from an image file.
CGImageRef CreateCGImageFromImageNamed(NSString *fileName)
{
    //Read in the image file using the appropriate iOS or Mac OS image class
#if (TARGET_OS_IPHONE)
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:fileName];
#else
    NSImage *imageFile = [[NSImage alloc] initWithContentsOfFile: fileName];
    NSBitmapImageRep *image = [[NSBitmapImageRep alloc] initWithData:[imageFile TIFFRepresentation]];
    [imageFile release];
#endif
    
    //Extract CG Image from image class
    CGImageRef cgImage = image.CGImage;
    
    //Ensure that the CG Image was loaded correctly
    if (!cgImage) {
        NSLog(@"%s Failed to load image %@", __PRETTY_FUNCTION__, fileName);
        [image release];
        return nil;
    }
    
    //We need to return a retained CG Image, but can discard the iOS/Mac OS image
    CGImageRetain(cgImage);
    [image release];
    
    return cgImage;
}
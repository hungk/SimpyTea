//
//  Line.m
//  SimplyTea
//
//  Created by Ken Hung on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Line.h"

@implementation Line
@synthesize startPoint, endPoint;

- (id) initWithStartPoint: (CGPoint) start endPoint: (CGPoint) end {
    if (self = [super init]) {
        self.startPoint = start;
        self.endPoint = end;
    }
        
    return self;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"Start (%f, %f) End: (%f, %f)", self->startPoint.x, self->startPoint.y, self->endPoint.x, self->endPoint.y];
}
@end

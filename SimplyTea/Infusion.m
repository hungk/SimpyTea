//
//  Infusion.m
//  SimplyTea
//
//  Created by Ken Hung on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Infusion.h"

@implementation Infusion
@synthesize infusionNumber, infusionSeconds, hitBox, pointShape;

- (id) initWithInfusionNumber: (NSInteger) number secondsToInfuse: (NSInteger) seconds {
    if (self = [super init]) {
        self.infusionNumber = number;
        self.infusionSeconds = seconds;
        // Should be redefined
        // This is touch box for this infusion
        self.hitBox = CGRectMake(0, 0, 0, 0);
        self.pointShape = POINT_SHAPE_RECT_2;
    }
    
    return self;
}

- (void) copyValuesFromInfusion: (Infusion *) infusion {
    self.infusionNumber = infusion.infusionNumber;
    self.infusionSeconds = infusion.infusionSeconds;
    self.hitBox = infusion.hitBox;
    self.pointShape = infusion.pointShape;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"Infusion: %d, At %d Seconds", self.infusionNumber, self.infusionSeconds];
}
@end

//
//  Infusion.h
//  SimplyTea
//
//  Created by Ken Hung on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewUtilities.h"

@interface Infusion : NSObject
@property (nonatomic, assign) NSInteger infusionNumber, infusionSeconds;
@property (nonatomic, assign) CGRect hitBox;
@property (nonatomic, assign) PointShape pointShape;

- (id) initWithInfusionNumber: (NSInteger) number secondsToInfuse: (NSInteger) seconds;
- (void) copyValuesFromInfusion: (Infusion *) infusion;
@end

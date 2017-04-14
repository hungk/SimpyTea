//
//  TeaInputValidation.h
//  SimplyTea
//
//  Created by Ken Hung on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NUMBERIC_INPUT,
    INFUSION_TIME_INPUT,
    TEXT_INPUT
} TeaInputType;

@interface TeaInputValidation : NSObject {
    
}

+ (BOOL) validateStringInput: (NSString *) input ofType: (TeaInputType) type;
+ (BOOL) isValidInfusionTimeString: (NSString *) infusionTimeString;
+ (BOOL) isValidNumberString: (NSString *) numberString output: (NSInteger *) outputInt;
+ (BOOL) isValidNumber: (NSInteger) number;

+ (BOOL) isInfusionStringTimeWithinLimits: (NSString *) minutes andSeconds: (NSString *) seconds;
@end

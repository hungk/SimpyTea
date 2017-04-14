//
//  TeaInputValidation.m
//  SimplyTea
//
//  Created by Ken Hung on 9/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TeaInputValidation.h"
#import "AlertUtility.h"

#define TIME_CHAR_LIMIT 4
#define INVALID -1
#define MAX_SECONDS 300 // 5 minutes
#define MIN_SECONDS 0
#define MIN_MINUTES 0
#define MAX_MINUTES 5

@implementation TeaInputValidation
+ (BOOL) validateStringInput: (NSString *) input ofType: (TeaInputType) type {
    BOOL result = YES;
    AlertUtility * alert = [[AlertUtility alloc] init];
    
    switch (type) {
        case NUMBERIC_INPUT:
            if (![self isValidNumberString: input output: nil]) {
                [alert showAlertWithTitle: @"Could not recognize number" andMessage: @"Example: 2:34 for two minutes and thirty-four seconds."];
                
                NSLog(@"Invalid infusion time or format!");
                
                result = NO;
            }
            
            break;
        case INFUSION_TIME_INPUT:
            if (![self isValidInfusionTimeString: input]) {
                [alert showAlertWithTitle: @"Could not recognize number" andMessage: @"Example: 34 for thirty-four seconds."];
                
                NSLog(@"Invalid number format!");
                
                result = NO;
            }
            
            break;
        case TEXT_INPUT:
            
            break;
        default:
            break;
    }
    
    return result;
}


+ (BOOL) isValidInfusionTimeString: (NSString *) infusionTimeString {
    BOOL result = NO;
    
    const char * cStr = [infusionTimeString UTF8String];
    
    // String should not be longer than 4 characters (excluding the terminating null)
    if (infusionTimeString.length > TIME_CHAR_LIMIT) {
        return result;
    }
    
    // String is allowed one ':', '.', '-', to separate minute and seconds ex: 1-22, 1:22, 1.22
    int locatedIndex = INVALID;
    
    for (int i = 0; i < TIME_CHAR_LIMIT; i++) {
        if (cStr[i] == ':' || cStr[i] == '.' || cStr[i] == '-') {
            // These symbols must be exactly at index 1 eg: :000, 00.0, 000- are all invalid
            if (i != 1) {
                return result;
            }
            
            locatedIndex = i;
        }
    }
    
    // Seconds can overflow but not past 99. Highest time is 9.99
    
    // Check if an int is parsable. If locatedIndex is Valid, check both sides of the symbol
    if (locatedIndex != INVALID) {
        NSString * sub1 = [infusionTimeString substringToIndex: locatedIndex];
        NSString * sub2 = [infusionTimeString substringFromIndex: locatedIndex + 1];
        
        result = [self isInfusionStringTimeWithinLimits: sub1 andSeconds: sub2];
    } else {
        result = [self isInfusionStringTimeWithinLimits: nil andSeconds: infusionTimeString];
    }
    
    return result;
}

// In the case of 1:2s or any other character, the 's' will be ignored by default
// Before calling this function, make sure isValidInfusionTimeString is called first to weed out invalid formatting
+ (BOOL) isInfusionStringTimeWithinLimits: (NSString *) minutes andSeconds: (NSString *) seconds {
    BOOL result = NO;
    
    if (seconds == nil) {
        return result;
    }
    
    NSInteger min, sec;

    // check seconds string
    if (![self isValidNumberString: seconds output: &sec]) {
        return result;
    }
    
    if (sec >= MIN_SECONDS && sec <= MAX_SECONDS) {
        result = YES;
    }
    
    if (minutes != nil) {
        // merge both minutes and seconds and check the resutl against the min and max limites
        // check minutes string
        if (![self isValidNumberString: minutes output: &min]) {
            return result;
        }
        
        if (min >= MIN_MINUTES && min <= MAX_MINUTES) {
            result = YES;
        }
        
        // check the merged result of minutes and seconds
        if (min * 60 + sec <= MAX_SECONDS) {
            result = YES;
        }
    }
    
    return result;
}

// TODO: maybe check for non numberic characters
+ (BOOL) isValidNumberString: (NSString *) numberString output: (NSInteger *) outputInt {
    BOOL result = NO;
    
    NSScanner * scanner = [NSScanner scannerWithString: numberString];
    
    NSInteger num;
    
    if([scanner scanInt: &num]) {
        if ([self isValidNumber: num]) {
            result = YES;
        }
    }
    
    if (outputInt) {
        if (result)
            *outputInt = num;
        else
            *outputInt = NSNotFound;
    }
    
    return result;
}

+ (BOOL) isValidNumber: (NSInteger) number {
    BOOL result = NO;
    
    if (number >= 0) {
        result = YES;
    }
    
    return result;
}
@end

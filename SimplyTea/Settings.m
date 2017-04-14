//
//  Settings.m
//  SimplyTea
//
//  Created by Ken Hung on 9/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"

// Dictionary identifiers in Settings.plist
#define PORTIONS_ID @"portions"
#define TEMPERATURE_ID @"temperature"
#define START_FAVORITES_ID @"start_favorites"

@implementation Settings
+ (void) forceDefaultSettings {
    // Set the application defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray * objects = [NSArray arrayWithObjects: [NSNumber numberWithInt: 2], [NSNumber numberWithInt: 1], @"NO", nil];
    NSArray * keys = [NSArray arrayWithObjects: PORTIONS_ID, TEMPERATURE_ID, START_FAVORITES_ID, nil];
    
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjects: objects forKeys: keys];
    
    [defaults registerDefaults:appDefaults];
    [defaults synchronize];
}

/**
 * 0 = Calcius
 * 1 = Fahrenheit
 */
+ (NSInteger) getTemperatureSetting {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults integerForKey: TEMPERATURE_ID];
}

/**
 * 0 = oz
 * 1 = tsp
 * 2 = tbsp
 */
+ (NSInteger) getPortionSetting {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults integerForKey: PORTIONS_ID];
}

+ (BOOL) shouldStartWithFavorites {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    return [defaults boolForKey: START_FAVORITES_ID];
}
@end

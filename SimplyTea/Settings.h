//
//  Settings.h
//  SimplyTea
//
//  Created by Ken Hung on 9/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject
+ (void) forceDefaultSettings;
+ (NSInteger) getTemperatureSetting;
+ (NSInteger) getPortionSetting;
+ (BOOL) shouldStartWithFavorites;
@end

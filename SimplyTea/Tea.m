//
//  Tea.m
//  SimplyTea
//
//  Created by Ken Hung on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tea.h"

@implementation Tea
@synthesize primaryTeaType, subType1, subType2, infusions, countryOfOrigin, mountain, antioxidantLevel, caffeineLevel, databaseID;
@synthesize brewTempLow, brewTempHigh, maxNumberOfInfusionsLow, maxNumberOfInfusionsHigh, lightToDarkScale, meters;
@synthesize portion, temperature, isFavorite, databaseType;

- (id) init  {
    if (self = [super init]) {
        self.infusions = [[NSMutableArray alloc] init];
        
        [self clearAllData];
    }
    
    return self;
}

- (void) clearAllData {
    [self.infusions removeAllObjects];
    self.databaseID = -1; // shouldn't be used as an ID in database
    self.primaryTeaType = @"";
    self.subType1 = @"";
    self.subType2 = @"";
    self.countryOfOrigin = @"";
    self.mountain = @"";
    self.antioxidantLevel = @"";
    self.caffeineLevel = @"";
    
    self.brewTempLow = 0;
    self.brewTempHigh = 0;
    self.maxNumberOfInfusionsLow = 0;
    self.maxNumberOfInfusionsHigh = 0;
    self.lightToDarkScale = 0;
    self.meters = 0;
    self.portion = 0;
    self.temperature = 0;
    
    self.isFavorite = NO;
    self.databaseType = DEFAULT_TEAS;
}

- (void) dealloc {
    [primaryTeaType release];
    [subType1 release];
    [subType2 release];
    [infusions release];
    [countryOfOrigin release];
    [mountain release];
    [antioxidantLevel release];
    [caffeineLevel release];
    
    [super dealloc];
}

- (NSString *) description {
    return [NSString stringWithFormat: @"Tea: %@, %@, %@, %@, %d, %d, %d, %d, %d, %@, %@, %d, %@, %@, %d %d %@", self.primaryTeaType, self.subType1, self.subType2, [self.infusions description], self.brewTempLow, self.brewTempHigh, self.maxNumberOfInfusionsLow, self.maxNumberOfInfusionsHigh, 
            self.lightToDarkScale, self.countryOfOrigin, self.mountain, self.meters, self.antioxidantLevel, self.caffeineLevel, self.portion, self.temperature, self.isFavorite ? @"YES" : @"NO"];
}
@end

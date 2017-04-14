//
//  Tea.h
//  SimplyTea
//
//  Created by Ken Hung on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TeaDatabaseHeader.h"

@interface Tea : NSObject

@property (nonatomic, assign) NSInteger databaseID;
@property (nonatomic, retain) NSString * primaryTeaType;
@property (nonatomic, retain) NSString * subType1, * subType2;
@property (nonatomic, retain) NSMutableArray * infusions;
@property (nonatomic, assign) NSInteger brewTempLow, brewTempHigh;
@property (nonatomic, assign) NSInteger maxNumberOfInfusionsLow, maxNumberOfInfusionsHigh;
@property (nonatomic, assign) NSInteger lightToDarkScale;
@property (nonatomic, retain) NSString * countryOfOrigin;
@property (nonatomic, retain) NSString * mountain;
@property (nonatomic, assign) NSInteger meters;
@property (nonatomic, retain) NSString * antioxidantLevel, * caffeineLevel;
@property (nonatomic, assign) NSInteger portion;
@property (nonatomic, assign) NSInteger temperature;
@property (nonatomic, assign) TeaDatabaseType databaseType;
@property (nonatomic, assign) BOOL isFavorite;

- (void) clearAllData;
@end

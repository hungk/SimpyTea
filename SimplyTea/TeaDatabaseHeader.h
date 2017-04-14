//
//  TeaDatabaseHeader.h
//  SimplyTea
//
//  Created by Ken Hung on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef SimplyTea_TeaDatabaseHeader_h
#define SimplyTea_TeaDatabaseHeader_h

typedef enum {
    DEFAULT_TEAS,
    USER_TEAS
} TeaDatabaseType;

#define NUM_INFUSIONS 10
// NOTE: Excluding the first ID attribute
#define ALL_ATTRIBUTES @"PrimaryTeaType, Subtype1, Subtype2, Infusion1, Infusion2, Infusion3, Infusion4, Infusion5, Infusion6, Infusion7, Infusion8, Infusion9, Infusion10, BrewTempLow, BrewTempHigh, MaxInfusionsLow, MaxInfusionsHigh, ScaleLightToDark, Country, Mountain, Meters, AntioxidentLevel, CaffeineLevel, Portion, Temperature, isFavorite"

#define CREATE_TABLE "CREATE TABLE IF NOT EXISTS Tea(ID INTEGER PRIMARY KEY AUTOINCREMENT, PrimaryTeaType TEXT, Subtype1 TEXT, Subtype2 TEXT, Infusion1 INTEGER, Infusion2 INTEGER, Infusion3 INTEGER, Infusion4 INTEGER, Infusion5 INTEGER, Infusion6 INTEGER, Infusion7 INTEGER, Infusion8 INTEGER, Infusion9 INTEGER, Infusion10 INTEGER, BrewTempLow INTEGER, BrewTempHigh INTEGER, MaxInfusionsLow INTEGER, MaxInfusionsHigh INTEGER, ScaleLightToDark INTEGER, Country TEXT, Mountain TEXT, Meters INTEGER, AntioxidentLevel TEXT, CaffeineLevel TEXT, Portion INTEGER, Temperature INTEGER, isFavorite INTEGER)"
#endif

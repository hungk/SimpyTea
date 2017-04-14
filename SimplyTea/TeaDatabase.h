//
//  TeaDatabase.h
//  SimplyTea
//
//  Created by Ken Hung on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Tea.h"
#import "TeaDatabaseHeader.h"

@interface TeaDatabase : NSObject {
    sqlite3 * teaDatabase;
}

// Singleton
+ (TeaDatabase *) sharedTeaDatabase;

- (NSString *) getDatabaseFilePathOfType: (TeaDatabaseType) databaseType;
- (void) setupDatabase: (TeaDatabaseType) databaseType;
- (void) retrieveDataFromCSV: (NSString *) csvFilename;
- (void) insertTeaIntoDatabase: (Tea *) tea InDatabase: (TeaDatabaseType) databaseType;
- (void) showDatabaseFromDatabase: (TeaDatabaseType) databaseType;

- (NSMutableArray *) getEntriesWithTeaType: (NSString *) typeName inDatabase: (TeaDatabaseType) databaseType;
- (NSMutableArray *) getFavoritesInDatabase: (TeaDatabaseType) databaseType;
- (NSInteger) getNumberOfEntriesInDatabase: (TeaDatabaseType) databaseType;
- (NSMutableArray *) getAllPrimaryTeaTypesFromDatabase: (TeaDatabaseType) databaseType;
- (BOOL) checkIfExistsInDatabase: (TeaDatabaseType) databaseType tea: (Tea *) tea;

- (void) updateTableEntryID: (NSInteger) entryID withFavorite: (BOOL) isFavorite inDatabase: (TeaDatabaseType) databaseType;
- (void) clearTeaTableInDatabase: (TeaDatabaseType) databaseType;
@end

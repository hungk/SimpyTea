//
//  TeaDatabase.m
//  SimplyTea
//
//  Created by Ken Hung on 7/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// TODO: Don't use auto incrementor as the primary key, because deleting entries does not cause the auto incrementor to reset or use the 
// lowest inused value. May runout of numbers (overflow).

#import "TeaDatabase.h"
#import "Infusion.h"
#import "CHCSVParserWrapper.h"

@interface TeaDatabase () 
    - (void) fillTea: (Tea *) tea withDataFromStatement: (sqlite3_stmt *) statement ofType: (TeaDatabaseType) databaseType;
@end

@implementation TeaDatabase

#pragma mark - Singleton Methods
+ (TeaDatabase *) sharedTeaDatabase {
    //  Static local predicate must be initialized to 0
    static TeaDatabase * sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TeaDatabase alloc] init];
        // Do any other initialisation stuff here
    });
    
    return sharedInstance;
}

- (id) init {
    if (self = [super init]) {
        [self setupDatabase: DEFAULT_TEAS];
        [self setupDatabase: USER_TEAS];
        
        // Add entries to database only once
        if ([self getNumberOfEntriesInDatabase: DEFAULT_TEAS] <= 0) {
            [self retrieveDataFromCSV: @"Tea DB Hierarchy - TDB"];
        }
    }
    
    return self;
}

- (void) dealloc {
    abort();
    
    [super dealloc];
}

- (NSString *) getDatabaseFilePathOfType: (TeaDatabaseType) databaseType {
    NSString * documentsDirectory;
    NSArray * directoryPaths;
    
    // Get documents directory
    directoryPaths  = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [directoryPaths objectAtIndex: 0];
    
    // Build path to database file
    if (databaseType == DEFAULT_TEAS) {
        return [NSString stringWithString: [documentsDirectory stringByAppendingPathComponent: @"tea.db"]];
    } else if (databaseType == USER_TEAS) {
        return [NSString stringWithString: [documentsDirectory stringByAppendingPathComponent: @"user_tea.db"]];
    } else {
        return [NSString stringWithString: [documentsDirectory stringByAppendingPathComponent: @"tea.db"]];   
    }
}

- (void) setupDatabase: (TeaDatabaseType) databaseType {
    NSString * databasePath;
    
    // Build path to database file
    databasePath = [self getDatabaseFilePathOfType:databaseType];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSLog(@"Database Path: %@", databasePath);
    
    // The sqlite3_open command created the database File????
    if (![fileManager fileExistsAtPath: databasePath]) {
        const char * cStringDatabasePath = [databasePath UTF8String];
        
        if (sqlite3_open(cStringDatabasePath, &teaDatabase) == SQLITE_OK) {
            char * errorMessage;
            // Carefull that this is hardcoded table
            const char * sql_statement = CREATE_TABLE;
            
            if (sqlite3_exec(teaDatabase, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                // TABLE CREATION ERROR
                NSLog(@"Failed to create table: %@\n%s", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)], sql_statement);
            } else {
                NSLog(@"Table successfully created");
            }
            
            sqlite3_close(teaDatabase);
        } else {
            // OPEN/CREATE ERROR
            NSLog(@"Failed to open/create database: %@", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)]);
        }
    } else {
        NSLog(@"Database file already exists");
    //    [self showDatabase];
    }
    
    [fileManager release];
}

- (void) retrieveDataFromCSV: (NSString *) csvFilename {
    NSString * csvFilePath = [[NSBundle mainBundle] pathForResource: csvFilename ofType: @"csv"];

    // Returns a 2D array matching csv data grid (all as NSString)
   // [parser setDelimiter: ','];
   // NSMutableArray * csvContent = [parser parseFile];
    CHCSVParserWrapper * parser = [[[CHCSVParserWrapper alloc] init] autorelease];
    NSArray *csvContent = [parser parseArrayOfArraysFromCSVFile: csvFilePath];
    
    Tea * tea = [[Tea alloc] init];
    
    for (int i = 1; i < [csvContent count]; i++) {
        int j = 0;
        NSLog(@"content of line %d: %@", i, [csvContent objectAtIndex: i]);
        
        [tea clearAllData];
        
        tea.primaryTeaType = [[csvContent objectAtIndex: i] objectAtIndex: j++];
        tea.subType1 = [[csvContent objectAtIndex: i] objectAtIndex: j++];
        tea.subType2 = [[csvContent objectAtIndex: i] objectAtIndex: j++];
        
        // Infusions
        int infNum = 1;
        
        // 10 infusions currently
        int infusionCount = j + NUM_INFUSIONS;
        
        for (; j < infusionCount; j++) {
            Infusion * infusion = [[Infusion alloc] initWithInfusionNumber: infNum++ secondsToInfuse: [[[csvContent objectAtIndex: i] objectAtIndex: j] integerValue]];
            [tea.infusions addObject: infusion];
        }
        
        tea.brewTempLow = [[[csvContent objectAtIndex: i] objectAtIndex: j++] integerValue];
        tea.brewTempHigh = [[[csvContent objectAtIndex: i] objectAtIndex: j++] integerValue];
        tea.maxNumberOfInfusionsLow = [[[csvContent objectAtIndex: i] objectAtIndex: j++] integerValue];
        tea.maxNumberOfInfusionsHigh = [[[csvContent objectAtIndex: i] objectAtIndex: j++] integerValue];
        tea.lightToDarkScale = [[[csvContent objectAtIndex: i] objectAtIndex: j++] integerValue];
        tea.countryOfOrigin = [[csvContent objectAtIndex: i] objectAtIndex: j++];
        tea.mountain = [[csvContent objectAtIndex: i] objectAtIndex: j++];
        tea.meters = [[[csvContent objectAtIndex: i] objectAtIndex: j++] integerValue];
        tea.antioxidantLevel = [[csvContent objectAtIndex: i] objectAtIndex: j++];
        tea.caffeineLevel = [[csvContent objectAtIndex: i] objectAtIndex: j++];
        tea.portion = [[[csvContent objectAtIndex: i] objectAtIndex: j++] integerValue];
        tea.temperature = [[[csvContent objectAtIndex: i] objectAtIndex: j++] integerValue];
        // isFavorites is not in teh CSV file
        
        [self insertTeaIntoDatabase: tea InDatabase: DEFAULT_TEAS];
    }
    
    [tea release];
}

- (void) fillTea: (Tea *) tea withDataFromStatement: (sqlite3_stmt *) statement ofType: (TeaDatabaseType) databaseType {
    int j = 0;
    
    tea.databaseID = sqlite3_column_int(statement, j++);
    tea.primaryTeaType = [NSString stringWithUTF8String: (const char*) sqlite3_column_text(statement, j++)];
    tea.subType1 = [NSString stringWithUTF8String: (const char*) sqlite3_column_text(statement, j++)];
    tea.subType2 = [NSString stringWithUTF8String: (const char*) sqlite3_column_text(statement, j++)];
    
    int infCount = 1;
    Infusion * infusion;
    
    // 10 infusions currently
    int infusionCount = j + NUM_INFUSIONS;
    
    for (; j < infusionCount; j++) {
        // ignore 0/empty/null infusion time entries
        if (sqlite3_column_int(statement, j) > 0) {
            infusion = [[Infusion alloc] initWithInfusionNumber: infCount++ secondsToInfuse: sqlite3_column_int(statement, j)];
            [tea.infusions addObject: infusion];
            [infusion release];
        }
    }
    
    tea.brewTempLow = sqlite3_column_int(statement, j++);
    tea.brewTempHigh = sqlite3_column_int(statement, j++);
    tea.maxNumberOfInfusionsLow = sqlite3_column_int(statement, j++);
    tea.maxNumberOfInfusionsHigh = sqlite3_column_int(statement, j++);
    tea.lightToDarkScale = sqlite3_column_int(statement, j++);
    tea.countryOfOrigin = [NSString stringWithUTF8String: (const char*) sqlite3_column_text(statement, j++)];
    tea.mountain = [NSString stringWithUTF8String: (const char*) sqlite3_column_text(statement, j++)];
    tea.meters = sqlite3_column_int(statement, j++);
    tea.antioxidantLevel = [NSString stringWithUTF8String: (const char*) sqlite3_column_text(statement, j++)];
    tea.caffeineLevel = [NSString stringWithUTF8String: (const char*) sqlite3_column_text(statement, j++)];
    tea.portion = sqlite3_column_int(statement, j++);
    tea.temperature = sqlite3_column_int(statement, j++);
    tea.isFavorite = sqlite3_column_int(statement, j++) == 1 ? YES : NO;
    tea.databaseType = databaseType;
}

- (void) insertTeaIntoDatabase: (Tea *) tea InDatabase: (TeaDatabaseType) databaseType {
    sqlite3_stmt * statement;
    
    const char * cStringDatabasePath = [[self getDatabaseFilePathOfType: databaseType] UTF8String];
    
    if (sqlite3_open(cStringDatabasePath, &teaDatabase) == SQLITE_OK) {
        // Careful that this is hardcoded table
        NSString * insertSQL = [NSString stringWithFormat: @"INSERT INTO Tea(%@) VALUES (\"%@\", \"%@\", \"%@\", ", 
                                ALL_ATTRIBUTES,
                                tea.primaryTeaType, 
                                tea.subType1, 
                                tea.subType2];
        
        for (int i = 0; i < NUM_INFUSIONS; i++) {
            insertSQL = [NSString stringWithFormat: @"%@ %d, ", insertSQL, ((Infusion*)[tea.infusions objectAtIndex: i]).infusionSeconds];
        }

        insertSQL = [NSString stringWithFormat: @"%@ %d, %d, %d, %d, %d, \"%@\", \"%@\", %d, \"%@\", \"%@\", %d, %d, %d)",
                                insertSQL,
                                tea.brewTempLow, 
                                tea.brewTempHigh, 
                                tea.maxNumberOfInfusionsLow, 
                                tea.maxNumberOfInfusionsHigh, 
                                tea.lightToDarkScale, 
                                tea.countryOfOrigin, 
                                tea.mountain, 
                                tea.meters, 
                                tea.antioxidantLevel, 
                                tea.caffeineLevel, 
                                tea.portion, 
                                tea.temperature, 
                                tea.isFavorite ? 1 : 0];
        
        const char * insert_statement = [insertSQL UTF8String];
        
        sqlite3_prepare_v2(teaDatabase, insert_statement, -1, &statement, NULL);
        
        if (sqlite3_step(statement) == SQLITE_DONE) {
            // SUCCESS
            NSLog(@"INSERT successful");
        } else {
            NSLog(@"Failed to execute INSERT statement: %@\n%@", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)], insertSQL);
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(teaDatabase);
    } else {
        // OPEN/CREATE ERROR
        NSLog(@"Failed to open/create database: %@", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)]);
    }
}

- (void) showDatabaseFromDatabase: (TeaDatabaseType) databaseType {
    const char * cStringDatabasePath = [[self getDatabaseFilePathOfType: databaseType] UTF8String];
    sqlite3_stmt * statement;
    
    if (sqlite3_open(cStringDatabasePath, &teaDatabase) == SQLITE_OK) {
        NSString * querySQL = [NSString stringWithFormat: @"SELECT ID, %@ FROM Tea", ALL_ATTRIBUTES];
        
        const char * query_statement = [querySQL UTF8String];
        
        Tea * tea = [[Tea alloc] init];
        
        if (sqlite3_prepare_v2(teaDatabase, query_statement, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                [tea clearAllData];
                
                [self fillTea: tea withDataFromStatement: statement ofType: databaseType];
                
                NSLog(@"%@", [tea description]);
            }
            
            sqlite3_finalize(statement);
        } else {
            NSLog(@"Failed to SELECT from table: %@\n %s", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)], query_statement);
        }
        
        [tea release];
        
        sqlite3_close(teaDatabase);
    } else {
        // OPEN/CREATE ERROR
        NSLog(@"Failed to open/create database: %@", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)]);
    }
}

// Returns a list of Tez objects
- (NSMutableArray *) getEntriesWithTeaType: (NSString *) typeName inDatabase: (TeaDatabaseType) databaseType {
    NSMutableArray * results = [[NSMutableArray alloc] init];
    
    const char * cStringDatabasePath = [[self getDatabaseFilePathOfType: databaseType] UTF8String];
    sqlite3_stmt * statement;
    
    if (sqlite3_open(cStringDatabasePath, &teaDatabase) == SQLITE_OK) {
        NSString * querySQL = [NSString stringWithFormat: @"SELECT ID, %@ FROM Tea WHERE primaryTeaType == \"%@\"", ALL_ATTRIBUTES, typeName];
        
        const char * query_statement = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(teaDatabase, query_statement, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                Tea * tea = [[Tea alloc] init];
                
                [self fillTea: tea withDataFromStatement: statement ofType: databaseType];
                
                NSLog(@"%@", [tea description]);
                
                [results addObject: tea];
                [tea release];
            }
            
            sqlite3_finalize(statement);
        } else {
            NSLog(@"Failed to SELECT from table: %@\n %s", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)], query_statement);
        }
        
        sqlite3_close(teaDatabase);
    } else {
        // OPEN/CREATE ERROR
        NSLog(@"Failed to open/create database: %@", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)]);
    }
    
    return [results autorelease];
}

- (NSMutableArray *) getFavoritesInDatabase: (TeaDatabaseType) databaseType {
    NSMutableArray * results = [[NSMutableArray alloc] init];
    
    const char * cStringDatabasePath = [[self getDatabaseFilePathOfType: databaseType] UTF8String];
    sqlite3_stmt * statement;
    
    if (sqlite3_open(cStringDatabasePath, &teaDatabase) == SQLITE_OK) {
        NSString * querySQL = [NSString stringWithFormat: @"SELECT ID, %@ FROM Tea WHERE isFavorite = 1", ALL_ATTRIBUTES];
        
        const char * query_statement = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(teaDatabase, query_statement, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                Tea * tea = [[Tea alloc] init];
                
                [self fillTea: tea withDataFromStatement: statement ofType: databaseType];
                
                NSLog(@"%@", [tea description]);
                
                [results addObject: tea];
                [tea release];
            }
            
            sqlite3_finalize(statement);
        } else {
            NSLog(@"Failed to SELECT from table: %@\n %s", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)], query_statement);
        }
        
        sqlite3_close(teaDatabase);
    } else {
        // OPEN/CREATE ERROR
        NSLog(@"Failed to open/create database: %@", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)]);
    }
    
    return [results autorelease];
}

- (NSInteger) getNumberOfEntriesInDatabase: (TeaDatabaseType) databaseType {
    NSInteger result = 0;
    
    const char * cStringDatabasePath = [[self getDatabaseFilePathOfType:databaseType] UTF8String];
    sqlite3_stmt * statement;
    
    if (sqlite3_open(cStringDatabasePath, &teaDatabase) == SQLITE_OK) {
        NSString * querySQL = [NSString stringWithFormat: @"SELECT COUNT(ID) FROM Tea"];
        
        const char * query_statement = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(teaDatabase, query_statement, -1, &statement, NULL) == SQLITE_OK) {
            // Should only be one but ... just incase, get the last result
            while (sqlite3_step(statement) == SQLITE_ROW) {
                result = sqlite3_column_int(statement, 0);
            }
            
            sqlite3_finalize(statement);
        } else {
            NSLog(@"Failed to SELECT from table: %@\n %s", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)], query_statement);
        }
        
        sqlite3_close(teaDatabase);
    } else {
        // OPEN/CREATE ERROR
        NSLog(@"Failed to open/create database: %@", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)]);
    }
    
    return result;
}

- (NSMutableArray *) getAllPrimaryTeaTypesFromDatabase: (TeaDatabaseType) databaseType {
    NSMutableArray * results = [[NSMutableArray alloc] init];
    
    const char * cStringDatabasePath = [[self getDatabaseFilePathOfType: databaseType] UTF8String];
    sqlite3_stmt * statement;
    
    if (sqlite3_open(cStringDatabasePath, &teaDatabase) == SQLITE_OK) {
        NSString * querySQL = [NSString stringWithFormat: @"SELECT DISTINCT PrimaryTeaType FROM Tea"];
        
        const char * query_statement = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(teaDatabase, query_statement, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {                
                [results addObject: [NSString stringWithUTF8String: (const char*) sqlite3_column_text(statement, 0)]];
            }
            
            sqlite3_finalize(statement);
        } else {
            NSLog(@"Failed to SELECT from table: %@\n %s", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)], query_statement);
        }
        
        sqlite3_close(teaDatabase);
    } else {
        // OPEN/CREATE ERROR
        NSLog(@"Failed to open/create database: %@", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)]);
    }
    
    return [results autorelease];
}

- (BOOL) checkIfExistsInDatabase: (TeaDatabaseType) databaseType tea: (Tea *) tea {
    BOOL result = NO;
    
    const char * cStringDatabasePath = [[self getDatabaseFilePathOfType:databaseType] UTF8String];
    sqlite3_stmt * statement;
    
    if (sqlite3_open(cStringDatabasePath, &teaDatabase) == SQLITE_OK) {
        // NOTE on stringWithFormat: Does not resolve parameters inside of parameters
        NSString * querySQL = [NSString stringWithFormat: @"SELECT ID, %@ FROM Tea WHERE PrimaryTeaType = \"%@\" AND Subtype1 = \"%@\" AND Subtype2 = \"%@\" AND BrewTempLow = %d AND BrewTempHigh = %d AND MaxInfusionsLow = %d AND MaxInfusionsHigh = %d AND ScaleLightToDark = %d AND Country = \"%@\" AND Mountain = \"%@\" AND Meters = %d AND AntioxidentLevel = \"%@\" AND CaffeineLevel = \"%@\" AND Portion = %d AND Temperature = %d", ALL_ATTRIBUTES,
                               tea.primaryTeaType,
                               tea.subType1, 
                               tea.subType2,
                               tea.brewTempLow,
                               tea.brewTempHigh,
                               tea.maxNumberOfInfusionsLow,
                               tea.maxNumberOfInfusionsHigh,
                               tea.lightToDarkScale,
                               tea.countryOfOrigin,
                               tea.mountain,
                               tea.meters,
                               tea.antioxidantLevel,
                               tea.caffeineLevel,
                               tea.portion,
                               tea.temperature];
        
        const char * query_statement = [querySQL UTF8String];
        
        if (sqlite3_prepare_v2(teaDatabase, query_statement, -1, &statement, NULL) == SQLITE_OK) {
            if (sqlite3_step(statement) == SQLITE_ROW) {
                result = YES;
            }
            
            sqlite3_finalize(statement);
        } else {
            NSLog(@"Failed to SELECT from table: %@\n %s", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)], query_statement);
        }
        
        sqlite3_close(teaDatabase);
    } else {
        // OPEN/CREATE ERROR
        NSLog(@"Failed to open/create database: %@", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)]);
    }
    
    return result;
}

- (void) updateTableEntryID: (NSInteger) entryID withFavorite: (BOOL) isFavorite inDatabase: (TeaDatabaseType) databaseType {
    NSString * databasePath;
    
    // Build path to database file
    databasePath = [self getDatabaseFilePathOfType: databaseType];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSLog(@"Database Path: %@", databasePath);
    
    if ([fileManager fileExistsAtPath: databasePath]) {
        const char * cStringDatabasePath = [databasePath UTF8String];
        
        if (sqlite3_open(cStringDatabasePath, &teaDatabase) == SQLITE_OK) {
            char * errorMessage;
            // Carefull that this is hardcoded table
            const char * sql_statement = [[NSString stringWithFormat: @"UPDATE Tea SET isFavorite = %d WHERE ID = %d", isFavorite ? 1 : 0, entryID] UTF8String];
            
            if (sqlite3_exec(teaDatabase, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                // TABLE CREATION ERROR
                NSLog(@"Failed to update table: %@\n %s", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)], sql_statement);
            } else {
                NSLog(@"Table successfully update");
            }
            
            sqlite3_close(teaDatabase);
        } else {
            // OPEN/CREATE ERROR
            NSLog(@"Failed to open/create database, %@", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)]);
        }
    } else {
        NSLog(@"Database file does not exist");
    }
}

- (void) clearTeaTableInDatabase: (TeaDatabaseType) databaseType {
    NSString * databasePath;
    
    // Build path to database file
    databasePath = [self getDatabaseFilePathOfType: databaseType];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSLog(@"Database Path: %@", databasePath);
    
    if ([fileManager fileExistsAtPath: databasePath]) {
        const char * cStringDatabasePath = [databasePath UTF8String];
        
        if (sqlite3_open(cStringDatabasePath, &teaDatabase) == SQLITE_OK) {
            char * errorMessage;
            // Carefull that this is hardcoded table
            const char * sql_statement = "DROP TABLE IF EXISTS Tea";
            
            if (sqlite3_exec(teaDatabase, sql_statement, NULL, NULL, &errorMessage) != SQLITE_OK) {
                // TABLE CREATION ERROR
                NSLog(@"Failed to drop table: %@\n%s", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)], sql_statement);
            } else {
                NSLog(@"Table successfully dropped");
            }
            
            sqlite3_close(teaDatabase);
        } else {
            // OPEN/CREATE ERROR
            NSLog(@"Failed to open/create database, %@", [NSString stringWithUTF8String:sqlite3_errmsg(teaDatabase)]);
        }
    } else {
        NSLog(@"Database file does not exist");
    }
    
    [fileManager release];
}
@end

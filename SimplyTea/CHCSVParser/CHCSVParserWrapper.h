//
//  CHCSVParserWrapper.h
//  SimplyTea
//
//  Created by Ken Hung on 8/14/13.
//
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"

@interface CHCSVParserWrapper : NSObject <CHCSVParserDelegate> {
    // An array of entries (lines) each with an array of tokens (comma separated values).
    NSMutableArray * entriesArray;
    NSMutableArray * tokenArray;
}

- (NSArray *) parseArrayOfArraysFromCSVFile: (NSString *) filePath;
@end

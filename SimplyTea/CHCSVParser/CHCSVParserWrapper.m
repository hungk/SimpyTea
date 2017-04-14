//
//  CHCSVParserWrapper.m
//  SimplyTea
//
//  Created by Ken Hung on 8/14/13.
//
//

#import "CHCSVParserWrapper.h"

@implementation CHCSVParserWrapper
- (void) dealloc {
    if (self->entriesArray)
        [self->entriesArray release];
    
    self->entriesArray = nil;
    
    if (self->tokenArray)
        [self->tokenArray release];
    
    self->tokenArray = nil;
    
    [super dealloc];
}

- (NSArray *) parseArrayOfArraysFromCSVFile: (NSString *) filePath {
    NSArray * result = nil;
    
    CHCSVParser * parser = [[[CHCSVParser alloc] initWithContentsOfCSVFile: filePath] autorelease];
    parser.delegate = self;
    [parser parse];
    
    if (self->entriesArray) {
        result = [[[NSArray alloc] initWithArray: self->entriesArray] autorelease];
    }
    
    if (self->entriesArray)
        [self->entriesArray release];
    
    self->entriesArray = nil;
    
    return result;
}

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    self->entriesArray = [[NSMutableArray alloc] init];
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    if (self->tokenArray)
        [self->tokenArray release];
    
    self->tokenArray = nil;
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    if (self->tokenArray)
        [self->tokenArray release];
    
    self->tokenArray = [[NSMutableArray alloc] init];
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    if (self->tokenArray) {
        [self->entriesArray addObject: self->tokenArray];
        [self->tokenArray release];
    }
    
    self->tokenArray = nil;
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    if (self->tokenArray)
        [self->tokenArray addObject: field];
}

- (void)parser:(CHCSVParser *)parser didReadComment:(NSString *)comment {
    
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    
}
@end

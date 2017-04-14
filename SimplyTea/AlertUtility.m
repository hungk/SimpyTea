//
//  AlertUtility.m
//  SimplyTea
//
//  Created by Ken Hung on 9/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlertUtility.h"

@implementation AlertUtility
@synthesize alertView;

- (id) init {
    if (self = [super init]) {
        self.alertView = [[UIAlertView alloc] initWithTitle: nil message: nil delegate: self cancelButtonTitle: @"OK" otherButtonTitles:nil, nil];
    }
    
    return self;
}

- (void) showAlertWithTitle: (NSString *) title andMessage: (NSString *) message {
    self.alertView.title = title;
    self.alertView.message = message;
    
    [self.alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    
}

- (void) dealloc {
    [alertView release];
    [super dealloc];
}
@end

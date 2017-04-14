//
//  AlertUtility.h
//  SimplyTea
//
//  Created by Ken Hung on 9/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertUtility : NSObject <UIAlertViewDelegate> {
    
}

@property (nonatomic, retain) UIAlertView * alertView;

- (void) showAlertWithTitle: (NSString *) title andMessage: (NSString *) message;
@end

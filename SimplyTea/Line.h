//
//  Line.h
//  SimplyTea
//
//  Created by Ken Hung on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Line : NSObject

@property (nonatomic, assign) CGPoint startPoint, endPoint;

- (id) initWithStartPoint: (CGPoint) start endPoint: (CGPoint) end;
@end

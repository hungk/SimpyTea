//
//  TeaDetailsViewController.h
//  SimplyTea
//
//  Created by Ken Hung on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tea.h"
@interface TeaDetailsViewController : UIViewController
@property (nonatomic, retain) Tea * teaRef;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil tea: (Tea *) tea;
@end

//
//  AddTeaGraphViewController.h
//  SimplyTea
//
//  Created by Ken Hung on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tea.h"
#import "GraphScrollView.h"

@class AddTeaInfusionTableView;

@interface AddTeaGraphViewController : UIViewController <InfusionChangedNotificationProtocol, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate> {
    BOOL isTeaInfusionTableExpandedView;
}

@property (nonatomic, retain) Tea * currentTea;
@property (nonatomic, assign) id<InfusionChangedNotificationProtocol> target;
@property (nonatomic, retain) IBOutlet UIScrollView * graphTableScrollView;
@property (nonatomic, retain) IBOutlet GraphScrollView * graphScrollView;
@property (nonatomic, retain) AddTeaInfusionTableView * addTeaInfusionTableView;
@property (nonatomic, retain) NSMutableArray * pickerDataList;
@property (nonatomic, retain) NSMutableArray * textFieldList,  * cellTextList;
@property (nonatomic, retain) UITapGestureRecognizer * tapGesture;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTea: (Tea*) teaObject notificationTarget: (id<InfusionChangedNotificationProtocol>) notifyTarget;
@end

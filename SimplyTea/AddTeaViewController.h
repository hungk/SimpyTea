//
//  AddTeaViewController.h
//  SimplyTea
//
//  Created by Ken Hung on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/**
 Last Steep TO DO
 
 - Fix Timer index on orientation change
 - Fix Timer View bi directional scrolling. (index ceiling)
 - Find way to show time on each infusion in graph in portrait.
 - Add ability to add custom teas.
 - Decide what to do if adding a duplicate tea entry with different infusion times. Update? or only allow updating from main menu -> graph.
 - create two database table in the same .db file and not in two separate files (unless future-proofing against data loss??)
 - Add ability to add infusions to existing tea and update it's properties
 - Add ability to delete teas
 - Add Scrolling graph time numbers (y axis numbers)
 - Graph infusion limits and error checking.
 - Save Graph infusion changes.
 - Add search bar when pull down.
 - Input default values for empty strings, when validating with empty strings, no show alert.
 */
#import <UIKit/UIKit.h>
#import "GraphScrollView.h"

@interface AddTeaViewController : UITableViewController <UITextFieldDelegate, InfusionChangedNotificationProtocol, UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, retain) NSMutableArray * textFieldList,  * cellTextList;
@property (nonatomic, retain) UITapGestureRecognizer * tapGesture;
@property (nonatomic, retain) Tea * tea;
@property (nonatomic, retain) UIBarButtonItem *saveBarButton;
@property (nonatomic, retain) NSMutableArray * pickerDataList;
@end

//
//  AddTeaGraphViewController.m
//  SimplyTea
//
//  Created by Ken Hung on 9/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddTeaGraphViewController.h"
#import "AddTeaInfusionTableView.h"
#import "Infusion.h"
#import "AddTeaDefaults.h"
#import "iOSVersionCheckUtility.h"

#define ADD_TEA_INFUSION_TABLE_CELL_SPACING 1

@interface AddTeaGraphViewController (Private)
    - (void) updateInfusionsTableView;
    - (void) updateGraphTableScrollView;
@end

@implementation AddTeaGraphViewController
@synthesize currentTea = currentTea_, target = target_, graphScrollView = graphScrollView_, addTeaInfusionTableView = addTeaInfusionTableView_, graphTableScrollView = graphTableScrollView_, pickerDataList = pickerDataList_, textFieldList = textFieldList_, cellTextList = cellTextList_, tapGesture = tapGesture_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andTea: (Tea*) teaObject notificationTarget: (id<InfusionChangedNotificationProtocol>) notifyTarget
{
    self = [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.currentTea = teaObject;
        self.target = notifyTarget;
        self.pickerDataList = [[[NSMutableArray alloc] init] autorelease];
        self.textFieldList = [[[NSMutableArray alloc] init] autorelease];
        self.cellTextList = [[[NSMutableArray alloc] init] autorelease];
        
        NSMutableArray * minutesList = [[[NSMutableArray alloc] init] autorelease];
        NSMutableArray * secondsList = [[[NSMutableArray alloc] init] autorelease];
         
        for (int i = 0; i < ADD_TEA_PICKER_MINUTES_LIMIT; i++) {
            [minutesList addObject: [@(i) stringValue]];
        }
         
        for (int i = 0; i < ADD_TEA_PICKER_SECONDS_LIMIT; i++) {
            [secondsList addObject: [@(i) stringValue]];
        }
         
        [self.pickerDataList addObject: minutesList];
        [self.pickerDataList addObject: secondsList];
        
        Infusion * infusion;
        
        for (int i = 0; i < [self.currentTea.infusions count]; i++) {
            infusion = [self.currentTea.infusions objectAtIndex: i];
            
            // Cell Titles
            [self.cellTextList addObject: [@(infusion.infusionNumber) stringValue]];
            
            // Cell TextFields
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 22)];
            textField.adjustsFontSizeToFitWidth = YES;
            textField.textColor = [UIColor blackColor];
            
            textField.text = [NSString stringWithFormat:@"%d:%.2d", infusion.infusionSeconds / 60, infusion.infusionSeconds % 60];
            
            textField.keyboardType = UIKeyboardTypeDefault;
            
            // Make last return key Done
            if (i + 1 == [self.cellTextList count]) {
                textField.returnKeyType = UIReturnKeyDone;
            } else {
                textField.returnKeyType = UIReturnKeyNext;
            }
            // textField.secureTextEntry = YES;
            
            textField.backgroundColor = [UIColor clearColor];
            textField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
            textField.textAlignment = UITextAlignmentLeft;
            textField.tag = i;
            textField.delegate = self;
            
            UIPickerView * pickerView = [[[UIPickerView alloc] initWithFrame: self.view.frame] autorelease];
            pickerView.delegate = self;
            pickerView.dataSource = self;
            pickerView.showsSelectionIndicator = YES;
            pickerView.tag = i; // NOTE: this has the same tag as the textField
            
            textField.inputView = pickerView;
            
            textField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
            [textField setEnabled: YES];
            
            [self.textFieldList addObject: textField];
            
            [textField release];
        }
        
        self->isTeaInfusionTableExpandedView = NO;
    }
    return self;
}

- (void) dealloc {
    [graphTableScrollView_ removeGestureRecognizer: tapGesture_];
    [currentTea_ release];
    [graphScrollView_ release];
    [addTeaInfusionTableView_ release];
    [graphTableScrollView_ release];
    [textFieldList_ release];
    [cellTextList_ release];
    [tapGesture_ release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self.graphScrollView initializeGraphViewWithTea: self.currentTea notificationTarget: self];
    
    // Ensure the table's fram does NOT extend past what is visible. The table's scroll view may not scroll.
    self.addTeaInfusionTableView = [[[AddTeaInfusionTableView alloc] initWithFrame: CGRectMake(self.graphScrollView.frame.origin.x,
                                                                                                self.graphScrollView.frame.size.height,
                                                                                                self.graphScrollView.frame.size.width,
                                                                                                self.graphTableScrollView.frame.size.height - self.graphScrollView.frame.size.height) style:UITableViewStyleGrouped] autorelease];    
    self.addTeaInfusionTableView.delegate = self;
    self.addTeaInfusionTableView.dataSource = self;
    
    [self.graphTableScrollView addSubview: self.addTeaInfusionTableView];

    self.tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleGesture:)] autorelease];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.numberOfTouchesRequired = 1;
    self.tapGesture.cancelsTouchesInView = NO;
    
    [self.graphTableScrollView addGestureRecognizer: self.tapGesture];
    
    NSLog(@"AddTesInfusionTableView: %f %f %f %f", self.addTeaInfusionTableView.frame.origin.x,
          self.addTeaInfusionTableView.frame.origin.y,
          self.addTeaInfusionTableView.frame.size.width,
          self.addTeaInfusionTableView.frame.size.height);
    
    NSLog(@"GraphTableScrollView: %f %f %f %f", self.graphTableScrollView.frame.origin.x,
          self.graphTableScrollView.frame.origin.y,
          self.graphTableScrollView.frame.size.width,
          self.graphTableScrollView.frame.size.height);
    
    NSLog(@"GraphScrollView: %f %f %f %f", self.graphScrollView.frame.origin.x,
          self.graphScrollView.frame.origin.y,
          self.graphScrollView.frame.size.width,
          self.graphScrollView.frame.size.height);
    
    NSLog(@"graphTableScrollView : %f %f %f %f", self.graphTableScrollView.frame.origin.x,
          self.graphTableScrollView .frame.origin.y,
          self.graphTableScrollView .frame.size.width,
          self.graphTableScrollView .frame.size.height);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [self.graphTableScrollView removeGestureRecognizer: self.tapGesture];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // Change the parent scroll view frame to fit the frame of the graphScrollView
    [self updateGraphTableScrollView];
    // Resize graph and graph scroll views
    [self.graphScrollView didRotateFromInterfaceOrientation: fromInterfaceOrientation];
    // Refresh Everything (Complete redraw)
    [self.graphScrollView updateGraph];
    
    [self updateGraphTableScrollView];
    
    CGRect frame = self.graphTableScrollView.frame;
    CGRect bounds = self.graphTableScrollView.bounds;
    CGSize size = self.graphTableScrollView.contentSize;
    
    NSLog(@"F %f %f %f %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    NSLog(@"B %f %f %f %f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    NSLog(@"C: %f %f", size.width, size.height);
}

- (void) updateGraphTableScrollView {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    
    NSInteger toolbarHeight = 0;
    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        toolbarHeight = 64;
    else
        toolbarHeight = 52;
    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        // Portrait
        self.graphTableScrollView.frame = CGRectMake(0, 0, screenSize.size.width, screenSize.size.height);
    } else {
        // Landscape
        self.graphTableScrollView.frame = CGRectMake(0, 0, screenSize.size.height, screenSize.size.width - toolbarHeight);
    }
}

- (void) updateInfusionsTableView {
    // Update the infusion table relative to GraphScrollView and the parent GraphTableScrollView
    self.addTeaInfusionTableView.frame = CGRectMake(self.graphScrollView.frame.origin.x,
                                                    self.graphScrollView.frame.size.height,
                                                    self.graphScrollView.frame.size.width,
                                                    self.graphTableScrollView.frame.size.height - self.graphScrollView.frame.size.height);
}

- (void) handleGesture: (id) sender {
    for (UITextField * textField in self.textFieldList) {
        [textField resignFirstResponder];
    }
    
    if (self->isTeaInfusionTableExpandedView) {
        [UIView animateWithDuration: 0.4f
                              delay: 0.0f
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self updateInfusionsTableView];
                         }
                         completion:^(BOOL finished) {
                             self->isTeaInfusionTableExpandedView = NO;
                         }];
    }
}

- (void) infusionChangeAtInfusion:(Infusion *)infusion timeChange:(BOOL)didTimeChange {
    if (self.target) {
        [self.target infusionChangeAtInfusion:infusion timeChange:didTimeChange];
    }
}

- (void) shouldDisableScrolling:(BOOL)disableScrolling {
    if (self.target) {
        [self.target shouldDisableScrolling:disableScrolling];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.currentTea.infusions count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

/*
 - (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
 return @"Test Footer";
 }
 */

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return ADD_TEA_INFUSION_TABLE_CELL_SPACING;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ADD_TEA_INFUSION_TABLE_CELL_SPACING;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.accessoryView = [self.textFieldList objectAtIndex: indexPath.section];
    cell.accessoryView.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [self.cellTextList objectAtIndex: indexPath.section];
    cell.textLabel.minimumFontSize = 8;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - UITextField Delegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    // Resign current textField as firstResponder
    [textField resignFirstResponder];
    
    // Make the next textField firstResponder
    if (textField.tag + 1 < [self.textFieldList count]) {
        [((UITextField *)[self.textFieldList objectAtIndex: textField.tag + 1]) becomeFirstResponder];
    }
    
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    // textField has 0 indexed tag

}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    if (!self->isTeaInfusionTableExpandedView) {
        // Set the frame height to be full height but partially out of sight.
        self.addTeaInfusionTableView.frame = CGRectMake(self.graphScrollView.frame.origin.x,
                                                        self.graphScrollView.frame.size.height,
                                                        self.graphTableScrollView.frame.size.width,
                                                        self.graphTableScrollView.frame.size.height);
        
        // Set content size with extra space hieristic
        NSInteger keyboardExtraSpace = 300;
        self.addTeaInfusionTableView.contentSize = CGSizeMake(self.graphTableScrollView.frame.size.width,
                                                              self.graphTableScrollView.frame.size.height + keyboardExtraSpace);
        
        // Set bounds (or where we want the view to be).
        CGRect bounds = self.addTeaInfusionTableView.bounds;
        //self.addTeaInfusionTableView.bounds;
        // TO DO: 40 is guestimated cell height
        self.addTeaInfusionTableView.bounds = CGRectMake(bounds.origin.x, textField.tag * 40, bounds.size.width, bounds.size.height);
        
        // Animate frame upward
        [UIView animateWithDuration: 0.4f
                              delay: 0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.addTeaInfusionTableView.frame = CGRectMake(0,
                                                                             0,
                                                                             self.graphTableScrollView.frame.size.width,
                                                                             self.graphTableScrollView.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             self->isTeaInfusionTableExpandedView = YES;
                         }];
    } else {
        // Set bounds (or where we want the view to be).
        CGRect bounds = self.addTeaInfusionTableView.bounds;
        
        // Animate frame upward
        [UIView animateWithDuration: 0.4f
                              delay: 0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             // TO DO: 40 is guestimated cell height
                             self.addTeaInfusionTableView.bounds = CGRectMake(bounds.origin.x, textField.tag * 40, bounds.size.width, bounds.size.height);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

#pragma mark - UIPickerView DataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return [self.pickerDataList count];
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.pickerDataList objectAtIndex: component] count];
}

#pragma mark - UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[self.pickerDataList objectAtIndex: component] objectAtIndex: row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"Row: %d Comp: %d", row, component);
    NSInteger minutesRow = [pickerView selectedRowInComponent: 0];
    NSInteger secondsRow = [pickerView selectedRowInComponent: 1];
    
    ((UITextField*)[self.textFieldList objectAtIndex: pickerView.tag]).text =
    [NSString stringWithFormat:@"%@:%@", [[self.pickerDataList objectAtIndex: 0] objectAtIndex: minutesRow],  [[self.pickerDataList objectAtIndex: 1] objectAtIndex: secondsRow]];
    
    ((Infusion*)[self.currentTea.infusions objectAtIndex: pickerView.tag]).infusionSeconds = [[[self.pickerDataList objectAtIndex: 0] objectAtIndex: minutesRow] intValue] * 60 + [[[self.pickerDataList objectAtIndex: 1] objectAtIndex: secondsRow] intValue];
    
    NSLog(@"Index: %d new time: %d", pickerView.tag,  ((Infusion*)[self.currentTea.infusions objectAtIndex: pickerView.tag]).infusionSeconds);
    
    [self.graphScrollView updateGraph];
}
@end

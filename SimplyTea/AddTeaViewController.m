//
//  AddTeaViewController.m
//  SimplyTea
//
//  Created by Ken Hung on 9/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// TODO:
//  - Change placeholder text to be appropriate.
//  - Verify input, if invalid show UIAlertView.

#import "AddTeaViewController.h"
#import "Infusion.h"
#import "AddTeaGraphViewController.h"
#import "TeaInputValidation.h"
#import "TeaDatabase.h"
#import "AddTeaDefaults.h"

#define ADD_TEA_TABLE_CELL_SPACING 25

@interface AddTeaViewController ()
    - (void) handleGesture: (id) sender;
    - (void) inputFromGraph: (id) sender;
    - (void) saveTea: (id) sender;
    - (void) inititalize;
    - (void) updateTeaWithTextField: (UITextField *) textField;
@end

@implementation AddTeaViewController
@synthesize textFieldList = textFieldList_, cellTextList = cellTextList_, tapGesture = tapGesture_, tea = tea_, saveBarButton = saveBarButton_, pickerDataList = pickerDataList_;

// This will not be called because we're loading from a nib, unless programmatically called
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc {
    [textFieldList_ release];
    [cellTextList_ release];
    [tapGesture_ release];
    [tea_ release];
    [saveBarButton_ release];
    [pickerDataList_ release];
    
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.title = @"New Tea";
    
    // Create Save button
    self.saveBarButton = [[[UIBarButtonItem alloc] initWithTitle: @"Save" style: UIBarButtonItemStyleBordered target: self action: @selector(saveTea:)] autorelease];
    self.saveBarButton.enabled = NO;
    self.navigationItem.rightBarButtonItem= self.saveBarButton;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tea = [[[Tea alloc] init] autorelease];
    self.textFieldList = [[[NSMutableArray alloc] init] autorelease];
    self.cellTextList = [[[NSMutableArray alloc] init] autorelease];
    
    [self inititalize];
    
    self.tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget: self action:@selector(handleGesture:)] autorelease];
    self.tapGesture.numberOfTapsRequired = 1;
    self.tapGesture.numberOfTouchesRequired = 1;
    self.tapGesture.cancelsTouchesInView = NO;
    
    [self.view addGestureRecognizer: self.tapGesture];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [tea_ release];
    [textFieldList_ release];
    [cellTextList_ release];
    [saveBarButton_ release];
    
    [self.view removeGestureRecognizer: tapGesture_];
    [tapGesture_ release];
}

- (void) inititalize {
    // Setup a default Tea objects
    for (int i = 0; i < ADD_TEA_DEFAULT_INFUSION_COUNT; i++) {
        [self.tea.infusions addObject: [[Infusion alloc] initWithInfusionNumber: i + 1 secondsToInfuse: ADD_TEA_DEFAULT_INFUSION_TIME]];
    }
    
    // Cell Titles
    [self.cellTextList addObject: @"Name:"];
    [self.cellTextList addObject: @"Tea Type:"];
    [self.cellTextList addObject: @"Subtype:"]; // 2
    
    // Cell TextFields
    for (int i = 0; i < [self.cellTextList count]; i++) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 150, 22)];
        textField.adjustsFontSizeToFitWidth = YES;
        textField.textColor = [UIColor blackColor];
        
        if (i < 2) {
            // Name and Tea Type
            textField.placeholder = @"Required";
        } else {
            // Sub Type
            textField.placeholder = @"Optional";
        }
        
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
        
        if (i == 1) {
            UIPickerView * pickerView = [[[UIPickerView alloc] initWithFrame: self.view.frame] autorelease];
            
            pickerView.delegate = self;
            pickerView.dataSource = self;
            pickerView.showsSelectionIndicator = YES;
            
            textField.inputView = pickerView;
        }
        
        textField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
        [textField setEnabled: YES];
        
        [self.textFieldList addObject: textField];
        
        [textField release];
    }
    
    // UIPicker Data
    self.pickerDataList = [[[NSMutableArray alloc] initWithArray: [[TeaDatabase sharedTeaDatabase] getAllPrimaryTeaTypesFromDatabase: DEFAULT_TEAS]] autorelease];
    [self.pickerDataList addObjectsFromArray: [[TeaDatabase sharedTeaDatabase] getAllPrimaryTeaTypesFromDatabase: USER_TEAS]];
}

- (void) handleGesture: (id) sender {
    for (UITextField * textField in self.textFieldList) {
        [textField resignFirstResponder];
    }
}

- (void) saveTea: (id) sender {
    if (![[TeaDatabase sharedTeaDatabase] checkIfExistsInDatabase: USER_TEAS tea: self.tea]) {
        [[TeaDatabase sharedTeaDatabase] insertTeaIntoDatabase: self.tea InDatabase: USER_TEAS];
    } else {
        NSLog(@"Duplicate entry found. Not INSERTED to user database");
    }
    
    // Show dialog
    self.saveBarButton.enabled = NO;
}

- (void) inputFromGraph: (id) sender {
    AddTeaGraphViewController * viewController = [[AddTeaGraphViewController alloc] initWithNibName:@"AddTeaGraphViewController" bundle: nil andTea: self.tea notificationTarget:self];
    
    [self.navigationController pushViewController: viewController animated:YES];
    
    [viewController release];
}

// TODO: Text verify
// NOTE: the provided textField's tag needs to be pointg to a valid index in the textFields array
- (void) updateTeaWithTextField: (UITextField *) textField {
    NSInteger index = textField.tag;
    
    if (index < 0 || index >= [self.textFieldList count]) {
        return;
    }
    
    if (index < 3) { // 0 - 2
        switch (index) {
            case 0:
                self.tea.subType1 = textField.text;
                break;
            case 1:
                self.tea.primaryTeaType = textField.text;
                break;
            case 2:
                self.tea.subType2 = textField.text;
                break;
            default:
                break;
        }
    }
    
    self.saveBarButton.enabled = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.cellTextList count] + 1; // Add one for button to infusions
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
    return ADD_TEA_TABLE_CELL_SPACING;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (indexPath.section != 3) {        
        cell.accessoryView = [self.textFieldList objectAtIndex: indexPath.section];
        cell.accessoryView.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = [self.cellTextList objectAtIndex: indexPath.section];
        cell.textLabel.minimumFontSize = 8;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    } else {
        UIButton *customButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        customButton.frame = CGRectMake(0, 0, 200, 42);
        // customButton.backgroundColor = [UIColor blueColor];
        [customButton setTitle: @"Edit Infusion Times" forState: UIControlStateNormal];
        [customButton addTarget:self action:@selector(inputFromGraph:) forControlEvents: UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:customButton];
    }
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     [detailViewController release];
//     */
//}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (textField.tag + 1 < [self.textFieldList count]) {
        [((UITextField *)[self.textFieldList objectAtIndex: textField.tag + 1]) becomeFirstResponder];
    }
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    // textField has 0 indexed tag 
    [self updateTeaWithTextField: textField];
}

#pragma mark - 
#pragma mark GraphView Protocol
- (void) infusionChangeAtInfusion:(Infusion *)infusion timeChange:(BOOL)didTimeChange {
    self.saveBarButton.enabled = YES;
}

- (void) shouldDisableScrolling:(BOOL)disableScrolling {
    
}

#pragma mark - UIPickerView DataSource 
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerDataList count];
}

#pragma mark - UIPickerView Delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.pickerDataList objectAtIndex: row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    ((UITextField*)[self.textFieldList objectAtIndex: 1]).text = [self.pickerDataList objectAtIndex: row];
}

@end

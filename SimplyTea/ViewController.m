//
//  ViewController.m
//  SimplyTea
//
//  Created by Ken Hung on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "TeaDatabase.h"
#import "Tea.h"
#import "Infusion.h"
#import "TimerGraphViewController.h"
#import "TeaTableViewCell.h"
#import "FavoritesTableViewController.h"
#import "TeaDetailsViewController.h"
#import "Settings.h"
#import "AddTeaViewController.h"

@interface ViewController () 
    - (void) updateTypeList;
    - (void) addNewTeaAction: (id) sender;
    - (void) filterListByPartialString: (NSString *) partialString;
    - (void) retrieveSpecifcTeaListWithTeaTypeName: (NSString *) teaTypeName;
    - (void) setupSearchBar;
@end

@implementation ViewController
@synthesize teaTypeScrollView, specificTeaTableView, specificTeaList, teaTypeList, currentTeaIndex, specificTeaSearchBar;

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.specificTeaList = [[[NSMutableArray alloc] init] autorelease];
        self->lastIndex = 0;
        
        self.title = @"Specfic Teas";
    }
    
    return self;
}

/**
 * Filters the current table view list by the partial string input from the UISearchBar and updates the table. AKA Instantaneous search.
 */
- (void) filterListByPartialString: (NSString *) partialString {
    NSMutableArray * listTemp = [[TeaDatabase sharedTeaDatabase] getEntriesWithTeaType: [self.teaTypeList objectAtIndex: self-> lastIndex]inDatabase: DEFAULT_TEAS];
    [listTemp addObjectsFromArray: [[TeaDatabase sharedTeaDatabase] getEntriesWithTeaType: [self.teaTypeList objectAtIndex: self-> lastIndex]inDatabase: USER_TEAS]];
    
    if (partialString && ![partialString isEqualToString: @""]) {
        NSMutableArray * newList = [[NSMutableArray alloc] init];
        
        for (Tea * tea in listTemp) {
            // Search within subtypes I an II
            if ([[tea.subType1 lowercaseString] rangeOfString: [partialString lowercaseString] ].location == 0
                || [[tea.subType2 lowercaseString] rangeOfString: [partialString lowercaseString] ].location == 0) {
                [newList addObject: tea];
            }
        }
        
        self.specificTeaList = newList;
        [newList release];
    } else {
        self.specificTeaList = listTemp;
    }
    
    [self.specificTeaTableView reloadData];
}

/**
 * Filters the table view list by tea type name.
 */
- (void) retrieveSpecifcTeaListWithTeaTypeName: (NSString *) teaTypeName {
    self.specificTeaList = [[TeaDatabase sharedTeaDatabase] getEntriesWithTeaType: teaTypeName inDatabase: DEFAULT_TEAS];
    [self.specificTeaList addObjectsFromArray: [[TeaDatabase sharedTeaDatabase] getEntriesWithTeaType: teaTypeName inDatabase: USER_TEAS]];
    
    [self.specificTeaTableView reloadData];
}

// NOTE: make sure database is initialized at least once
- (void) updateTypeList {
    // Check if we really have to update first
    NSMutableArray * defaultTeas = [[TeaDatabase sharedTeaDatabase] getAllPrimaryTeaTypesFromDatabase: DEFAULT_TEAS];
    NSMutableArray * userTeas = [[TeaDatabase sharedTeaDatabase] getAllPrimaryTeaTypesFromDatabase: USER_TEAS];
    
    if ([self.teaTypeList count] == [defaultTeas count] + [userTeas count]) {
        return;
    }
    
    // Get a string list of all tea types from database
    self.teaTypeList = [[[NSMutableArray alloc] initWithArray: defaultTeas] autorelease];
    [self.teaTypeList addObjectsFromArray: userTeas];
    
    // Remove all labels from type scroll view
    [self.teaTypeScrollView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    CGRect scrollDefaultSize = self.teaTypeScrollView.bounds;
    
    // Add content to horizontal scroll view
    int widthOffset = 0;
    for (NSString * teaType in self.teaTypeList) {
        UILabel * typeLabel = [[[UILabel alloc] initWithFrame: CGRectMake(scrollDefaultSize.size.width * widthOffset, 0/*scrollDefaultSize.origin.y*/, scrollDefaultSize.size.width, scrollDefaultSize.size.height)] autorelease];
        
        typeLabel.textAlignment = UITextAlignmentCenter;
        typeLabel.font = [UIFont fontWithName: @"Arial"size: 32];
        typeLabel.text = teaType;
        typeLabel.backgroundColor = [UIColor colorWithRed:205.0f/255.0f green: 133.0f/255.0f blue: 63.0/255.0f alpha:1.0f];
        typeLabel.textColor = [UIColor whiteColor];
        typeLabel.minimumFontSize = 12;
        typeLabel.numberOfLines = 1;
        typeLabel.adjustsFontSizeToFitWidth = YES;
        
        widthOffset++;
        
        [self.teaTypeScrollView addSubview: typeLabel];
    }
    
    // TODO: Scroll indicators somehow not showing???
    self.teaTypeScrollView.contentSize = CGSizeMake(scrollDefaultSize.size.width * [self.teaTypeList count], scrollDefaultSize.size.height);
}

/**
 * Tries to changes the UISearchBar keyboard 's Search Button to a Done button and also makes it enabled with no test.
 */
- (void) setupSearchBar {
    if ( self.specificTeaSearchBar == nil) {
        self.specificTeaSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.specificTeaSearchBar.delegate = self;
        self.specificTeaSearchBar.barStyle = UIBarStyleBlackOpaque;
    }
    
    self.specificTeaTableView.tableHeaderView = self.specificTeaSearchBar;
    self.specificTeaSearchBar.text = @"";
    
    for (UIView *searchBarSubview in [self.specificTeaSearchBar subviews]) {
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                [(UITextField *)searchBarSubview setReturnKeyType:UIReturnKeyDone];
                [(UITextField *)searchBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
                UITextField *tf = (UITextField *)searchBarSubview;
                tf.enablesReturnKeyAutomatically = NO;
            }
            @catch (NSException * e) {
                // ignore exception
                NSLog(@"!!!!! NSException thrown: %@", [e description]);
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self updateTypeList];
    
   // CGRect screenSize = [UIScreen mainScreen].bounds;
    
    [self retrieveSpecifcTeaListWithTeaTypeName: [self.teaTypeList objectAtIndex: 0]];
    
    // Create Add button
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target: self action:@selector(addNewTeaAction:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [addButton release];
    
    // Start directly with favorites
    if ([Settings shouldStartWithFavorites]) {
        [self filterTableByFavorites: nil];
    }

    [self setupSearchBar];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    // Refresh our table incase we changed something from favorites table view
    [self updateTypeList];
    
    if (self->lastIndex >= 0) {
        [self retrieveSpecifcTeaListWithTeaTypeName: [self.teaTypeList objectAtIndex: self-> lastIndex]];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    // If View isn't touched initially this wont be called when returning from graph view
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - Callbacks
- (void) favoritesCallBack: (id) sender {
    UIButton * button = (UIButton *)sender;
    
    if (button.tag < [self.specificTeaList count]) {
        Tea * tea = [self.specificTeaList objectAtIndex: button.tag];
        
        tea.isFavorite = !tea.isFavorite;
        [[TeaDatabase sharedTeaDatabase] updateTableEntryID: tea.databaseID withFavorite: tea.isFavorite inDatabase: tea.databaseType];
        
        [self.specificTeaTableView reloadData];
    }
}

- (void) detailsCallBack: (id) sender {
    UIButton * button = (UIButton *)sender;
    
    if (button.tag < [self.specificTeaList count]) {
        Tea * tea = [self.specificTeaList objectAtIndex: button.tag];
        
        TeaDetailsViewController * tdvc = [[TeaDetailsViewController alloc] initWithNibName: @"TeaDetailsViewController" bundle:nil tea:tea];
        [self.navigationController  pushViewController: tdvc animated: YES];
        [tdvc release];
    }
}

- (void) filterTableByFavorites: (id) sender {
    FavoritesTableViewController * ftvc = [[FavoritesTableViewController alloc] initWithNibName:@"FavoritesTableViewController" bundle: nil];
    
    UINavigationController * navigationController = [[UINavigationController alloc] initWithRootViewController:ftvc];
    navigationController.toolbarHidden = YES;
    navigationController.navigationBar.tintColor = [UIColor colorWithRed:107.0f/255.0f green: 142.0f/255.0f blue: 35.0/255.0f alpha:0.15f];
    
    [self presentModalViewController: navigationController animated: YES];
    [ftvc release];
    [navigationController release];
}

- (void) brewButtonAction: (id) sender {
    if ([self.specificTeaList count] <= 0) {
        // display message
        return;
    }
    
    TimerGraphViewController * timerGraphViewController = [[TimerGraphViewController alloc] initWithNibName:@"TimerGraphViewController" bundle: nil andTea: [self.specificTeaList objectAtIndex: self.currentTeaIndex]];
    
    [self.navigationController pushViewController: timerGraphViewController animated: YES];
    [timerGraphViewController release];
}

- (void) addNewTeaAction: (id) sender {
    AddTeaViewController * atvc = [[AddTeaViewController alloc] initWithNibName: @"AddTeaViewController" bundle: nil];
    [self.navigationController pushViewController:atvc animated: YES];
    [atvc release];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.specificTeaList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    TeaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
   // if (cell == nil) {
       // cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
   //     cell = [[[TeaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
   // }
    
    if (cell == nil){
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: @"TeaTableViewCell" owner:nil options:nil];
        
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass: [TeaTableViewCell class]])
            {
                cell = (TeaTableViewCell *) currentObject;
                break;
            } else {
                // Backup for whatever reason
                cell = [[[TeaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
        }
    }
    
    Tea * tea = (Tea *)[self.specificTeaList objectAtIndex: indexPath.row];
    
    // Configure the cell...
    [cell.favoritesButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents]; 
    
    [cell.favoritesButton addTarget: self action: @selector(favoritesCallBack:) forControlEvents:UIControlEventTouchUpInside];
    cell.favoritesButton.tag = indexPath.row; // NTE: using UIButton's tag as the index into the tea list
    
    [cell.detailButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents]; 
    [cell.detailButton addTarget: self action: @selector(detailsCallBack:) forControlEvents:UIControlEventTouchUpInside];
    cell.detailButton.tag = indexPath.row; // NTE: using UIButton's tag as the index into the tea list
    
    cell.textLabel.text = tea.subType1;
    cell.subTextlabel.text = tea.subType2;
    
    if (tea.isFavorite) {
        cell.favoritesButton.imageView.image = [UIImage imageNamed:@"last-step-assets-star2-04"];
    } else {
        cell.favoritesButton.imageView.image = [UIImage imageNamed:@"last-step-assets-star2-08"];
    }
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    self.currentTeaIndex = indexPath.row;
    
    [self brewButtonAction: nil];
}

#pragma mark - Scroll view delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    // NOTE: Both scroll views will call this callback
    if (scrollView.tag == 0) {
        // Side ScrollView for tea types
        double xCoord = self.teaTypeScrollView.bounds.origin.x;
        NSInteger widthSize = [UIScreen mainScreen].bounds.size.width;
        NSInteger newIndex = xCoord / widthSize;
        
        // Tea category scroller (left/right)
        // lastIndex keeps tableScrolling from triggering this callback for some reason
        if ((NSInteger)xCoord % widthSize == 0 && self->lastIndex != newIndex) {
            self->lastIndex = newIndex;

            [self filterListByPartialString: self.specificTeaSearchBar.text];
        }
    } else if (scrollView.tag == 1) {

    }
}

#pragma mark - UISearchBar Protocol Methods
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterListByPartialString: searchText];
    NSLog(@"Text changed");
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
}

#pragma mark - Deallocation
- (void) dealloc {
    [teaTypeScrollView release];
    [specificTeaTableView release];
    [specificTeaList release];
    [teaTypeList release];
    [specificTeaSearchBar release];
    
    [super dealloc];
}

@end

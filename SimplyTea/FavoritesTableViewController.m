//
//  FavoritesTableViewController.m
//  SimplyTea
//
//  Created by Ken Hung on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavoritesTableViewController.h"
#import "TeaTableViewCell.h"
#import "TimerGraphViewController.h"
#import "TeaDatabase.h"

@interface FavoritesTableViewController (Private)
    - (void) setupSearchBar;
@end

@implementation FavoritesTableViewController
@synthesize favoritesTeaList, favoritesTableView, favoritesSearchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.favoritesTeaList = [[TeaDatabase sharedTeaDatabase] getFavoritesInDatabase: DEFAULT_TEAS];
        [self.favoritesTeaList addObjectsFromArray: [[TeaDatabase sharedTeaDatabase] getFavoritesInDatabase: USER_TEAS]];
        self.title = @"Favorites";
    }
    return self;
}

- (void) dismissFavoritesTable: (id) sender {
    [self dismissModalViewControllerAnimated: YES];
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
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
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
    // Keep favorites star image updated
    [self.favoritesTableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.favoritesTeaList count];
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
    
    Tea * tea = (Tea *)[self.favoritesTeaList objectAtIndex: indexPath.row];
    
    // Configure the cell...
    [cell.favoritesButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents]; 
    
    [cell.favoritesButton addTarget: self action: @selector(favoritesCallBack:) forControlEvents:UIControlEventTouchUpInside];
    cell.favoritesButton.tag = indexPath.row; // NTE: using UIButton's tag as the index into the tea list
    
    cell.textLabel.text = tea.subType1;
    cell.subTextlabel.text = tea.subType2;
    
    if (tea.isFavorite) {
        cell.favoritesButton.imageView.image = [UIImage imageNamed:@"last-step-assets-star2-04"];
    } else {
        cell.favoritesButton.imageView.image = [UIImage imageNamed:@"last-step-assets-star2-08"];
    }
    
    return cell;
}

- (void) favoritesCallBack: (id) sender {
    UIButton * button = (UIButton *)sender;
    
    if (button.tag < [self.favoritesTeaList count]) {
        Tea * tea = [self.favoritesTeaList objectAtIndex: button.tag];
        
        tea.isFavorite = !tea.isFavorite;
        [[TeaDatabase sharedTeaDatabase] updateTableEntryID: tea.databaseID withFavorite: tea.isFavorite inDatabase: tea.databaseType];
        
        [self.favoritesTableView reloadData];
    }
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
    
    TimerGraphViewController * timerGraphViewController = [[TimerGraphViewController alloc] initWithNibName:@"TimerGraphViewController" bundle: nil andTea: [self.favoritesTeaList objectAtIndex: indexPath.row]];
    
    [self.navigationController pushViewController: timerGraphViewController animated: YES];
    [timerGraphViewController release];
}

#pragma mark - UISearchBar Protocol Methods
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterListByPartialString: searchText];
    NSLog(@"Text changed");
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

// filters on local tea list
- (void) filterListByPartialString: (NSString *) partialString {
    NSMutableArray * favListTemp = [[TeaDatabase sharedTeaDatabase] getFavoritesInDatabase: DEFAULT_TEAS];
    [favListTemp addObjectsFromArray: [[TeaDatabase sharedTeaDatabase] getFavoritesInDatabase: USER_TEAS]];
    
    if (![partialString isEqualToString: @""]) {
        NSMutableArray * newList = [[NSMutableArray alloc] init];
        
        for (Tea * tea in favListTemp) {
            NSLog(@"Filter: %d %d", [tea.subType1 rangeOfString: partialString].location, [tea.subType1 rangeOfString: partialString].length);
            
            // filter by subtypes I and II
            if ([[tea.subType1 lowercaseString] rangeOfString: [partialString lowercaseString] ].location == 0
                || [[tea.subType2 lowercaseString] rangeOfString: [partialString lowercaseString] ].location == 0) {
                [newList addObject: tea];
            }
        }
        
        self.favoritesTeaList = newList;
        [newList release];
    } else {
        self.favoritesTeaList = favListTemp;
    }
    
    [self.favoritesTableView reloadData];
}

/**
 * Tries to changes the UISearchBar keyboard 's Search Button to a Done button and also makes it enabled with no test.
 */
- (void) setupSearchBar {
    if ( self.favoritesSearchBar == nil) {
        self.favoritesSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
        self.favoritesSearchBar.delegate = self;
        self.favoritesSearchBar.barStyle = UIBarStyleBlackOpaque;
    }
    
    self.favoritesTableView.tableHeaderView = self.favoritesSearchBar;
    self.favoritesSearchBar.text = @"";
    
    for (UIView *searchBarSubview in [self.favoritesSearchBar subviews]) {
        if ([searchBarSubview conformsToProtocol:@protocol(UITextInputTraits)]) {
            @try {
                [(UITextField *)searchBarSubview setReturnKeyType:UIReturnKeyDone];
                [(UITextField *)searchBarSubview setKeyboardAppearance:UIKeyboardAppearanceAlert];
                UITextField *tf = (UITextField *)searchBarSubview;
                tf.enablesReturnKeyAutomatically = NO;
            }
            @catch (NSException * e) {
                // ignore exception
            }
        }
    }
}

- (void) dealloc {
    [favoritesTeaList release];
    [favoritesTableView release];
    [favoritesSearchBar release];
    
    [super dealloc];
}
@end

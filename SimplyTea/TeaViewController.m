//
//  TeaViewController.m
//  SimplyTea
//
//  Created by Ken Hung on 6/16/13.
//
//

#import "TeaViewController.h"
#import "TeaDatabase.h"
#import "FavoritesTableViewController.h"
#import "TeaTypeTableViewCell.h"
#import "ViewController.h"

@interface TeaViewController ()

@end

@implementation TeaViewController
@synthesize teaTypeList = teaTypeList_, teaTypeTableView = teaTypeTableView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // Get all Tea types
        self.teaTypeList = [[TeaDatabase sharedTeaDatabase] getAllPrimaryTeaTypesFromDatabase: DEFAULT_TEAS];
        [self.teaTypeList addObjectsFromArray: [[TeaDatabase sharedTeaDatabase] getAllPrimaryTeaTypesFromDatabase: USER_TEAS]];
        NSLog(@"count %d", [self.teaTypeList count]);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Choose Your Tea";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) filterTableByFavorites: (id) sender {
    FavoritesTableViewController * ftvc = [[[FavoritesTableViewController alloc] initWithNibName:@"FavoritesTableViewController" bundle: nil] autorelease];
    
    UINavigationController * navigationController = [[[UINavigationController alloc] initWithRootViewController:ftvc] autorelease];
    navigationController.toolbarHidden = YES;
    navigationController.navigationBar.tintColor = [UIColor colorWithRed:107.0f/255.0f green: 142.0f/255.0f blue: 35.0/255.0f alpha:0.15f];
    
    [self presentModalViewController: navigationController animated: YES];
}

- (void) detailsCallBack: (id) sender {
    /*UIButton * button = (UIButton *)sender;
    
    if (button.tag < [self.specificTeaList count]) {
        Tea * tea = [self.specificTeaList objectAtIndex: button.tag];
        
        TeaDetailsViewController * tdvc = [[TeaDetailsViewController alloc] initWithNibName: @"TeaDetailsViewController" bundle:nil tea:tea];
        [self.navigationController  pushViewController: tdvc animated: YES];
        [tdvc release];
    }*/
}

#pragma mark - Orientation Callbacks
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.teaTypeList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;//[self.teaTypeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    TeaTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // if (cell == nil) {
    // cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    //     cell = [[[TeaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    // }
    
    if (cell == nil){
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed: @"TeaTypeTableViewCell" owner:nil options:nil];
        
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass: [TeaTypeTableViewCell class]])
            {
                cell = (TeaTypeTableViewCell *) currentObject;
                break;
            } else {
                // Backup for whatever reason
                cell = [[[TeaTypeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            }
        }
    }
    
    // Configure the cell...
    [cell.detailButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [cell.detailButton addTarget: self action: @selector(detailsCallBack:) forControlEvents:UIControlEventTouchUpInside];
    cell.detailButton.tag = indexPath.row; // NTE: using UIButton's tag as the index into the tea list
    
    cell.teaTypeLabel.text = [self.teaTypeList objectAtIndex: indexPath.section];
    
    return cell;
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1; // you can have your own choice, of course
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}*/

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
    
   // self.currentTeaIndex = indexPath.row;
    ViewController * specificTeaViewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle: nil] autorelease];
    [self.navigationController pushViewController: specificTeaViewController animated: YES];
}

- (void) dealloc {
    [teaTypeList_ release];
    [teaTypeTableView_ release];
    
    [super dealloc];
}
@end

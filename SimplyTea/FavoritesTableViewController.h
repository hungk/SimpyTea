//
//  FavoritesTableViewController.h
//  SimplyTea
//
//  Created by Ken Hung on 9/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoritesTableViewController : UIViewController <UITableViewDelegate, UISearchBarDelegate> {
    
}

@property (nonatomic, retain) NSMutableArray * favoritesTeaList;
@property (nonatomic, retain) IBOutlet UITableView * favoritesTableView;
@property (nonatomic, retain) UISearchBar * favoritesSearchBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
- (void) favoritesCallBack: (id) sender;
- (IBAction) dismissFavoritesTable: (id) sender;
- (void) filterListByPartialString: (NSString *) partialString;
@end

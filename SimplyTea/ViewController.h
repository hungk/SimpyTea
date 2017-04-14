//
//  ViewController.h
//  SimplyTea
//
//  Created by Ken Hung on 6/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UIScrollViewDelegate, UISearchBarDelegate> {
    // lastIndex is used to keep tableScrolling from triggering the scrolling callback for some reason
    NSInteger lastIndex;
}

@property (nonatomic, retain) IBOutlet UIScrollView * teaTypeScrollView;
@property (nonatomic, retain) IBOutlet UITableView * specificTeaTableView;
@property (nonatomic, retain) NSMutableArray * specificTeaList, * teaTypeList;
@property (nonatomic, assign) NSInteger currentTeaIndex;
@property (nonatomic, retain) UISearchBar * specificTeaSearchBar;

- (IBAction) brewButtonAction: (id) sender;
- (void) favoritesCallBack: (id) sender;
- (void) detailsCallBack: (id) sender;
- (IBAction) filterTableByFavorites: (id) sender;
@end

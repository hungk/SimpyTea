//
//  TeaViewController.h
//  SimplyTea
//
//  Created by Ken Hung on 6/16/13.
//
//

#import <UIKit/UIKit.h>

@interface TeaViewController : UIViewController <UITableViewDelegate> {
    
}

@property (nonatomic, retain) NSMutableArray * teaTypeList;
@property (nonatomic, retain) IBOutlet UITableView * teaTypeTableView;
- (IBAction) filterTableByFavorites: (id) sender;
- (void) detailsCallBack: (id) sender;
@end

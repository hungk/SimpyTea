//
//  TeaTypeTableViewCell.h
//  SimplyTea
//
//  Created by Ken Hung on 6/17/13.
//
//

#import <UIKit/UIKit.h>

@interface TeaTypeTableViewCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UILabel * teaTypeLabel, * colorLabel;
@property (nonatomic, retain) IBOutlet UIButton * detailButton;
@property (nonatomic, retain) IBOutlet UIImageView * backgroundImageView;
@end

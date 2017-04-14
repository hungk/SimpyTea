//
//  TeaTableViewCell.h
//  SimplyTea
//
//  Created by Ken Hung on 9/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tea.h"

@interface TeaTableViewCell : UITableViewCell
@property (nonatomic, retain) IBOutlet UILabel * textLabel, * subTextlabel;
@property (nonatomic, retain) IBOutlet UIButton * favoritesButton, * detailButton;
@property (nonatomic, retain) IBOutlet UIImageView * backgroundImageView;
@end

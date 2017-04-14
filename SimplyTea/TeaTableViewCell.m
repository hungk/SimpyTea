//
//  TeaTableViewCell.m
//  SimplyTea
//
//  Created by Ken Hung on 9/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TeaTableViewCell.h"

@implementation TeaTableViewCell
@synthesize textLabel, favoritesButton, subTextlabel, backgroundImageView, detailButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
   // [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted: (BOOL)highlighted animated: (BOOL)animated
{
    //[super setHighlighted:highlighted animated:animated];
    
    // don't highlight
    if (highlighted) {
        self.backgroundImageView.backgroundColor = [UIColor lightGrayColor];
    } else {
        self.backgroundImageView.backgroundColor = [UIColor whiteColor];
    }
}

- (void) dealloc {
    [textLabel release];
    [favoritesButton release];
    [subTextlabel release];
    [detailButton release];
    [backgroundImageView release];
    
    [super dealloc];
}
@end

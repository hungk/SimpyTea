//
//  TeaTypeTableViewCell.m
//  SimplyTea
//
//  Created by Ken Hung on 6/17/13.
//
//

#import "TeaTypeTableViewCell.h"

@implementation TeaTypeTableViewCell
@synthesize teaTypeLabel = teaTypeLabel_, backgroundImageView = backgroundImageView_, detailButton = detailButton_, colorLabel = colorLabel_;

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
    [super setSelected:selected animated:animated];

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
    [teaTypeLabel_ release];
    [detailButton_ release];
    [backgroundImageView_ release];
    [colorLabel_ release];
    
    [super dealloc];
}

@end

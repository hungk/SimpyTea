//
//  GraphScrollView.m
//  SimplyTea
//
//  Created by Ken Hung on 9/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
// This Scroll view is currently initialized in a NIB file, so at least an inirializeGraphViewWithTea needs to be called in viewDidLoad
// of it's parent ViewController

#import "GraphScrollView.h"
#import "Graph.h"
#import "Tea.h"
#import "GraphOverlayView.h"
#import "iOSVersionCheckUtility.h"

@interface GraphScrollView ()
    - (void) displayFadeOutWithTitle: (NSString *) titleToFade intView: (UIView *) view;
    - (void) pagingButtonPressed: (id) sender;
    - (CGFloat) getXOriginPageLeft: (BOOL) pageLeft;
    - (void) updatePagingButtonsVisibility;
    - (void) updateBoundsWithCurrentPage;
    - (void) updateCurrentPageWithCurrentBounds;
@end

@implementation GraphScrollView
@synthesize fadingTitle, graphTimeLabel, graphInfusionLabel, graphView, graph = graph_, graphOverlayView = graphOverlayView_, leftMoreButton = leftMoreButton_, rightMoreButton = rightMoreButton_;

- (void) initializeGraphViewWithTea: (Tea *) tea notificationTarget: (id<InfusionChangedNotificationProtocol>) target {
    BAR_HEIGHT = 25;
    
    CGRect screenRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    self.delegate = self;
    
    self.graph = [[[Graph alloc] initWithTea: tea] autorelease];
    self.graphView = [[[GraphView alloc] initWithFrame: screenRect graph: self.graph notificationTarget: target] autorelease];
    self.graphOverlayView = [[[GraphOverlayView alloc] initWithFrame:screenRect graph: self.graph] autorelease];
    
    NSInteger buttonWidth = 20, buttonHeight = 100;
    self.leftMoreButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.leftMoreButton setBackgroundImage: [UIImage imageNamed: @"arrow_left.png"] forState:UIControlStateNormal];
    self.leftMoreButton.frame = CGRectMake(0, self.bounds.size.height / 2  - buttonHeight / 2, buttonWidth, buttonHeight);
    self.leftMoreButton.tag = 0;
    [self.leftMoreButton addTarget: self action: @selector(pagingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightMoreButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [self.rightMoreButton setBackgroundImage: [UIImage imageNamed: @"arrow.png"] forState: UIControlStateNormal];
    self.rightMoreButton.frame = CGRectMake(self.bounds.size.width - buttonWidth, self.bounds.size.height / 2 - buttonHeight / 2, buttonWidth, buttonHeight);
    self.rightMoreButton.tag = 1;
    [self.rightMoreButton addTarget: self action: @selector(pagingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview: self.graphView];
    [self addSubview: self.graphOverlayView];
    [self addSubview: self.leftMoreButton];
    [self addSubview: self.rightMoreButton];
    
  //  self.pagingEnabled = YES;
    self.bounces = NO;
    self.contentSize = CGSizeMake(self.graphView.frame.size.width, self.graphView.frame.size.height);
    self.backgroundColor = [UIColor whiteColor];
    //self.scrollEnabled = NO;
   // [self displayFadeOutWithTitle: self.graph.tea.subType1 intView: self];
    
    graphScrollViewBoundsInPortrait = self.bounds;
    self->currentPage = 1;
    
    [self updatePagingButtonsVisibility];
}

- (void) displayFadeOutWithTitle: (NSString *) titleToFade intView: (UIView *) view {
    // Remove this title from superview and free it if we've loading something already
    if (self.fadingTitle != nil) {
        // set fame to fit orientation
        self.fadingTitle.frame = CGRectMake(0, 0, view.bounds.size.width, 30);
        // resetn alpha and text
        [self.fadingTitle setAlpha: 1.0f];
        [self.fadingTitle setText: titleToFade];
    } else {
        // Init a fading title label
        self.fadingTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 30)];
        self.fadingTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.fadingTitle setFont: [UIFont boldSystemFontOfSize: 14]];
        [self.fadingTitle setBackgroundColor: [UIColor colorWithRed: 49.0f/255.0f green: 79.0f/255.0f blue: 79.0/255.0f alpha:0.75f]];
        [self.fadingTitle setTextColor: [UIColor whiteColor]];
        [self.fadingTitle setText: titleToFade];
        self.fadingTitle.userInteractionEnabled = NO;
        self.fadingTitle.textAlignment = UITextAlignmentCenter;
        self.fadingTitle.numberOfLines = 1;
        self.fadingTitle.minimumFontSize = 6;
        self.fadingTitle.adjustsFontSizeToFitWidth = YES;
        
        [view addSubview: self.fadingTitle];
    }
    
    // animate fade out
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:10];
    [self.fadingTitle setAlpha:0];
    [UIView commitAnimations];
}

- (void) toggleGraphEditability {
    self.graphView.isEditable = !self.graphView.isEditable;
}

- (void) incrementGraphInfusionHighlight {
    // TO DO: Add KVO to check for index out of bounds
    if (self.graphView.highlightedInfusionIndex < [self.graphView.graph.tea.infusions count] - 1) {
        self.graphView.highlightedInfusionIndex++;
        [self.graphView refreshDisplay];
    }
}

- (void) decrementGraphInfusionHighlight {
    // TO DO: Add KVO to check for index out of bounds
    if (self.graphView.highlightedInfusionIndex > 0) {
        self.graphView.highlightedInfusionIndex--;
        [self.graphView refreshDisplay];
    }
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    CGRect screenSize = [UIScreen mainScreen].bounds; // height = width, width = height (static screen resolution)
    
    CGRect newScrollFrame;
    
    if (UIInterfaceOrientationIsPortrait(fromInterfaceOrientation)) {
        // 52 is toolbar height
        NSInteger toolbarHeight = 0;
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
            toolbarHeight = 64;
        else
            toolbarHeight = 52;
        
        self.frame = CGRectMake(0, 0, screenSize.size.height, screenSize.size.width - toolbarHeight);
        self.bounds = self.frame;
        newScrollFrame = [self.graph calculateGraphParametersInRect: CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];

        // Landscape
        self.graphView.frame = newScrollFrame;
        self.graphView.bounds = self.graphView.frame;
        self.graphOverlayView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
        
        self.contentSize = CGSizeMake(self.graphView.frame.size.width, self.graphView.frame.size.height);
    } else {
        self.frame = graphScrollViewBoundsInPortrait;
        self.bounds = self.frame;
        newScrollFrame = [self.graph calculateGraphParametersInRect: self.bounds];

        // Portrait
        self.graphView.frame = newScrollFrame;
        self.graphView.bounds = self.graphView.frame;
        self.graphOverlayView.frame = self.frame;
        
        self.contentSize = CGSizeMake(self.graphView.frame.size.width, self.graphView.frame.size.height);
    }
    
    [self updateBoundsWithCurrentPage];
    
    // Update the XScrollingVisualbaseline so GraphView Time guide line will follow the baseline while scrolling
    self.graph.XScrollingVisualBaseline = self.bounds.origin.x + self.graph.XOffset;
    // Update overlya position
    self.graphOverlayView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.graphOverlayView.frame.size.width, self.graphOverlayView.frame.size.height);
    
    [self updateGraph];
    
    // Update left and right paging buttons
    [self updatePagingButtonsVisibility];
    [self updateViews];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    // Update the XScrollingVisualbaseline so GraphView Time guide line will follow the baseline while scrolling
    self.graph.XScrollingVisualBaseline = self.bounds.origin.x + self.graph.XOffset;
    // update to reflect line change
    [self.graphView refreshDisplay];
    
    // self.fadingTitle.frame = CGRectMake(self.bounds.origin.x, 0, self.bounds.size.width, BAR_HEIGHT);
    self.graphOverlayView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.graphOverlayView.frame.size.width, self.graphOverlayView.frame.size.height);
    
    [self updateViews];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self updateCurrentPageWithCurrentBounds];
    [self updatePagingButtonsVisibility];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateCurrentPageWithCurrentBounds];
    [self updatePagingButtonsVisibility];
}

- (void) updateViews {
    NSInteger buttonWidth = 20, buttonHeight = 100;
    self.leftMoreButton.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height / 2  - buttonHeight / 2, buttonWidth, buttonHeight);
    self.rightMoreButton.frame = CGRectMake(self.bounds.origin.x + self.bounds.size.width - buttonWidth, self.bounds.size.height / 2 - buttonHeight / 2, buttonWidth, buttonHeight);
}

- (void) updateGraph {
    // Update graph layers and redraw
    [self.graphView updateLayers];
    [self.graphView refreshDisplay];
    
    // Update overlay layers and redraw
    [self.graphOverlayView updateLayers];
    [self.graphOverlayView setNeedsDisplay];
}

#pragma mark - Left and Right Paging buttons
- (void) pagingButtonPressed: (id) sender {
    if ([sender isKindOfClass: [UIButton class]]) {
        UIButton * button = (UIButton *)sender;
        CGRect bounds = self.bounds;
        
        if (button.tag == 0) {
            // Left
            [UIView animateWithDuration: 0.5f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.bounds = CGRectMake([self getXOriginPageLeft: YES], bounds.origin.y, bounds.size.width, bounds.size.height);
                                 // Update the XScrollingVisualbaseline so GraphView Time guide line will follow the baseline while scrolling
                                 self.graph.XScrollingVisualBaseline = self.bounds.origin.x + self.graph.XOffset;
                                 // update to reflect line change
                                 [self.graphView refreshDisplay];
                                 
                                 // self.fadingTitle.frame = CGRectMake(self.bounds.origin.x, 0, self.bounds.size.width, BAR_HEIGHT);
                                 self.graphOverlayView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.graphOverlayView.frame.size.width, self.graphOverlayView.frame.size.height);
                                 
                                 [self updateViews];
                             }
                             completion:^(BOOL finished) {
                                 [self updatePagingButtonsVisibility];
                             }];
        } else if (button.tag == 1) {
            // Right
            [UIView animateWithDuration: 0.5f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 self.bounds = CGRectMake([self getXOriginPageLeft: NO], bounds.origin.y, bounds.size.width, bounds.size.height);
                                 // Update the XScrollingVisualbaseline so GraphView Time guide line will follow the baseline while scrolling
                                 self.graph.XScrollingVisualBaseline = self.bounds.origin.x + self.graph.XOffset;
                                 
                                 // self.fadingTitle.frame = CGRectMake(self.bounds.origin.x, 0, self.bounds.size.width, BAR_HEIGHT);
                                 self.graphOverlayView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.graphOverlayView.frame.size.width, self.graphOverlayView.frame.size.height);
                                 
                                 [self updateViews];
                             }
                             completion:^(BOOL finished) {
                                 // update to reflect line change
                                 [self.graphView refreshDisplay];
                                 
                                 [self updatePagingButtonsVisibility];
                             }];
        }
    }
}

- (CGFloat) getXOriginPageLeft: (BOOL) pageLeft {
    NSInteger numberOfPages = ceil(self.contentSize.width / self.bounds.size.width);
    NSInteger lastPageRemainder = (NSInteger)self.contentSize.width % (NSInteger)self.bounds.size.width;

    CGFloat xOrigin = self.bounds.origin.x;
    
    if (pageLeft) {
        // Page Left
        if (self->currentPage > 1) {
            xOrigin = self.bounds.size.width * (--self->currentPage - 1);
        }
    } else {
        // Page Right
        if (self->currentPage < numberOfPages) {
            xOrigin = self.bounds.size.width * (self->currentPage++);
            
            if (self->currentPage == numberOfPages) {
                xOrigin -= self.bounds.size.width - lastPageRemainder;
            }
        }
    }

    return xOrigin;
}

- (void) updatePagingButtonsVisibility {
    if (self->currentPage == 1) {
        self.leftMoreButton.hidden = YES;
        self.rightMoreButton.hidden = NO;
    } else if (self->currentPage == ceil(self.contentSize.width / self.bounds.size.width)) {
        self.leftMoreButton.hidden = NO;
        self.rightMoreButton.hidden = YES;
    } else {
        self.leftMoreButton.hidden = NO;
        self.rightMoreButton.hidden = NO;
    }
}

- (void) updateBoundsWithCurrentPage {
    NSInteger numberOfPages = ceil(self.contentSize.width / self.bounds.size.width);
    NSInteger lastPageRemainder = (NSInteger)self.contentSize.width % (NSInteger)self.bounds.size.width;
    
    if (self->currentPage == numberOfPages && lastPageRemainder > 0) {
        // assuming there is at least 1 page and contentSize.width >= bounds.size.width so that self->currentPage -1 -1 is >= 0
        self.bounds = CGRectMake(self.bounds.size.width * ((self->currentPage - 1) - 1) + lastPageRemainder, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    } else {
        self.bounds = CGRectMake(self.bounds.size.width * (self->currentPage - 1), self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    }
}

- (void) updateCurrentPageWithCurrentBounds {
    // NOTE: paging does not play nice with this function (if pages are not even, the last one will page to the last even page interval)
    self->currentPage = ceil(self.bounds.origin.x / self.bounds.size.width) + 1;  // add 1 for 0 index

}

- (void) dealloc {
    [fadingTitle release];
    [graph_ release];
    [graphView release];
    [graphOverlayView_ release];
    [leftMoreButton_ release];
    [rightMoreButton_ release];
    
    [super dealloc];
}
@end

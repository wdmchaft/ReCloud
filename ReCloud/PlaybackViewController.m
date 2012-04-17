//
//  PlaybackViewController.m
//  ReCloud
//
//  Created by hanl on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlaybackViewController.h"
#import "SquareSliderView.h"
#import "Constants.h"

@implementation PlaybackViewController

@synthesize sliderBackView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    
    SquareSliderView *squareView = [[SquareSliderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 50)];
    [sliderBackView addSubview:squareView];
    [squareView release];
}

- (void)viewDidUnload
{
    self.sliderBackView = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Instance Methods

-(IBAction) backAction:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DISMISS_PALYBACK_VIEW object:self];
}

@end

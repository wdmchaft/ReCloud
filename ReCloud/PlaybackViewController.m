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
@synthesize indexList;

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

-(void) dealloc{
    self.indexList = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SquareSliderView *squareView = [[SquareSliderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, 50)];
    [sliderBackView addSubview:squareView];
    [squareView release];
    
    NSMutableArray *newList = [[NSMutableArray alloc] init];
    [newList addObject:@""];
    [newList addObject:@""];
    self.indexList = newList;
    [newList release];
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

#pragma mark - UITableView DataSource Methods

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(indexList != nil){
        return indexList.count;
    }
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"playbackViewCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CustomCellView" owner:self options:nil] lastObject];
    }    
    
    return cell;
}

#pragma mark - UITableView Delegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

#pragma mark - Instance Methods

-(IBAction) backAction:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_DISMISS_VIEW_CONTROLLER object:self];
}

@end

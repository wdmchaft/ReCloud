//
//  MainViewController.m
//  ReCloud
//
//  Created by hanl on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"
#import "RecordingViewController.h"
#import "PlaybackViewController.h"
#import "Constants.h"

@implementation MainViewController

@synthesize audioList;


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
    self.audioList = nil;
    
    [super dealloc];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *newArr = [[NSMutableArray alloc] init];
    [newArr addObject:@""];
    [newArr addObject:@""];
    [newArr addObject:@""];
    self.audioList = newArr;
    [newArr release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissRecordingView:) name:NOTIFY_DISMISS_PALYBACK_VIEW object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if(audioList != nil){
        return audioList.count;
    }
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"mainViewCell";    
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

-(IBAction) toPlaybackView:(id)sender{    
    PlaybackViewController *playbackVC = [[PlaybackViewController alloc] init];
    [self presentModalViewController:playbackVC animated:YES];
    [playbackVC release];
}

#pragma mark - NSNotification Callback Methods

-(void) dismissRecordingView:(NSNotification *)notification{
    [self dismissModalViewControllerAnimated:YES];
}

@end

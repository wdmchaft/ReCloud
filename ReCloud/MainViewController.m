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
#import "MAlertView.h"
#import "Constants.h"
#import "AppDelegate.h"

@implementation MainViewController

@synthesize myTableView;
@synthesize editLabel;
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
    self.editLabel = nil;
    
    [super dealloc];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshAudioList];
    
    viewingLocal = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissRecordingView:) name:NOTIFY_DISMISS_VIEW_CONTROLLER object:nil];
    
}

- (void)viewDidUnload
{
    self.myTableView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"%s", __FUNCTION__);
        
        [audioList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];        

    }    
}

#pragma mark - UITableView Delegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PlaybackViewController *playbackVC = [[PlaybackViewController alloc] init];
    [self presentModalViewController:playbackVC animated:YES];
    [playbackVC release];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}



#pragma mark - Instance Methods

-(IBAction) toRecordingView:(id)sender{    
    editLabel.text = @"edit";
    [myTableView setEditing:NO animated:YES];
    
    RecordingViewController *recordingVC = [[RecordingViewController alloc] init];
    [self presentModalViewController:recordingVC animated:YES];
    [recordingVC release];
    
}

-(IBAction) editAction:(id)sender{    
    if([editLabel.text isEqualToString:@"edit"]){
        editLabel.text = @"done";
        
        [myTableView setEditing:YES animated:YES];
    }else{
        editLabel.text = @"edit";
        
        [myTableView setEditing:NO animated:YES];
    }
    
}

-(IBAction) loginAction:(id)sender{
    editLabel.text = @"edit";
    [myTableView setEditing:NO animated:YES];
    
    /*
    [audioList addObject:@""];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationMiddle];
     */
    
    MAlertView *alertView = [[MAlertView alloc] initWithTitle:@"" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView addTextField:[[[UITextField alloc] init] autorelease] placeHolder:@"Account"];
    [alertView addTextField:[[[UITextField alloc] init] autorelease] placeHolder:@"Password"];
    [alertView show];
    [alertView release];
    
}

-(IBAction) viewCloud:(id)sender{
    editLabel.text = @"edit";
    [myTableView setEditing:NO animated:YES];
    
    if(viewingLocal){
        //从云端下载数据
        
        NSMutableArray *newArr = [[NSMutableArray alloc] init];
        [newArr addObject:@""];
        [newArr addObject:@""];
        self.audioList = newArr;
        [newArr release];
        
        [myTableView reloadData];
        
        viewingLocal = NO;
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil 
                                                            message:@"请先登陆" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"知道了" 
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
    }
}

-(IBAction) viewLocal:(id)sender{
    editLabel.text = @"edit";
    [myTableView setEditing:NO animated:YES];
    
    if(!viewingLocal){        
        //浏览本地文件
        [self refreshAudioList];
        
        [myTableView reloadData];
        
        viewingLocal = YES;
    }
}

-(void) refreshAudioList{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSString *audiosPath = [[appDelegate documentPath] stringByAppendingPathComponent:AUDIO_DIR];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *arr = [fileManager contentsOfDirectoryAtPath:audiosPath error:nil];    
    NSMutableArray *newArr = [[NSMutableArray alloc] initWithArray:arr];
    self.audioList = newArr;
    [newArr release];
    
    NSLog(@"audioList count: %d", audioList.count);
}

#pragma mark - NSNotification Callback Methods

-(void) dismissRecordingView:(NSNotification *)notification{
    [self dismissModalViewControllerAnimated:YES];
}

@end

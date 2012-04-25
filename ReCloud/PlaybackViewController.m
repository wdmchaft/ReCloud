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
#import "AppDelegate.h"

@implementation PlaybackViewController

@synthesize sliderBackView;
@synthesize playButton;
@synthesize indexList;
@synthesize dataInfo;
@synthesize audioPlayer;

-(id) initWithAudioInfo:(NSDictionary *)info{
    self = [super init];
    if(self){
        self.dataInfo = info;
        return self;
    }
    return nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) dealloc{
    self.indexList = nil;
    self.dataInfo = nil;
    self.audioPlayer = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"%s", __FUNCTION__);
    
    [self initLayout];
    
    NSMutableArray *newList = [[NSMutableArray alloc] init];
    [newList addObject:@""];
    [newList addObject:@""];
    self.indexList = newList;
    
    NSLog(@"dataInfo: %@", dataInfo);
    [self addObserver:self forKeyPath:@"playing" options:0 context:NULL];
    playing = NO;
    
    [newList release];
}

- (void)viewDidUnload
{
    self.sliderBackView = nil;
    self.playButton = nil;
    
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
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CustomCellView" owner:self options:nil] objectAtIndex:0];
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

#pragma mark - KVO Callback Methods

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"playing"]){
        if(playing){
            [playButton setTitle:@"||" forState:UIControlStateNormal];
        }else{
            [playButton setTitle:@">" forState:UIControlStateNormal];
        } 
    } 
}

#pragma mark - AVAudioPlayer Delegate Methods

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self willChangeValueForKey:@"playing"];
    playing = NO;
    [self didChangeValueForKey:@"playing"];
}

#pragma mark - Instance Methods

-(void) backAction:(id)sender{
    [self removeObserver:self forKeyPath:@"playing" context:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) prevSection:(id)sender{
    
}

-(IBAction) playOrPause:(id)sender{
    BOOL flag;
    if(audioPlayer == nil){
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *filepath = [[[appDelegate documentPath] stringByAppendingPathComponent:AUDIO_DIR] stringByAppendingPathComponent:[dataInfo objectForKey:kFilename]];
        NSURL *newURL = [[NSURL alloc] initFileURLWithPath:filepath];
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:newURL error:nil];
        [newURL release];
        self.audioPlayer = newPlayer;
        [newPlayer release];
        [audioPlayer prepareToPlay];
        audioPlayer.delegate = self;
        [audioPlayer play];
        flag = YES;
    }else{
        if(playing){
            [audioPlayer pause]; 
            flag = NO;
        }else{
            [audioPlayer play];
            flag = YES;
        }            
    }
    
    [self willChangeValueForKey:@"playing"];
    playing = flag;
    [self didChangeValueForKey:@"playing"];
}

-(IBAction) addTag:(id)sender{
    
}

-(IBAction) stop:(id)sender{
    if(audioPlayer != nil){
        [audioPlayer stop];
        
        [self willChangeValueForKey:@"playing"];
        playing = NO;
        [self didChangeValueForKey:@"playing"];
    }
}

-(IBAction) nextSection:(id)sender{
    
}

-(void) initLayout{
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = buttonItem;
    [buttonItem release];
    
    UIBarButtonItem *buttonItem2 = [[UIBarButtonItem alloc] initWithTitle:@"upload" style:UIBarButtonItemStyleBordered target:self action:@selector(uploadAction:)];
    self.navigationItem.rightBarButtonItem = buttonItem2;
    [buttonItem2 release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = [dataInfo objectForKey:kTitle];
    self.navigationItem.titleView = titleLabel;
    
    SquareSliderView *squareView = [[SquareSliderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, sliderBackView.frame.size.height)];
    [sliderBackView addSubview:squareView];
    [squareView release];     
    
}

@end

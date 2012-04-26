//
//  PlaybackViewController.m
//  ReCloud
//
//  Created by hanl on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlaybackViewController.h"
#import "TagSliderView.h"
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
        NSMutableDictionary *newDict = [info mutableCopy];
        self.dataInfo = newDict;
        [newDict release];
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
    
    NSMutableArray *newArray = [[dataInfo objectForKey:kTag] mutableCopy];
    self.indexList = newArray;
    [newArray release];
    
    [self addObserver:self forKeyPath:@"playing" options:0 context:NULL];
    playing = NO;
    
    [self initLayout];
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
    NSDictionary *dict = [indexList objectAtIndex:indexPath.row];
    
    UILabel *countLabel = (UILabel *)[cell.contentView viewWithTag:TAG_COUNTLABEL];
    countLabel.text = [NSString stringWithFormat:@"%d", indexList.count - indexPath.row];
    
    UILabel *tagTimeLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TIMELABEL];
    tagTimeLabel.text = [dict objectForKey:kCurrentTime];
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TITLELABEL];
    titleLabel.text = [dict objectForKey:kTagTitle];
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [editButton setTitle:@"E" forState:UIControlStateNormal];
    editButton.frame = CGRectMake(240, 15, 35, 25);
    editButton.tag = BASE_TAG_EDIT_BUTTON2 + indexPath.row;
    [editButton addTarget:self action:@selector(editTag:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:editButton];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [deleteButton setTitle:@"D" forState:UIControlStateNormal];
    deleteButton.frame = CGRectMake(280, 15, 35, 25);
    deleteButton.tag = BASE_TAG_EDIT_BUTTON2 + indexPath.row;
    [deleteButton addTarget:self action:@selector(deleteTag:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:deleteButton];
    
    return cell;
}

#pragma mark - UITableView Delegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

#pragma mark - UINavigationController Delegate Methods

-(void) navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    NSInteger audioDuration = [TagSliderView durationForString:[dataInfo objectForKey:kDuration]];
    [tagSliderView setProgressStr:[dataInfo objectForKey:kDuration]];
    CGFloat viewWidth = tagSliderView.frame.size.width;    
    for(NSInteger i = 0; i < indexList.count; i++){
        NSDictionary *dict = [indexList objectAtIndex:i];
        NSString *tagTimeStr = [dict objectForKey:kCurrentTime];
        NSInteger timeTagged = [TagSliderView durationForString:tagTimeStr];
        
        UIView *tagView = [[[NSBundle mainBundle] loadNibNamed:@"TagView" owner:self options:nil] lastObject];
        CGRect rect = tagView.frame;
        rect.origin.x = (timeTagged * 1.0 / audioDuration) * viewWidth - rect.size.width / 2;
        tagView.frame = rect;
        
        UILabel *countLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_COUNTLABEL];
        countLabel.text = [NSString stringWithFormat:@"%d", indexList.count - i];
        
        UILabel *timeLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_TIMELABEL];
        timeLabel.text = tagTimeStr;
        
        [tagSliderView addTagView:tagView withFrame:tagView.frame];
        
    }    
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
    NSLog(@"3.playback retainCount:%d", [self retainCount]);
}

-(void) uploadAction:(id)sender{
    
}

-(IBAction) prevSection:(id)sender{
    
}

-(IBAction) nextSection:(id)sender{
    
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
        self.audioPlayer = nil;
        
        [self willChangeValueForKey:@"playing"];
        playing = NO;
        [self didChangeValueForKey:@"playing"];
    }
}

-(void) initLayout{
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = buttonItem;
    [buttonItem release];
    
    UIBarButtonItem *buttonItem2 = [[UIBarButtonItem alloc] initWithTitle:@"upload" style:UIBarButtonItemStyleBordered target:self action:@selector(uploadAction:)];
    self.navigationItem.rightBarButtonItem = buttonItem2;
    [buttonItem2 release];
    
    self.navigationItem.title = [dataInfo objectForKey:kTitle];
    
    tagSliderView = [[TagSliderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, sliderBackView.frame.size.height) andTimeStr:[dataInfo objectForKey:kDuration]];
    [sliderBackView addSubview:tagSliderView];
    [tagSliderView release];     
    
    self.navigationController.delegate = self;    
 
}

@end

//
//  RecordingViewController.m
//  ReCloud
//
//  Created by hanl on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RecordingViewController.h"
#import "AppDelegate.h"
#import "Constants.h"

@implementation RecordingViewController

@synthesize indexList;
@synthesize mRecorder;
@synthesize recordButton;

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
    self.mRecorder = nil;
    
    [super dealloc];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLayout];
    
    NSMutableArray *newList = [[NSMutableArray alloc] init];
    [newList addObject:@""];
    [newList addObject:@""];
    self.indexList = newList;
    [newList release];
    
    recording = NO;
}

- (void)viewDidUnload
{
    self.recordButton = nil;
    
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

#pragma mark - Instance Methods

-(void) recordOrPause:(id)sender{
    UIButton *clicked = (UIButton *)sender;
    
    if(mRecorder == nil){
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        audioSession.delegate = self;
        [audioSession setActive:YES error:nil];
        [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
        
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        timestamp = [[NSDate date] timeIntervalSince1970];
        NSString *filepath = [[[appDelegate documentPath] stringByAppendingPathComponent:AUDIO_DIR] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.pcm", timestamp]];   
        NSURL *newURL = [[NSURL alloc] initFileURLWithPath:filepath];
        NSDictionary *recordSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        [NSNumber numberWithFloat:44100.0], AVSampleRateKey, 
                                        [NSNumber numberWithInt:kAudioFormatAppleLossless], AVFormatIDKey,
                                        [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                        [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
                                        nil];
        AVAudioRecorder *newRecorder = [[AVAudioRecorder alloc] initWithURL:newURL settings:recordSettings error:nil];
        [newURL release];
        [recordSettings release];
        self.mRecorder = newRecorder;
        [newRecorder release];
        mRecorder.meteringEnabled = YES;
        mRecorder.delegate = self;
        [mRecorder prepareToRecord];
        [mRecorder record];
        
        recording = YES;
        [clicked setTitle:@"||" forState:UIControlStateNormal];
    }else{
        if(recording){
            [mRecorder pause];
            recording = NO;
            [clicked setTitle:@">" forState:UIControlStateNormal];
        }else{
            [mRecorder record];
            recording = YES;
            [clicked setTitle:@"||" forState:UIControlStateNormal];
        }
    }
}

-(void) stopRecording{
    [mRecorder stop];
    self.mRecorder = nil;
    recording = NO;
    [recordButton setTitle:@">" forState:UIControlStateNormal];
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}

-(void) backAction:(id)sender{
    [self stopRecording];
    
    NSString *filename = [[NSString alloc] initWithFormat:@"%ld.pcm", timestamp];
    
    NSString *defaultTitle = @"未命名";
    
    NSDate *newDate = [[NSDate alloc] initWithTimeIntervalSince1970:timestamp];
    NSArray *tmp = [newDate.description componentsSeparatedByString:@" "];
    NSString *tempDateStr = [tmp objectAtIndex:0];
    NSString *dateStr = [tempDateStr stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    NSString *timeStr = [[[tmp objectAtIndex:1] componentsSeparatedByString:@"+"] objectAtIndex:0];    
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSString *filepath = [[[appDelegate documentPath] stringByAppendingPathComponent:AUDIO_DIR] stringByAppendingPathComponent:filename];
    NSDictionary *dict = [[NSFileManager defaultManager] attributesOfItemAtPath:filepath error:nil];
    NSString *tempFileSizeStr  = [dict objectForKey:NSFileSize];
    float filesize = [tempFileSizeStr longLongValue] / 1000000.0;
    NSString *filesizeStr = [[NSString alloc] initWithFormat:@"%.2f", filesize];
    
    NSURL *newURL = [[NSURL alloc] initFileURLWithPath:filepath];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:newURL error:nil];
    [newURL release];
    NSString *durationStr = [self stringForDuration:player.duration];
    //NSLog(@"durationStr: %@", durationStr);
    
    NSArray *tagArr = [NSArray arrayWithObjects:@"123", @"213", @"2312", nil];
    NSDictionary *newDict = [[NSDictionary alloc] initWithObjectsAndKeys:dateStr, kDate, 
                                                                      timeStr, kTime, 
                                                                      defaultTitle, kTitle, 
                                                                      durationStr, kDuration, 
                                                                      filesizeStr, kSize, 
                                                                      filename, kFilename, 
                                                                      tagArr, kTag, nil];
    NSString *indexFilepath = [[[appDelegate documentPath] stringByAppendingPathComponent:INDEX_DIR] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.plist", timestamp]];
    [newDict writeToFile:indexFilepath atomically:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(NSString *) stringForDuration:(NSTimeInterval)duration{
    NSInteger temp = (NSInteger)duration;
    NSInteger hour =  temp / 3600;
    NSInteger remainder = temp % 3600;
    NSInteger minute = 0;
    NSInteger second = 0;
    if(remainder != 0){
        minute = remainder / 60;
        second = remainder % 60;
    }    
    NSString *result = [[NSString alloc] initWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    
    return [result autorelease];
}

-(void) initLayout{
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = buttonItem;
    [buttonItem release];
}

@end

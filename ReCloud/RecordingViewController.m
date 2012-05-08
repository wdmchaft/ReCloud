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

@synthesize tagList;
@synthesize mRecorder;
@synthesize recordButton;
@synthesize tagBackView;
@synthesize timingLabel;
@synthesize myTableView;

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
    self.tagList = nil;
    self.mRecorder = nil;
    
    [tagViews release];
    [idleList release];
    
    if(recordingTimer != nil){
        [recordingTimer invalidate];
        recordingTimer = nil;
    }
    if(sampleTimer != nil){
        [sampleTimer invalidate];
        sampleTimer = nil;
    } 
    if(idleTimer != nil){
        [idleTimer invalidate];
        idleTimer = nil;
    }
    
    refreshHeaderView = nil;
    
    [super dealloc];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *newList = [[NSMutableArray alloc] init];
    self.tagList = newList;
    [newList release];
    NSDictionary *tempDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"temp", kCurrentTime, @"temp", kTagTitle, nil];
    [tagList addObject:tempDict];   //开始加一个临时数据，使数据源不为空，从而一开始就可下拉TableView
    [tempDict release];    
    
    [self addObserver:self forKeyPath:@"recording" options:0 context:NULL];
    recording = NO;
    isIdle = NO;
    idleCount = 0;
    idleTime = -1.0f;
    tagViews = [[NSMutableArray alloc] init];
    idleList = [[NSMutableArray alloc] init];
    NSString *initIdlePoint = [[NSString alloc] initWithFormat:@"%f", 0.0f];
    [idleList addObject:initIdlePoint];
    [initIdlePoint release];
    
    [self sampleSurroundVoice];
    
    [self initLayout];
    
    if(refreshHeaderView == nil){
        EGORefreshTableHeaderView *headerView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - myTableView.bounds.size.height, self.view.frame.size.width, myTableView.bounds.size.height)];
        headerView.delegate = self;
        [myTableView addSubview:headerView];
        refreshHeaderView = headerView;
        [headerView release];
    }
    
    [refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewDidUnload
{
    self.recordButton = nil;
    self.tagBackView = nil;
    self.timingLabel = nil;
    self.myTableView = nil;
    refreshHeaderView = nil;

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
    if(tagList != nil && tagList.count > 0){
        //NSLog(@"%s", __FUNCTION__);
        return tagList.count;
    }
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s", __FUNCTION__);
    
    static NSString *cellIdentifier2 = @"playbackViewCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CustomCellView" owner:self options:nil] lastObject];
    }  
    
    if(tagList != nil && tagList.count > 0){
        if(indexPath.row == tagList.count - 1){
            cell.contentView.alpha = 0.0; //最后一行为填充行，无视！
        }else{
            cell.contentView.alpha = 1.0; 
        }        
        
        NSDictionary *dict = [tagList objectAtIndex:indexPath.row];
        
        UILabel *countLabel = (UILabel *)[cell.contentView viewWithTag:TAG_COUNTLABEL];
        countLabel.text = [NSString stringWithFormat:@"%d", tagList.count - indexPath.row - 1];
        
        UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TIMELABEL];
        timeLabel.text = [dict objectForKey:kCurrentTime];
        
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TITLELABEL];
        titleLabel.text = [dict objectForKey:kTagTitle];
        
        UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [editButton setTitle:@"E" forState:UIControlStateNormal];
        editButton.frame = CGRectMake(240, 15, 35, 25);
        editButton.tag = BASE_TAG_EDIT_BUTTON3 + indexPath.row;
        [editButton addTarget:self action:@selector(editTagTitle:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:editButton];
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [deleteButton setTitle:@"D" forState:UIControlStateNormal];
        deleteButton.frame = CGRectMake(280, 15, 35, 25);
        deleteButton.tag = BASE_TAG_DELETE_BUTTON3 + indexPath.row;
        [deleteButton addTarget:self action:@selector(deleteTag:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteButton];
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

#pragma mark - UIScrollViewDelegate Methods

-(void) scrollViewDidScroll:(UIScrollView *)scrollView{
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderView Delegate Methods

-(void) egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view{
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.05];
}

-(BOOL) egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view{
    return reloading;
}

-(NSDate *) egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view{
    return [NSDate date];
}

#pragma mark - KVO Callback Methods

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSLog(@"%s", __FUNCTION__);
    
    if([keyPath isEqualToString:@"recording"]){
        if(recording){
            [recordButton setTitle:@"||" forState:UIControlStateNormal];
            idleTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkingIdleState:) userInfo:nil repeats:YES];
        }else{
            [recordButton setTitle:@">" forState:UIControlStateNormal];
            [idleTimer invalidate];
            idleTimer = nil;
        }
    }
}

#pragma mark - NSTimer Callback Methods

-(void) timeRecording:(NSTimer *)timer{
    //NSLog(@"currentTime: %f", mRecorder.currentTime);    
    timingLabel.text = [self stringForDuration:mRecorder.currentTime];
    
    if(recording){
        if(tagViews != nil && tagViews.count > 0){
            
            for(int i = 0; i < tagViews.count; i++){
                UIView *tagView = [tagViews objectAtIndex:i];                
                CGRect rect = tagView.frame;
                if(rect.origin.x > 0){
                    rect.origin.x = rect.origin.x - 2.0 / log10(mRecorder.currentTime + 1);
                }
                tagView.frame = rect;                
            }            
        }
    }
}

-(void) pickSampleVoice:(NSTimer *)timer{
    if(sampleCount < 30){
        [mRecorder updateMeters];
        NSLog(@"sampling: %f", [mRecorder peakPowerForChannel:0]);
        totalSamplePeak += [mRecorder peakPowerForChannel:0];
        sampleCount++;
    }else{
        [sampleTimer invalidate];
        sampleTimer = nil;
        [mRecorder stop];
        self.mRecorder = nil;
        
        averageSamplePeak = totalSamplePeak / sampleCount;
        NSLog(@"averageSamplePeak: %f", averageSamplePeak);
        
        [self cancelWaitingView];
    }
}

-(void) checkingIdleState:(NSTimer *)timer{
    [mRecorder updateMeters];
    
    NSLog(@"current peak: %f, idle: %d", [mRecorder peakPowerForChannel:0], isIdle);
    
    if([mRecorder peakPowerForChannel:0] <= averageSamplePeak){       
        idleCount++;
        if(idleCount >= 15){   //空白时间超过1.5秒即判断为断句
            isIdle = YES;
        }
    }else{
        if(isIdle){
            idleTime = mRecorder.currentTime;
            isIdle = NO;
            
            NSString *idlePoint = [[NSString alloc] initWithFormat:@"%f", idleTime];
            [idleList addObject:idlePoint];
            [idlePoint release];
        }
        idleCount = 0;
        idleTime = -1.0f;
    }
}


#pragma mark - UIView Animation Callback Methods

-(void) removeEditingView{
    [editingView removeFromSuperview];
    editingView = nil;
}

-(void) removeWaitingView{
    [waitingView removeFromSuperview];
    waitingView = nil;
    
    [self recordOrPause:nil];   //取样后马上开始录音
}

-(void) removeTagView{
    UIView *deletingTagView = [tagViews objectAtIndex:deletingIndex]; 
    [deletingTagView removeFromSuperview];
    [tagViews removeObjectAtIndex:deletingIndex];
    deletingTagView = nil;
}


#pragma mark - Instance Methods

-(void) recordOrPause:(id)sender{
    BOOL flag;
    
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
        flag = YES;
        
        recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeRecording:) userInfo:nil repeats:YES];

    }else{
        if(recording){
            [mRecorder pause];
            flag = NO;
    }else{
            [mRecorder record];
            flag = YES;
        }
    }
    
    [self willChangeValueForKey:@"recording"];
    recording = flag;
    [self didChangeValueForKey:@"recording"];
}

-(void) stopRecording{
    if(mRecorder != nil){
        [recordingTimer invalidate];
        recordingTimer = nil;
        if(idleTimer != nil){
            [idleTimer invalidate];
            idleTimer = nil;
        }
        
        [mRecorder stop];
        self.mRecorder = nil;
        [self willChangeValueForKey:@"recording"];
        recording = NO;
        [self didChangeValueForKey:@"recording"];    
        
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        [self writeAudioIndexToFile];
    }
}

-(void) backAction:(id)sender{
    [self stopRecording];
    [self removeObserver:self forKeyPath:@"recording"];    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) editTagTitle:(id)sender{
    UIButton *clicked = (UIButton *)sender;
    editingIndex = clicked.tag - BASE_TAG_EDIT_BUTTON3;
    UITableViewCell *editingCell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:editingIndex inSection:0]];
    UILabel *titleLabel = (UILabel *)[editingCell.contentView viewWithTag:TAG_TITLELABEL];
    
    editingView = [[[NSBundle mainBundle] loadNibNamed:@"EditingView" owner:self options:nil] lastObject];
    editingView.alpha = 0;
    editingView.frame = CGRectMake(0.0, 20.0, editingView.frame.size.width, editingView.frame.size.height);
    
    UITextView *textView = (UITextView *)[editingView viewWithTag:TAG_EDITVIEW_TEXTVIEW];
    textView.text = titleLabel.text;
    [textView becomeFirstResponder];
    
    UIButton *okButton = (UIButton *)[editingView viewWithTag:TAG_EDITVIEW_OK_BUTTON];
    [okButton addTarget:self action:@selector(confirmEditing:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelButton = (UIButton *)[editingView viewWithTag:TAG_EDITVIEW_CANCEL_BUTTON];
    [cancelButton addTarget:self action:@selector(cancelEditing:) forControlEvents:UIControlEventTouchUpInside];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window addSubview:editingView];
    [UIView animateWithDuration:0.5 animations:^{
        editingView.alpha = 1.0;
    }];
}

-(void) cancelEditing:(id)sender{
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeEditingView)];
    editingView.alpha = 0.0;
    [UIView commitAnimations];
}

-(void) confirmEditing:(id)sender{
    UITableViewCell *editingCell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:editingIndex inSection:0]];
    UILabel *titleLabel = (UILabel *)[editingCell.contentView viewWithTag:TAG_TITLELABEL];
    UITextView *textView = (UITextView *)[editingView viewWithTag:TAG_EDITVIEW_TEXTVIEW];
    titleLabel.text = textView.text;
    [textView resignFirstResponder];
    
    NSMutableDictionary *dict = [[tagList objectAtIndex:editingIndex] mutableCopy];
    [dict setObject:textView.text forKey:kTagTitle];    
    [tagList replaceObjectAtIndex:editingIndex withObject:dict];
    [dict release];
    
    [self cancelEditing:nil];
}

-(void) deleteTag:(id)sender{      
    UIButton *clicked = (UIButton *)sender;
    deletingIndex = clicked.tag - BASE_TAG_DELETE_BUTTON3;    
    NSLog(@"deletingIndex:%d", deletingIndex);
    
    //更新数据源
    [tagList removeObjectAtIndex:deletingIndex];
    
    //刷新列表视图
    [myTableView beginUpdates];
    [myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:deletingIndex inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    [myTableView endUpdates];
    
    [myTableView beginUpdates];        
    NSMutableArray *rowIndexPaths = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < tagList.count; i++){
        if(i != deletingIndex){
            NSIndexPath *temp = [NSIndexPath indexPathForRow:i inSection:0];
            [rowIndexPaths addObject:temp];
        }
    }
    [myTableView reloadRowsAtIndexPaths:rowIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [myTableView endUpdates];  
    [rowIndexPaths release];
    
    //删除浮标
    [self deleteTagViewAtIndex:deletingIndex];   
    
    //刷新浮标序号
    for(NSInteger i = 0; i < deletingIndex; i++){        
        UIView *tagView = [tagViews objectAtIndex:i];
        UILabel *countLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_COUNTLABEL];
        countLabel.text = [NSString stringWithFormat:@"%d", tagViews.count - 1 - i];
    }
    
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

-(IBAction) tagForTime:(id)sender{
    if(recording){
        
        //更新数据源
        NSString *currentTimeStr = [self stringForDuration:mRecorder.currentTime];
        NSDictionary *newDict = [[NSDictionary alloc] initWithObjectsAndKeys:currentTimeStr, kCurrentTime, @"未命名", kTagTitle, nil];  
        [tagList insertObject:newDict atIndex:0];
        [newDict release];
        
        //增加TagView
        [self addTagView];
        
        //更新列表视图
        [myTableView beginUpdates];
        [myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        [myTableView endUpdates];
        
        [myTableView beginUpdates];        
        NSMutableArray *rowIndexPaths = [[NSMutableArray alloc] init];
        for(NSInteger i = 1; i < tagList.count; i++){
            NSIndexPath *temp = [NSIndexPath indexPathForRow:i inSection:0];
            [rowIndexPaths addObject:temp];
        }
        [myTableView reloadRowsAtIndexPaths:rowIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        [myTableView endUpdates];   
        [rowIndexPaths release];
    }
}

-(void) addTagView{
    UIView *tagView = [[[NSBundle mainBundle] loadNibNamed:@"TagView" owner:self options:nil] lastObject];
    tagView.alpha = 0;
    tagView.frame = CGRectMake([UIScreen mainScreen].applicationFrame.size.width - tagView.frame.size.width / 2, 0, tagView.frame.size.width, tagView.frame.size.height);
    [tagViews insertObject:tagView atIndex:0];
    
    UILabel *countLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_COUNTLABEL];
    countLabel.text = [NSString stringWithFormat:@"%d", tagList.count - 1];
    
    UILabel *timeLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_TIMELABEL];
    timeLabel.text = [[tagList objectAtIndex:0] objectForKey:kCurrentTime];  //最新的在列表最前位置
    
    [tagBackView addSubview:tagView];
    
    [UIView animateWithDuration:0.5 animations:^{
        tagView.alpha = 1.0;
    }];
    
}

-(void) writeAudioIndexToFile{
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
    [player release];
    
    //注意tagList最后一项为临时占位项，要排除
    NSMutableArray *newArr = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < tagList.count - 1; i++){
        [newArr addObject:[tagList objectAtIndex:i]];
    }
    
    NSLog(@"idleList: %@", idleList);
    
    NSDictionary *newDict = [[NSDictionary alloc] initWithObjectsAndKeys:dateStr, kDate, 
                             timeStr, kTime, 
                             defaultTitle, kTitle, 
                             durationStr, kDuration, 
                             filesizeStr, kSize, 
                             filename, kFilename,
                             idleList, kIdleTime,
                             newArr, kTag, nil];
    NSString *indexFilepath = [[[appDelegate documentPath] stringByAppendingPathComponent:INDEX_DIR] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.plist", timestamp]];
    [newDict writeToFile:indexFilepath atomically:YES];
    [newArr release];
}

-(void) doneLoadingTableViewData{
    reloading = NO;
    [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:myTableView];
}

-(void) reloadTableViewDataSource{
    reloading = YES;
    [self tagForTime:nil];
}

-(void) sampleSurroundVoice{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    audioSession.delegate = self;
    [audioSession setActive:YES error:nil];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSString *filepath = [[[appDelegate documentPath] stringByAppendingPathComponent:SAMPLE_DIR] stringByAppendingPathComponent:@"sample.pcm"];   
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
    sampleCount = 0;
    
    sampleTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(pickSampleVoice:) userInfo:nil repeats:YES];  
    
    [self showWaitingView];
}

-(void) showWaitingView{
    waitingView = [[[NSBundle mainBundle] loadNibNamed:@"WaitingView" owner:self options:nil] lastObject];
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    waitingView.frame = CGRectMake(0, 20, waitingView.frame.size.width, waitingView.frame.size.height);
    waitingView.alpha = 0.0;
    UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[waitingView viewWithTag:TAG_WAITINGVIEW_ACTIVITY_INDICATOR];
    [indicator startAnimating];
    [appDelegate.window addSubview:waitingView];
    
    [UIView animateWithDuration:0.3 animations:^{
        waitingView.alpha = 1.0;
    }];
}

-(void) cancelWaitingView{
    if(waitingView != nil){
        UIActivityIndicatorView *indicator = (UIActivityIndicatorView *)[waitingView viewWithTag:TAG_WAITINGVIEW_ACTIVITY_INDICATOR];
        [indicator stopAnimating];
        
        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeWaitingView)];
        waitingView.alpha = 0.0;
        [UIView commitAnimations];
    }
}

-(void) deleteTagViewAtIndex:(NSInteger)index{
    UIView *deletingTagView = [tagViews objectAtIndex:index];    
    
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeTagView)];
    deletingTagView.alpha = 0.0;
    [UIView commitAnimations];
}

@end

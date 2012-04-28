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
@synthesize myTableView;
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
    
    if(progressTimer != nil){
        [progressTimer invalidate];
        progressTimer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    didEdit = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slide:) name:NOTIFY_WILL_SLIDE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneSliding:) name:NOTIFY_END_SLIDE object:nil];
    
    [self initLayout];
}

- (void)viewDidUnload
{
    self.sliderBackView = nil;
    self.playButton = nil;
    self.myTableView = nil;
    
    if(progressTimer != nil){
        [progressTimer invalidate];
        progressTimer = nil;
    }
    
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
    if(indexList != nil && indexList.count > 0){
        return indexList.count;
    }
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier1 = @"playbackViewCell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
    if(cell == nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CustomCellView" owner:self options:nil] lastObject];
    }    
    
    if(indexList != nil && indexList.count > 0){
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
        [editButton addTarget:self action:@selector(editTagTitle:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:editButton];
        
        UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [deleteButton setTitle:@"D" forState:UIControlStateNormal];
        deleteButton.frame = CGRectMake(280, 15, 35, 25);
        deleteButton.tag = BASE_TAG_DELETE_BUTTON2 + indexPath.row;
        [deleteButton addTarget:self action:@selector(deleteTag:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:deleteButton];
        
    }
    
    return cell;
}

#pragma mark - UITableView Delegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary *dict = [indexList objectAtIndex:indexPath.row];
    [tagSliderView setProgressForTimeStr:[dict objectForKey:kCurrentTime]];
    if(playing){
        audioPlayer.currentTime = tagSliderView.progress * audioPlayer.duration;
    }
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

#pragma mark - UINavigationController Delegate Methods

-(void) navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSLog(@"%s", __FUNCTION__);
    
    NSInteger audioDuration = [TagSliderView durationForString:[dataInfo objectForKey:kDuration]];
    CGFloat viewWidth = tagSliderView.frame.size.width;    
    for(NSInteger i = 0; i < indexList.count; i++){
        NSDictionary *dict = [indexList objectAtIndex:i];
        NSString *tagTimeStr = [dict objectForKey:kCurrentTime];
        NSInteger timeTagged = [TagSliderView durationForString:tagTimeStr];
        
        UIView *tagView = [[[NSBundle mainBundle] loadNibNamed:@"TagView" owner:self options:nil] lastObject];
        CGRect rect = tagView.frame;
        rect.origin.x = (timeTagged * 1.0 / audioDuration) * viewWidth - rect.size.width / 2;
        tagView.frame = rect;
        tagView.tag = BASE_TAG_PLAYBACK_TAGVIEW + i;
        
        UILabel *countLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_COUNTLABEL];
        countLabel.text = [NSString stringWithFormat:@"%d", indexList.count - i];
        
        UILabel *timeLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_TIMELABEL];
        timeLabel.text = tagTimeStr;
        
        [tagSliderView addTagView:tagView];
        
    }  
    
    self.view.userInteractionEnabled = YES;
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

#pragma mark - NSTimer Callback Methods
 
-(void) updateProgress:(NSTimer *)timer{
    if(audioPlayer != nil && playing){
        
        [tagSliderView setProgress:audioPlayer.currentTime / audioPlayer.duration];
    }
}

#pragma mark - NSNotification Callback Methods

-(void) slide:(NSNotification *)notification{
    if(audioPlayer != nil){
        if(playing){
            [audioPlayer pause];
            [self willChangeValueForKey:@"playing"];
            playing = NO;
            [self didChangeValueForKey:@"playing"];
        }
    }
}

-(void) doneSliding:(NSNotification *)notification{
    if(audioPlayer != nil){
        if(!playing){
            audioPlayer.currentTime = tagSliderView.progress * audioPlayer.duration;        
            [audioPlayer play];
            [self willChangeValueForKey:@"playing"];
            playing = YES;
            [self didChangeValueForKey:@"playing"];
        }
    }
}

#pragma mark - Animation Callback Meethods

-(void) removeEditingView{
    [editingView removeFromSuperview];
    editingView = nil;
}

#pragma mark - Instance Methods

-(void) backAction:(id)sender{
    [self stop:nil];
    
    [self removeObserver:self forKeyPath:@"playing"];
    
    if(didEdit){
        [dataInfo setObject:indexList forKey:kTag];
        
        NSString *temp = [[[dataInfo objectForKey:kFilename] componentsSeparatedByString:@"."] objectAtIndex:0];
        NSString *filename = [NSString stringWithFormat:@"%@.plist", temp];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *filePath = [[[appDelegate documentPath] stringByAppendingPathComponent:INDEX_DIR] stringByAppendingPathComponent:filename];
        [dataInfo writeToFile:filePath atomically:YES];
    } 
    
    [self.navigationController popViewControllerAnimated:YES];
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
        
        [tagSliderView setProgressForTimeStr:@"00:00:00"];
        progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
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
    //float currentTime = tagSliderView.progress * [TagSliderView durationForString:[dataInfo objectForKey:kDuration]];
    //NSString *currentTimeStr = [NSString stringWithFormat:@"%@", [TagSliderView stringForDuration:currentTime]];
    
    //更新数据源
    NSDictionary *newDict = [[NSDictionary alloc] initWithObjectsAndKeys:tagSliderView.currentTimeStr, kCurrentTime, @"未命名", kTagTitle, nil];
    [indexList insertObject:newDict atIndex:0];
    [newDict release];
    
    //插入标记视图
    UIView *tagView = [[[NSBundle mainBundle] loadNibNamed:@"TagView" owner:self options:nil] lastObject];
    
    UILabel *tagCountLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_COUNTLABEL];
    tagCountLabel.text = [NSString stringWithFormat:@"%d", indexList.count];
    
    UILabel *tagTimeLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_TIMELABEL];
    tagTimeLabel.text = [NSString stringWithFormat:@"%@", tagSliderView.currentTimeStr];
    
    CGRect rect = tagView.frame;
    rect.origin.x = tagSliderView.frame.size.width * tagSliderView.progress - rect.size.width / 2;
    tagView.frame = rect;
    tagView.tag = BASE_TAG_PLAYBACK_TAGVIEW + indexList.count;
    [tagSliderView addTagView:tagView];    
    
    //刷新列表视图
    [myTableView beginUpdates];
    [myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    [myTableView endUpdates];
    
    [myTableView beginUpdates];        
    NSMutableArray *rowIndexPaths = [[NSMutableArray alloc] init];
    for(NSInteger i = 1; i < indexList.count; i++){
        NSIndexPath *temp = [NSIndexPath indexPathForRow:i inSection:0];
        [rowIndexPaths addObject:temp];
    }
    [myTableView reloadRowsAtIndexPaths:rowIndexPaths withRowAnimation:UITableViewRowAnimationNone];
    [myTableView endUpdates];   
    [rowIndexPaths release];
    
    didEdit = YES;
}

-(IBAction) stop:(id)sender{
    if(audioPlayer != nil){
        [audioPlayer stop];
        self.audioPlayer = nil;
        
        [progressTimer invalidate];
        progressTimer = nil;
        
        [self willChangeValueForKey:@"playing"];
        playing = NO;
        [self didChangeValueForKey:@"playing"];
    }
}

-(void) initLayout{
    self.view.userInteractionEnabled = NO;
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = buttonItem;
    [buttonItem release];
    
    UIBarButtonItem *buttonItem2 = [[UIBarButtonItem alloc] initWithTitle:@"upload" style:UIBarButtonItemStyleBordered target:self action:@selector(uploadAction:)];
    self.navigationItem.rightBarButtonItem = buttonItem2;
    [buttonItem2 release];
    
    self.navigationItem.title = [dataInfo objectForKey:kTitle];
    
    tagSliderView = [[TagSliderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, sliderBackView.frame.size.height) andTotalTimeStr:[dataInfo objectForKey:kDuration]];
    [sliderBackView addSubview:tagSliderView];
    [tagSliderView release];     
    
    self.navigationController.delegate = self;    
 
}

-(void) editTagTitle:(id)sender{
    UIButton *clicked = (UIButton *)sender;
    editingIndex = clicked.tag - BASE_TAG_EDIT_BUTTON2;
    
    NSLog(@"editingIndex: %d", editingIndex);
    
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
    
    NSMutableDictionary *dict = [[indexList objectAtIndex:editingIndex] mutableCopy];
    [dict setObject:textView.text forKey:kTagTitle];    
    [indexList replaceObjectAtIndex:editingIndex withObject:dict];
    [dict release];

    //[dataInfo setObject:indexList forKey:kTag];
    
    didEdit = YES;
    [self cancelEditing:nil];
}

-(void) deleteTag:(id)sender{
    didEdit = YES;
}

@end

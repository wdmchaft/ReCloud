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
@synthesize playButton, prevButton, nextButton, addTagButton;
@synthesize myTableView;
@synthesize tableBackView;
@synthesize indexList;
@synthesize dataInfo;
@synthesize audioPlayer;
@synthesize idleList;

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
    self.idleList = nil;
    [editingButtons release];
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
    
    NSMutableArray *newArray1 = [[dataInfo objectForKey:kIdleTime] mutableCopy];
    self.idleList = newArray1;
    [newArray1 release];
    
    NSLog(@"dataInfo: %@, idleList: %@", dataInfo, idleList);
    
    [self addObserver:self forKeyPath:@"playing" options:0 context:NULL];
    playing = NO;
    didEdit = NO;
    hightlightedIndex = -1;
    lastSelectedIndex = -1;
    idleIndex = 0;
    currentOrientation = UIInterfaceOrientationPortrait;
    editingButtons = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willSlide:) name:NOTIFY_WILL_SLIDE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneSliding:) name:NOTIFY_END_SLIDE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sliding:) name:NOTIFY_SLIDING object:nil];
    
    [self initLayout];
}

- (void)viewDidUnload
{
    self.sliderBackView = nil;
    self.playButton = nil;
    self.prevButton = nil;
    self.nextButton = nil;
    self.addTagButton = nil;
    self.myTableView = nil;
    self.tableBackView = nil;
    
    if(progressTimer != nil){
        [progressTimer invalidate];
        progressTimer = nil;
    }
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    NSLog(@"%s, orientation: %d, device_orientation: %d", __FUNCTION__, toInterfaceOrientation, [[UIDevice currentDevice] orientation]);
    
    currentOrientation = toInterfaceOrientation;
    
    if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        [self portraitView];
    }else{
        [self landscapeView];
    }
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(indexList != nil && indexList.count > 0){
        NSDictionary *dict = [indexList objectAtIndex:indexPath.row];
        
        UILabel *countLabel = (UILabel *)[cell.contentView viewWithTag:TAG_COUNTLABEL];
        countLabel.text = [NSString stringWithFormat:@"%d", indexList.count - indexPath.row];
        
        UILabel *tagTimeLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TIMELABEL];
        tagTimeLabel.text = [dict objectForKey:kCurrentTime];
        
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:TAG_TITLELABEL];
        titleLabel.text = [dict objectForKey:kTagTitle];        
        
        UIButton *editingBtn = (UIButton *)[cell.contentView viewWithTag:TAG_EDITING_BUTTON2];
        CGRect rect1 = editingBtn.frame;
        if(currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown){
            rect1.origin.x = 274;
        }else{
            rect1.origin.x = 434;
        }
        editingBtn.frame = rect1;
        [editingBtn addTarget:self action:@selector(editTagTitle:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *deletingBtn = (UIButton *)[cell.contentView viewWithTag:TAG_DELETING_BUTTON2];
        CGRect rect2 = deletingBtn.frame;
        rect2.origin.x = tableView.frame.size.width * 5.0f / 8;
        deletingBtn.frame = rect2;
        [deletingBtn addTarget:self action:@selector(deleteTag:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImageView *cellBg = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL_BG];
        CGRect rect3 = cellBg.frame;
        rect3.size.width = tableView.frame.size.width;
        cellBg.frame = rect3;
        
        UIImageView *hoverView = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
        CGRect rect4 = hoverView.frame;
        rect4.size.width = tableView.frame.size.width;
        hoverView.frame = rect4;
        if(lastSelectedIndex == indexPath.row){
            hoverView.alpha = 1.0;
        }else{
            hoverView.alpha = 0.0;
        }
    }
    
    return cell;
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
        NSLog(@"deleteIndextRow: %d", indexPath.row);
        
        deletingIndex = indexPath.row;
        [self deleteTag:nil];
    }    
}

#pragma mark - UITableView Delegate Methods

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *hoverView = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
    hoverView.alpha = 1.0;   
    
    NSLog(@"lastSelectedIndex: %d", lastSelectedIndex);
    
    if(lastSelectedIndex >= 0 && lastSelectedIndex != indexPath.row){
        NSIndexPath *lastPath = [NSIndexPath indexPathForRow:lastSelectedIndex inSection:0];
        UITableViewCell *lastSelectedCell = [tableView cellForRowAtIndexPath:lastPath];
        UIImageView *hoverView = (UIImageView *)[lastSelectedCell.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
        hoverView.alpha = 0.0;        
    }
    lastSelectedIndex = indexPath.row;  
    
    NSDictionary *dict = [indexList objectAtIndex:indexPath.row];
    float duration = [TagSliderView durationForString:[dataInfo objectForKey:kDuration]];
    float currentTime = [TagSliderView durationForString:[dict objectForKey:kCurrentTime]];
    [tagSliderView setProgress:currentTime / duration];
    
    if(playing){
        audioPlayer.currentTime = tagSliderView.progress * audioPlayer.duration;
    }    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49;
}

-(NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
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
        rect.origin.y = 0;
        tagView.frame = rect;
        
        UILabel *countLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_COUNTLABEL];
        countLabel.text = [NSString stringWithFormat:@"%d", indexList.count - i];
        
        UILabel *timeLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_TIMELABEL];
        timeLabel.text = tagTimeStr;
        timeLabel.hidden = YES;
        
        [tagSliderView addTagView:tagView];
        [tagSliderView.positionPercentage addObject:[NSNumber numberWithFloat:timeTagged * 1.0f / audioDuration]];
        
    }  
    
    self.view.userInteractionEnabled = YES;
}

#pragma mark - KVO Callback Methods

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"playing"]){
        if(playing){
            if(currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown){
                [playButton setImage:[UIImage imageNamed:@"button_pause.png"] forState:UIControlStateNormal];
            }else{
                [playButton setImage:[UIImage imageNamed:@"button_pause_h.png"] forState:UIControlStateNormal];
            }
        }else{
            if(currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown){
                [playButton setImage:[UIImage imageNamed:@"button_play.png"] forState:UIControlStateNormal];
            }else{
                [playButton setImage:[UIImage imageNamed:@"button_play_h.png"] forState:UIControlStateNormal];
            }
        } 
    } 
}

#pragma mark - AVAudioPlayer Delegate Methods

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self stop:nil];
}

#pragma mark - NSTimer Callback Methods
 
-(void) updateProgress:(NSTimer *)timer{
    if(audioPlayer != nil && playing){        
        
        float progress = audioPlayer.currentTime / audioPlayer.duration;        
        [tagSliderView setProgress:progress];
        
        NSInteger found = -1;
        for(NSInteger i = 0; i < tagSliderView.tagViews.count; i++){            
            UIView *tagView = [tagSliderView.tagViews objectAtIndex:tagSliderView.tagViews.count - 1 - i];
            if(tagSliderView.frame.size.width * progress >= (tagView.frame.origin.x + tagView.frame.size.width / 2)){                
                found = i;
            }else{
                break;
            }
        }
        
        NSLog(@"lastSelectedIndex: %d", lastSelectedIndex);
        
        if(found != -1){
            if(lastSelectedIndex != indexList.count - 1 - found){
                //[myTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(indexList.count - 1 - found) inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
                
                UITableViewCell *cell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexList.count - 1 - found) inSection:0]];
                UIImageView *hoverView = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
                hoverView.alpha = 1.0;
                
                if(lastSelectedIndex >= 0){
                    UITableViewCell *lastSeletedCell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedIndex inSection:0]];
                    UIImageView *lastHoverView = (UIImageView *)[lastSeletedCell.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
                    lastHoverView.alpha = 0.0;
                }               
                lastSelectedIndex = indexList.count - 1 - found;
            }
        }else{
            /*
            for(NSInteger i = 0; i < indexList.count; i++){
                [myTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO];

            }    
            */
            
            if(lastSelectedIndex >= 0){
                UITableViewCell *cell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedIndex inSection:0]];
                UIImageView *hoverView = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
                hoverView.alpha = 0.0;
                
                lastSelectedIndex = -1;
            }            
        }
        
        hightlightedIndex = found;
    }
}

#pragma mark - NSNotification Callback Methods

-(void) willSlide:(NSNotification *)notification{
    if(audioPlayer != nil){
        if(playing){
            [audioPlayer pause];
            [self willChangeValueForKey:@"playing"];
            playing = NO;
            [self didChangeValueForKey:@"playing"];
        }
    }
    
    NSDictionary *dict = [notification userInfo];
    float x = [(NSNumber *)[dict objectForKey:kSliderViewBlockXpos] floatValue];
    
    NSInteger found = -1;
    for(NSInteger i = 0; i < indexList.count; i++){
        UIView *tagView = [tagSliderView.tagViews objectAtIndex:indexList.count - 1 - i];
        if(x >= tagView.frame.origin.x + tagView.frame.size.width / 2){ 
            found = i;
        }else{
            break;
        }        
    }
    
    NSLog(@"found: %d, lastSelectedIndex: %d", found, lastSelectedIndex);
    if(found != -1){
        if(lastSelectedIndex != indexList.count - 1 - found){            
            UITableViewCell *cell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexList.count - 1 - found) inSection:0]];
            UIImageView *hoverView = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
            hoverView.alpha = 1.0;
            
            if(lastSelectedIndex >= 0){
                UITableViewCell *lastSeletedCell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedIndex inSection:0]];
                UIImageView *lastHoverView = (UIImageView *)[lastSeletedCell.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
                lastHoverView.alpha = 0.0;
            }            
            lastSelectedIndex = indexList.count - 1 - found;
        }
    }else{
        if(lastSelectedIndex >= 0){
            UITableViewCell *cell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedIndex inSection:0]];
            UIImageView *hoverView = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
            hoverView.alpha = 0.0;
            
            lastSelectedIndex = -1;
        }        
    }
    
    hightlightedIndex = found;
}

-(void) sliding:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    float x = [(NSNumber *)[dict objectForKey:kSliderViewBlockXpos] floatValue];
    
    NSInteger found = -1;
    for(NSInteger i = 0; i < indexList.count; i++){
        UIView *tagView = [tagSliderView.tagViews objectAtIndex:indexList.count - 1 - i];
        if(x >= tagView.frame.origin.x + tagView.frame.size.width / 2){ 
            found = i;
        }else{
            break;
        }        
    }
    
    NSLog(@"found: %d", found);
    if(found != -1){
        if(lastSelectedIndex != indexList.count - 1 - found){            
            UITableViewCell *cell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:(indexList.count - 1 - found) inSection:0]];
            UIImageView *hoverView = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
            hoverView.alpha = 1.0;
            
            if(lastSelectedIndex >= 0){
                UITableViewCell *lastSeletedCell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedIndex inSection:0]];
                UIImageView *lastHoverView = (UIImageView *)[lastSeletedCell.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
                lastHoverView.alpha = 0.0;
            }            
            lastSelectedIndex = indexList.count - 1 - found;
        }
    }else{
        if(lastSelectedIndex >= 0){
            UITableViewCell *cell = [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedIndex inSection:0]];
            UIImageView *hoverView = (UIImageView *)[cell.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
            hoverView.alpha = 0.0;
            
            lastSelectedIndex = -1;
        }        
    }
    
    hightlightedIndex = found;
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

-(void) removeSingleTagView{
    UIView *deleteTagView = [tagSliderView.tagViews objectAtIndex:deletingIndex];
    [deleteTagView removeFromSuperview];
    [tagSliderView.tagViews removeObjectAtIndex:deletingIndex];
    [tagSliderView.positionPercentage removeObjectAtIndex:deletingIndex];
    deleteTagView = nil;
}

-(void) willRemoveOverlayView{
    [self performSelector:@selector(cancelOverlayView) withObject:nil afterDelay:1.0];
}

-(void) removeOverlayView{
    [overlayView removeFromSuperview];
    overlayView = nil;
}

#pragma mark - Instance Methods

-(void) backAction:(id)sender{
    [self stop:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if(audioPlayer != nil){
        if(idleIndex == 0){
            [self showOverlayViewWithMessage:@"列表为空"];
            return;
        }
        
        idleIndex--;
        float idlePoint = [[idleList objectAtIndex:idleIndex] floatValue];
        [tagSliderView setProgress:idlePoint / audioPlayer.duration];
        self.audioPlayer.currentTime = idlePoint;
    }   
    
}

-(IBAction) nextSection:(id)sender{
    if(audioPlayer != nil){
        if(idleIndex == idleList.count - 1){
            [self showOverlayViewWithMessage:@"列表为空"];
            return;
        }        
        idleIndex++;
        float idlePoint = [[idleList objectAtIndex:idleIndex] floatValue];
        [tagSliderView setProgress:idlePoint / audioPlayer.duration];
        self.audioPlayer.currentTime = idlePoint;
    }

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
        hightlightedIndex = -1;
        
        [tagSliderView setProgress:0.0];
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
    
    BOOL tagExist = NO;
    for(NSDictionary *dict in indexList){
        NSString *timeStr = [dict objectForKey:kCurrentTime];
        if([tagSliderView.currentTimeStr isEqualToString:timeStr]){
            tagExist = YES;
            break;
        }
    }
    
    if(!tagExist){
        //更新数据源
        NSDictionary *newDict = [[NSDictionary alloc] initWithObjectsAndKeys:tagSliderView.currentTimeStr, kCurrentTime, @"未命名", kTagTitle, nil];
        [indexList insertObject:newDict atIndex:indexList.count - 1 - hightlightedIndex];
        [newDict release];    
        
        //插入标记视图
        UIView *newTagView = [[[NSBundle mainBundle] loadNibNamed:@"TagView" owner:self options:nil] lastObject];
        
        UILabel *tagCountLabel = (UILabel *)[newTagView viewWithTag:TAG_TAGVIEW_COUNTLABEL];
        tagCountLabel.text = [NSString stringWithFormat:@"%d", hightlightedIndex + 2];
        
        UILabel *tagTimeLabel = (UILabel *)[newTagView viewWithTag:TAG_TAGVIEW_TIMELABEL];
        tagTimeLabel.text = [NSString stringWithFormat:@"%@", tagSliderView.currentTimeStr];
        tagTimeLabel.hidden = YES;
        
        CGRect rect = newTagView.frame;
        rect.origin.x = tagSliderView.frame.size.width * tagSliderView.progress - rect.size.width / 2;
        if(currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown){
            rect.size.height = 85;
            
            UIImageView *pointView = (UIImageView *)[newTagView viewWithTag:TAG_TAGVIEW_POINT];
            pointView.frame = CGRectMake(newTagView.frame.size.width / 2 - 16 / 2, pointView.frame.origin.y, 16, 70);
            
            tagCountLabel.frame = CGRectMake(newTagView.frame.size.width / 2 - tagCountLabel.frame.size.width / 2, 53, tagCountLabel.frame.size.width, tagCountLabel.frame.size.height);
            tagCountLabel.font = [UIFont systemFontOfSize:13];
            
            tagTimeLabel.frame = CGRectMake(newTagView.frame.size.width / 2 - tagTimeLabel.frame.size.width / 2, 69, tagTimeLabel.frame.size.width, tagTimeLabel.frame.size.height);
        }else{
            rect.size.height = 95;
            
            UIImageView *pointView = (UIImageView *)[newTagView viewWithTag:TAG_TAGVIEW_POINT];
            pointView.frame = CGRectMake(newTagView.frame.size.width / 2 - 18 / 2, pointView.frame.origin.y, 18, 80);
            
            tagCountLabel.frame = CGRectMake(newTagView.frame.size.width / 2 - tagCountLabel.frame.size.width / 2, 60, tagCountLabel.frame.size.width, tagCountLabel.frame.size.height);
            tagCountLabel.font = [UIFont systemFontOfSize:12];
            
            tagTimeLabel.frame = CGRectMake(newTagView.frame.size.width / 2 - tagTimeLabel.frame.size.width / 2, 78, tagTimeLabel.frame.size.width, tagTimeLabel.frame.size.height);
        }
        newTagView.frame = rect;
        
        NSInteger index = tagSliderView.tagViews.count - 1 - hightlightedIndex;
        [tagSliderView addTagView:newTagView atIndex:index];  
        [tagSliderView.positionPercentage insertObject:[NSNumber numberWithFloat:tagSliderView.progress] atIndex:index];
        
        //刷新标记序号
        NSInteger count = indexList.count - 1 - (hightlightedIndex + 2);
        for(NSInteger i = 0; i <= count; i++){
            NSLog(@"looping>..");
            UIView *tagView = [tagSliderView.tagViews objectAtIndex:i];
            UILabel *countLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_COUNTLABEL];
            countLabel.text = [NSString stringWithFormat:@"%d", indexList.count - 1 - i + 1];        
        }    
        
        //刷新列表视图
        [myTableView beginUpdates];
        [myTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(indexList.count - 2 - hightlightedIndex) inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        [myTableView endUpdates];    
        
        [myTableView beginUpdates];        
        NSMutableArray *rowIndexPaths = [[NSMutableArray alloc] init];
        for(NSInteger i = 0; i < indexList.count; i++){
            if(i != indexList.count - 2 - hightlightedIndex){
                NSIndexPath *temp = [NSIndexPath indexPathForRow:i inSection:0];
                [rowIndexPaths addObject:temp];
            }
        }
        [myTableView reloadRowsAtIndexPaths:rowIndexPaths withRowAnimation:UITableViewRowAnimationNone];
        [myTableView endUpdates];   
        [rowIndexPaths release];
        
        hightlightedIndex++;
        [myTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:(indexList.count - 1 - hightlightedIndex) inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];   
        
        didEdit = YES; 
        
    }else{
        
        [self showOverlayViewWithMessage:@"时间点重复"];
    }   

}

-(IBAction) stop:(id)sender{
    if(audioPlayer != nil){
        [audioPlayer stop];
        self.audioPlayer = nil;
        
        [progressTimer invalidate];
        progressTimer = nil;
        
        idleIndex = 0;
        
        [tagSliderView setProgress:0.0];
        
        [self willChangeValueForKey:@"playing"];
        playing = NO;
        [self didChangeValueForKey:@"playing"];
    }
}

-(void) initLayout{
    self.view.userInteractionEnabled = NO;
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"button_back02.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"button_back02_hover.png"] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    backButton.frame = CGRectMake(0, 0, 56, 28);
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = buttonItem;
    [buttonItem release];
    
    /*
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setImage:[UIImage imageNamed:@"button_done.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"button_done_hover.png"] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(stop:) forControlEvents:UIControlEventTouchUpInside];
    doneButton.frame = CGRectMake(0, 0, 46, 28);
    UIBarButtonItem *buttonItem2 = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem = buttonItem2;
    [buttonItem2 release];
    */
    self.navigationItem.title = [dataInfo objectForKey:kTitle];
    
    tagSliderView = [[TagSliderView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, sliderBackView.frame.size.height) andTotalTimeStr:[dataInfo objectForKey:kDuration]];
    [sliderBackView addSubview:tagSliderView];
    [tagSliderView release];     
    
    self.navigationController.delegate = self;    
    
    /*
    if([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown){
        [self portraitView];
    }else{
        [self landscapeView];
    }
     */
 
}

-(void) landscapeView{    
    CGFloat screenWidth = [UIScreen mainScreen].applicationFrame.size.height;
    NSLog(@"screenWidth: %f", screenWidth);
    
    self.sliderBackView.frame = CGRectMake(0, 0, screenWidth, 95);
    self.myTableView.frame = CGRectMake(0, 95, screenWidth, 124);
    self.tableBackView.frame = CGRectMake(0, 95, screenWidth, 124);
    
    self.prevButton.frame = CGRectMake(0, 219, 120, 49);
    [prevButton setImage:[UIImage imageNamed:@"button_left_h.png"] forState:UIControlStateNormal];
    self.playButton.frame = CGRectMake(120, 219, 120, 49);
    [playButton setImage:[UIImage imageNamed:@"button_play_h.png"] forState:UIControlStateNormal];
    self.nextButton.frame = CGRectMake(240, 219, 120, 49);
    [nextButton setImage:[UIImage imageNamed:@"button_right_h.png"] forState:UIControlStateNormal];
    self.addTagButton.frame = CGRectMake(360, 219, 120, 49);
    [addTagButton setImage:[UIImage imageNamed:@"button_add_h.png"] forState:UIControlStateNormal];
    
    [myTableView reloadData];    
    [tagSliderView landscapeLayout];

}

-(void) portraitView{    
    CGFloat screenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    NSLog(@"screenWidth: %f", screenWidth);
    
    self.sliderBackView.frame = CGRectMake(0, 0, screenWidth, 87);
    self.myTableView.frame = CGRectMake(0, 87, screenWidth, 280);
    self.tableBackView.frame = CGRectMake(0, 87, screenWidth, 280);
    self.prevButton.frame = CGRectMake(0, 367, 80, 49);
    [prevButton setImage:[UIImage imageNamed:@"button_left.png"] forState:UIControlStateNormal];
    self.playButton.frame = CGRectMake(80, 367, 80, 49);
    [playButton setImage:[UIImage imageNamed:@"button_play.png"] forState:UIControlStateNormal];
    self.nextButton.frame = CGRectMake(160, 367, 80, 49);
    [nextButton setImage:[UIImage imageNamed:@"button_right.png"] forState:UIControlStateNormal];
    self.addTagButton.frame = CGRectMake(240, 367, 80, 49);
    [addTagButton setImage:[UIImage imageNamed:@"button_add.png"] forState:UIControlStateNormal];
    
    [myTableView reloadData];
    [tagSliderView portraitLayout];

}

-(void) editTagTitle:(id)sender{
    UIButton *clicked = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[clicked superview] superview];
    NSIndexPath *path = [myTableView indexPathForCell:cell];
    editingIndex = path.row;
    
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
    /*
    UIButton *clicked = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[clicked superview] superview];
    NSIndexPath *path = [myTableView indexPathForCell:cell];
    deletingIndex = path.row;
    */
    
    NSLog(@"deletingIndex: %d", deletingIndex);   
 
    if(hightlightedIndex + 1 >= indexList.count - deletingIndex){
        hightlightedIndex--;
    }     
    
    [indexList removeObjectAtIndex:deletingIndex];
    
    UIView *deleteTagView = [tagSliderView.tagViews objectAtIndex:deletingIndex];
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeSingleTagView)];
    deleteTagView.alpha = 0.0;
    [UIView commitAnimations];
    
    for(NSInteger i = 0; i < deletingIndex; i++){
        UIView *tagView = [tagSliderView.tagViews objectAtIndex:i];        
        UILabel *countLabel = (UILabel *)[tagView viewWithTag:TAG_TAGVIEW_COUNTLABEL];
        countLabel.text = [NSString stringWithFormat:@"%d", indexList.count - i];
    }
    
    
    [myTableView beginUpdates];
    [myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:deletingIndex inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    [myTableView endUpdates];
    
    [myTableView beginUpdates];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for(NSInteger i = 0; i < indexList.count; i++ ){
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [indexPaths addObject:indexPath];
    }
    [myTableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [myTableView endUpdates];
    [indexPaths release];
    
    if(lastSelectedIndex >= 0){
        UITableViewCell *cell1 = (UITableViewCell *)[myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectedIndex inSection:0]];
        UIImageView *hoverView = (UIImageView *)[cell1.contentView viewWithTag:TAG_CELL2_HOVERVIEW];
        hoverView.alpha = 1.0;
    }
    if(lastSelectedIndex > deletingIndex){
        lastSelectedIndex--;
    }  
    
    NSLog(@"lastSelectedIndex:%d", lastSelectedIndex);
}

-(void) showOverlayViewWithMessage:(NSString *)msg{
    UILabel *msgLabel = nil;
    if(currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown){
        overlayView = [[[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil] objectAtIndex:0];
        msgLabel = (UILabel *)[overlayView viewWithTag:TAG_OVERLAY_MESSAGE_LABEL_PORT];
        
    }else{
        overlayView = [[[NSBundle mainBundle] loadNibNamed:@"OverlayView" owner:self options:nil] lastObject];
        msgLabel = (UILabel *)[overlayView viewWithTag:TAG_OVERLAY_MESSAGE_LABEL_LAND];
            }    
    msgLabel.text = msg;
    overlayView.alpha = 0.0;  
    overlayView.frame = CGRectMake(0, 0, overlayView.frame.size.width, overlayView.frame.size.height);
    [self.view addSubview:overlayView];
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDidStopSelector:@selector(willRemoveOverlayView)];
    overlayView.alpha = 1.0;
    [UIView commitAnimations];
}

-(void) cancelOverlayView{
    if(overlayView != nil){
        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDidStopSelector:@selector(removeOverlayView)];
        overlayView.alpha = 0.0;
        [UIView commitAnimations];
    }
}


@end
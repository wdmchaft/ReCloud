//
//  RecordingViewController.h
//  ReCloud
//
//  Created by hanl on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EGORefreshTableHeaderView.h"

@interface RecordingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioSessionDelegate, AVAudioRecorderDelegate, EGORefreshTableHeaderDelegate>{
    
    UIView *editingView;
    UIView *waitingView;
    UIView *deletingTagView;
    EGORefreshTableHeaderView *refreshHeaderView;
    
    NSInteger editingIndex;
    NSInteger sampleCount;
    NSInteger idleCount;
    NSTimer *recordingTimer;
    NSTimer *sampleTimer;
    BOOL recording;
    BOOL sampling;
    BOOL reloading;
    long timestamp;
    float totalSamplePeak;
    float averageSamplePeak;
    
}

@property (nonatomic, retain) IBOutlet UIView *tagBackView;
@property (nonatomic, retain) IBOutlet UILabel *timingLabel;
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableArray *tagList;
@property (nonatomic, retain) AVAudioRecorder *mRecorder;

-(void)         backAction:(id)sender;
-(void)         stopRecording;
-(NSString *)   stringForDuration:(NSTimeInterval)duration;
-(IBAction)     recordOrPause:(id)sender;
-(IBAction)     tagForTime:(id)sender;
-(void)         addTagView;
-(void)         initLayout;
-(void)         writeAudioIndexFile;
-(void)         reloadTableViewDataSource;
-(void)         doneLoadingTableViewData;
-(void)         sampleSurroundVoice;  //周围环境声音采样
-(void)         showWaitingView;
-(void)         cancelWaitingView;
-(void)         deleteTagViewAtIndex:(NSInteger)index;

@end
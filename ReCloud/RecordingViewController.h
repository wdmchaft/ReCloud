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


@interface RecordingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioSessionDelegate, AVAudioRecorderDelegate>{
    
    UIView *editingView;
    UIView *waitingView;
    UIView *toastView;
    //EGORefreshTableHeaderView *refreshHeaderView;
    
    NSMutableArray *idleList;
    NSMutableArray *tagViews;
    NSArray *statusStrs;
    NSInteger editingIndex;
    NSInteger deletingIndex;
    NSInteger sampleCount;
    NSInteger idleCount;
    NSInteger lastSelectedIndex;
    NSTimer *recordingTimer;
    NSTimer *sampleTimer;
    NSTimer *idleTimer;
    NSTimer *tapeRotatingTimer;
    NSTimer *spectrumTimer;
    BOOL isIdle;
    BOOL recording;
    BOOL sampling;
    BOOL reloading;
    long timestamp;
    float totalSamplePeak;
    float averageSamplePeak;
    float powerPerSpectrumItem;
    float idleTime;
    float rotatingAngle;
    NSInteger tempIndex;
    
}

@property (nonatomic, retain) IBOutlet UIView *tagBackView;
@property (nonatomic, retain) IBOutlet UILabel *timingLabel;
@property (nonatomic, retain) IBOutlet UIButton *recordButton;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) IBOutlet UIImageView *wheelView1;
@property (nonatomic, retain) IBOutlet UIImageView *wheelView2;
@property (nonatomic, retain) IBOutlet UIView *spectrumView;
@property (nonatomic, retain) IBOutlet UIImageView *guideView;
@property (nonatomic, retain) NSMutableArray *tagList;
@property (nonatomic, retain) AVAudioRecorder *mRecorder;

-(void)         stopRecording;
-(NSString *)   stringForDuration:(NSTimeInterval)duration;
-(IBAction)     recordOrPause:(id)sender;
-(IBAction)     tagForTime:(id)sender;
-(IBAction)     saveAndBack:(id)sender;
-(void)         deleteTag:(id)sender;
-(void)         addTagView;
-(void)         initLayout;
-(void)         writeAudioIndexToFile;
//-(void)         reloadTableViewDataSource;
//-(void)         doneLoadingTableViewData;
-(void)         sampleSurroundVoice;  //周围环境声音采样
-(void)         showWaitingView;
-(void)         cancelWaitingView;
-(void)         showToastViewWithMessage:(NSString *)str;
-(void)         cancelToastView;
-(void)         deleteTagViewAtIndex:(NSInteger)index;

@end
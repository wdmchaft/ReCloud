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
    EGORefreshTableHeaderView *refreshHeaderView;
    
    NSInteger editingIndex;
    NSTimer *recordingTimer;
    BOOL recording;
    BOOL sampling;
    BOOL reloading;
    BOOL initial;
    long timestamp;
    
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

@end
//
//  RecordingViewController.h
//  ReCloud
//
//  Created by hanl on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RecordingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioSessionDelegate, AVAudioRecorderDelegate>{
    
    BOOL recording;
    BOOL sampling;
    long timestamp;
    NSTimer *recordingTimer;
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

@end
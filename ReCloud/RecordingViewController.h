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
    BOOL pausing;
    BOOL sampling;
    long timestamp;
}

@property (nonatomic, retain) NSMutableArray *indexList;
@property (nonatomic, retain) AVAudioRecorder *mRecorder;

-(IBAction)     backAction:(id)sender;
-(IBAction)     pauseOrRecordAction:(id)sender;
-(void)         startRecordingForFilepath:(NSString *)path;
-(void)         pauseRecording;
-(void)         stopRecording;
-(void)         resumeRecording;
-(NSString *)   stringForDuration:(NSTimeInterval)duration;

@end
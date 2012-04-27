//
//  PlaybackViewController.h
//  ReCloud
//
//  Created by hanl on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class TagSliderView;

@interface PlaybackViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate, UINavigationControllerDelegate>{
    
    TagSliderView *tagSliderView;
    UIView *editingView;
    
    BOOL didEdit;  //是否编辑过音频编辑，以便是否重新写入文件
    BOOL playing;    
    NSTimer *progressTimer;
    NSInteger editingIndex;
    
}

@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) IBOutlet UIView *sliderBackView;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) NSMutableArray *indexList;
@property (nonatomic, retain) NSMutableDictionary *dataInfo;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

-(id)           initWithAudioInfo:(NSDictionary *)info ;
-(IBAction)     playOrPause:(id)sender;
-(IBAction)     prevSection:(id)sender;
-(IBAction)     nextSection:(id)sender;
-(IBAction)     stop:(id)sender;
-(IBAction)     addTag:(id)sender;
-(void)         backAction:(id)sender;
-(void)         initLayout;

@end

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
    UIView *overlayView;
    
    BOOL didEdit;  //是否编辑过音频，以便是否重新写入文件
    BOOL playing;    
    NSTimer *progressTimer;
    NSInteger editingIndex;
    NSInteger deletingIndex;
    NSInteger hightlightedIndex;   //当前高亮的标记序号 
    NSInteger idleIndex;    //当前断句序号
    NSInteger lastSelectedIndex;
    NSMutableArray *editingButtons;
    
    UIInterfaceOrientation currentOrientation;
    
    IBOutlet UIView *landView;
    IBOutlet UIView *portView;
    
}

@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) IBOutlet UIView *sliderBackView;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *prevButton;
@property (nonatomic, retain) IBOutlet UIButton *addTagButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIImageView *tableBackView;
@property (nonatomic, retain) NSMutableArray *indexList;
@property (nonatomic, retain) NSMutableDictionary *dataInfo;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@property (nonatomic, retain) NSMutableArray *idleList;

-(id)           initWithAudioInfo:(NSDictionary *)info;
-(IBAction)     playOrPause:(id)sender;
-(IBAction)     prevSection:(id)sender;
-(IBAction)     nextSection:(id)sender;
-(IBAction)     stop:(id)sender;
-(IBAction)     addTag:(id)sender;
-(void)         backAction:(id)sender;
-(void)         initLayout;
-(void)         showOverlayViewWithMessage:(NSString *)msg;
-(void)         cancelOverlayView;
-(void)         portraitView;
-(void)         landscapeView;

@end

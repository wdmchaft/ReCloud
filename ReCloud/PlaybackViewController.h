//
//  PlaybackViewController.h
//  ReCloud
//
//  Created by hanl on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlaybackViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>{
    BOOL playing;
    
}

@property (nonatomic, retain) IBOutlet UIView *sliderBackView;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) NSMutableArray *indexList;
@property (nonatomic, retain) NSDictionary *dataInfo;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

-(id)       initWithAudioInfo:(NSDictionary *)info;
-(IBAction) playOrPause:(id)sender;
-(IBAction) prevSection:(id)sender;
-(IBAction) nextSection:(id)sender;
-(IBAction) stop:(id)sender;
-(IBAction) addTag:(id)sender;
-(void)     backAction:(id)sender;
-(void)     initLayout;

@end

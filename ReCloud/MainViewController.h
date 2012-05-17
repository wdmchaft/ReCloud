//
//  MainViewController.h
//  ReCloud
//
//  Created by hanl on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecordingViewController;

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    
    BOOL viewingLocal;
    UIView *editingView;
    NSInteger editingIndex;
    NSInteger lastSelectedIndex;
}

@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) IBOutlet UILabel *editLabel;
@property (nonatomic, retain) NSMutableArray *audioList;

-(IBAction)    showRecordingView:(id)sender;
-(IBAction)    viewCloud:(id)sender;
-(IBAction)    viewLocal:(id)sender;
-(void)        refreshAudioList;
-(void)        editTitle:(id)sender;
-(void)        uploadToCloud:(id)sender;
-(void)        loginAction:(id)sender;
-(void)        editAction:(id)sender;
-(void)        doneEditingAction:(id)sender;
-(void)        initLayout;

@end

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
    
}

@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) IBOutlet UILabel *editLabel;
@property (nonatomic, retain) NSMutableArray *audioList;

-(IBAction) toRecordingView:(id)sender;
-(IBAction) editAction:(id)sender;
-(IBAction) loginAction:(id)sender;
-(IBAction) viewCloud:(id)sender;
-(IBAction) viewLocal:(id)sender;

@end

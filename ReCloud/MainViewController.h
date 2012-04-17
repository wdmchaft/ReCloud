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
    
    
}

@property (nonatomic, retain) NSMutableArray *audioList;

-(IBAction) toRecordView:(id)sender;

@end

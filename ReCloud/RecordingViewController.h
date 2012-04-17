//
//  RecordingViewController.h
//  ReCloud
//
//  Created by hanl on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UIView *silderBackView;

-(IBAction) backAction:(id)sender;

@end

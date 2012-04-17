//
//  PlaybackViewController.h
//  ReCloud
//
//  Created by hanl on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaybackViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) IBOutlet UIView *sliderBackView;
@property (nonatomic, retain) NSMutableArray *indexList;

-(IBAction) backAction:(id)sender;

@end

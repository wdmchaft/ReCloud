//
//  MainViewCell.h
//  ReCloud
//
//  Created by hanl on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewCell : UITableViewCell{
    
}

@property (nonatomic, retain) UIButton      *editButton;
@property (nonatomic, retain) UIButton      *deleteButton;
@property (nonatomic, retain) UILabel       *audioTitleLabel;
@property (nonatomic, retain) UILabel       *filesizeLabel;
@property (nonatomic, retain) UILabel       *durationLabel;
@property (nonatomic, retain) UILabel       *dateLabel;
@property (nonatomic, retain) UILabel       *timeLabel;
@property (nonatomic, retain) UIImageView   *iconImageView;
@property (nonatomic, retain) UIImageView   *filesizeImageView;
@property (nonatomic, retain) UIImageView   *cellBackgroundImageView;

@end

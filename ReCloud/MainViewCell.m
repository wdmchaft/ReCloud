//
//  MainViewCell.m
//  ReCloud
//
//  Created by hanl on 12-5-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainViewCell.h"

@implementation MainViewCell

@synthesize editButton, deleteButton;
@synthesize audioTitleLabel, filesizeLabel, durationLabel, dateLabel, timeLabel;
@synthesize iconImageView, filesizeImageView, cellBackgroundImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        audioTitleLabel = [[UILabel alloc] init];
        filesizeLabel = [[UILabel alloc] init];
        durationLabel = [[UILabel alloc] init];
        dateLabel = [[UILabel alloc] init];
        timeLabel = [[UILabel alloc] init];
        iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons_audiotape.png"]];
        filesizeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"filesize_bg.png"]];
        cellBackgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_bg.png"]];
        //[self.contentView addSubview:cellBackgroundImageView];
        //[self.contentView addSubview:filesizeImageView];
        //[self.contentView addSubview:iconImageView];
        //[self.contentView addSubview:timeLabel];
        //[self.contentView addSubview:dateLabel];
        //[self.contentView addSubview:durationLabel];
        //[self.contentView addSubview:filesizeLabel];
        [self.contentView addSubview:audioTitleLabel];
        [self.contentView addSubview:editButton];
        [self.contentView addSubview:deleteButton];
    }
    return self;
}

-(void) layoutSubviews{
    //audioTitleLabel.frame = 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

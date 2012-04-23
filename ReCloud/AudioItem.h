//
//  AudioItem.h
//  ReCloud
//
//  Created by hanl on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioItem : NSObject

@property (nonatomic, retain) NSString *dateStr;
@property (nonatomic, retain) NSString *timeStr;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *durationStr;
@property (nonatomic, retain) NSString *sizeStr;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSMutableArray *tagList;

-(NSString *)   stringForDuration:(NSTimeInterval)duration;
-(NSInteger)    durationForString:(NSString *)str;

@end

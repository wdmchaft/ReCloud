//
//  AudioItem.m
//  ReCloud
//
//  Created by hanl on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AudioItem.h"

@implementation AudioItem

@synthesize dateStr, timeStr;
@synthesize title, durationStr;
@synthesize sizeStr, filename;
@synthesize tagList;

-(void) dealloc{
    [dateStr release];
    [timeStr release];
    [title release];
    [durationStr release];
    [sizeStr release];
    [filename release];
    [tagList release];
    
    [super dealloc];
}

-(NSString *) stringForDuration:(NSTimeInterval)duration{
    NSInteger temp = (NSInteger)duration;
    NSInteger hour =  temp / 3600;
    NSInteger remainder = temp % 3600;
    NSInteger minute = 0;
    NSInteger second = 0;
    if(remainder != 0){
        minute = remainder / 60;
        second = remainder % 60;
    }    
    NSString *result = [[NSString alloc] initWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    
    return [result autorelease];
}

-(NSInteger) durationForString:(NSString *)str{
    NSArray *arr = [str componentsSeparatedByString:@":"];
    if(arr.count == 3){
        return [[arr objectAtIndex:0] intValue] * 3600 + [[arr objectAtIndex:1] intValue] * 60 + [[arr objectAtIndex:2] intValue];
    }
    return 0;    
}

@end

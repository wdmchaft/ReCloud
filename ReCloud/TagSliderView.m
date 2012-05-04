//
//  TagSliderView.m
//  ReCloud
//
//  Created by hanl on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TagSliderView.h"
#import "Constants.h"

@implementation TagSliderView

@synthesize progress;
@synthesize currentTimeStr;
@synthesize currentXpos;
@synthesize tagViews;

- (id)initWithFrame:(CGRect)frame andTotalTimeStr:(NSString *)str
{
    self = [super initWithFrame:frame];
    if (self) {        
        durationStr = str;
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 50)];
        backView.backgroundColor = CUSTOM_COLOR(176.0, 215.0, 255.0); 
        [self addSubview:backView];
        [backView release];
        
        //progressView为可拖动的进度界面
        UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, backView.frame.size.height)];
        progressView.backgroundColor = [UIColor blackColor];
        progressView.alpha = 0.3;
        progressView.tag = TAG_SLIDER_VIEW;
        [self addSubview:progressView];
        [progressView release];
        
        UILabel *durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, backView.frame.size.width, backView.frame.size.height)];
        durationLabel.backgroundColor = [UIColor clearColor];
        durationLabel.textAlignment = UITextAlignmentCenter;
        durationLabel.font = [UIFont systemFontOfSize:28];
        durationLabel.textColor = [UIColor whiteColor];
        durationLabel.text = [NSString stringWithFormat:@"00:00:00/%@", str];
        durationLabel.center = CGPointMake(backView.frame.size.width / 2, backView.frame.size.height / 2);
        durationLabel.tag = TAG_TAGSLIDERVIEW_PROGRESS_LABEL;
        [self addSubview:durationLabel];
        [durationLabel release];
        duration = [TagSliderView durationForString:str];
        
        //blockView为滑块
        progress = 0.0;
        UIView *blockView = [[[NSBundle mainBundle] loadNibNamed:@"SliderBlockView" owner:self options:nil] lastObject];
        UILabel *blockLabel = (UILabel *)[blockView viewWithTag:TAG_TAGSLIDERVIEW_TIMELABEL];
        blockLabel.text = [NSString stringWithFormat:@"%@", [TagSliderView stringForDuration:duration * progress]];
        self.currentTimeStr = blockLabel.text;
        CGRect rect = blockView.frame;
        rect.origin.x = progressView.frame.size.width - blockView.frame.size.width / 2;
        rect.origin.y = 0;
        blockView.frame = rect;
        blockView.tag = TAG_BLOCK_VIEW;
        [self addSubview:blockView];
        [self bringSubviewToFront:blockView];
        
        tagViews = [[NSMutableArray alloc] init];
    }
    return self;
}



-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s", __FUNCTION__);
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];  
    
    UIView *progressView = [self viewWithTag:TAG_SLIDER_VIEW];
    CGRect rect = progressView.frame;
    rect.size.width = touchPoint.x;
    progressView.frame = rect;
    
    currentXpos = touchPoint.x;
    
    UIView *blockView = [self viewWithTag:TAG_BLOCK_VIEW];
    CGRect rect1 = blockView.frame;
    rect1.origin.x = progressView.frame.size.width - rect1.size.width / 2;
    blockView.frame = rect1;
    
    progress = touchPoint.x / self.frame.size.width;
    UILabel *timeLabel = (UILabel *)[blockView viewWithTag:TAG_TAGSLIDERVIEW_TIMELABEL];
    timeLabel.text = [TagSliderView stringForDuration:duration * progress];   
    self.currentTimeStr = timeLabel.text;
    
    UILabel *progressLabel = (UILabel *)[self viewWithTag:TAG_TAGSLIDERVIEW_PROGRESS_LABEL];
    progressLabel.text = [NSString stringWithFormat:@"%@/%@", self.currentTimeStr, durationStr];

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:currentXpos], kSliderViewBlockXpos, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_WILL_SLIDE object:self userInfo:dict];
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s", __FUNCTION__);
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    
    UIView *progressView = [self viewWithTag:TAG_SLIDER_VIEW];
    CGRect rect = progressView.frame;
    rect.size.width = touchPoint.x;
    progressView.frame = rect;
    
    currentXpos = touchPoint.x;
    
    UIView *blockView = [self viewWithTag:TAG_BLOCK_VIEW];
    CGRect rect1 = blockView.frame;
    rect1.origin.x = progressView.frame.size.width - rect1.size.width / 2;
    blockView.frame = rect1;
    
    progress = touchPoint.x / self.frame.size.width;
    UILabel *timeLabel = (UILabel *)[blockView viewWithTag:TAG_TAGSLIDERVIEW_TIMELABEL];
    timeLabel.text = [TagSliderView stringForDuration:duration * progress];
    self.currentTimeStr = timeLabel.text;
    
    UILabel *progressLabel = (UILabel *)[self viewWithTag:TAG_TAGSLIDERVIEW_PROGRESS_LABEL];
    progressLabel.text = [NSString stringWithFormat:@"%@/%@", self.currentTimeStr, durationStr];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:currentXpos], kSliderViewBlockXpos, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SLIDING object:self userInfo:dict];
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s", __FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_END_SLIDE object:self];
    
}


-(void) dealloc{
    self.currentTimeStr = nil;
    self.tagViews = nil;
    
    [super dealloc];
}

#pragma mark - Instance Methods

-(void) setBackViewColor:(UIColor *)color{
    self.backgroundColor = color;
}


-(void) setSliderViewColor:(UIColor *)color{
    UIView *sliderView = [self viewWithTag:TAG_SLIDER_VIEW];
    sliderView.backgroundColor = color;
}


-(void) addTagView:(UIView *)view atIndex:(NSInteger)index{
    NSLog(@"%s", __FUNCTION__);
    
    view.alpha = 0.0;
    [self addSubview:view];
    
    [UIView animateWithDuration:0.5 animations:^{
        view.alpha = 1.0;
    }];
    
    UIView *blockView = [self viewWithTag:TAG_BLOCK_VIEW];
    [self bringSubviewToFront:blockView];
    
    [tagViews insertObject:view atIndex:index];
}

-(void) addTagView:(UIView *)view{
    view.alpha = 0.0;
    [self addSubview:view];
    
    [UIView animateWithDuration:0.5 animations:^{
        view.alpha = 1.0;
    }];
    
    UIView *blockView = [self viewWithTag:TAG_BLOCK_VIEW];
    [self bringSubviewToFront:blockView];
    
    [tagViews addObject:view];
}

-(void) setProgress:(float)_progress{
    progress = _progress;
    self.currentTimeStr = [TagSliderView stringForDuration:progress * duration];
    
    UIView *progressView = [self viewWithTag:TAG_SLIDER_VIEW];
    CGRect rect = progressView.frame;
    rect.size.width = self.frame.size.width * progress;
    progressView.frame = rect;
    
    currentXpos = rect.size.width;
    
    UIView *blockView = [self viewWithTag:TAG_BLOCK_VIEW];
    CGRect rect1 = blockView.frame;
    rect1.origin.x = progressView.frame.size.width - rect1.size.width / 2;
    blockView.frame = rect1;
    
    UILabel *blockLabel = (UILabel *)[blockView viewWithTag:TAG_TAGSLIDERVIEW_TIMELABEL];
    blockLabel.text = [TagSliderView stringForDuration:progress * duration];  
    
    UILabel *progressLabel = (UILabel *)[self viewWithTag:TAG_TAGSLIDERVIEW_PROGRESS_LABEL];
    progressLabel.text = [NSString stringWithFormat:@"%@/%@", self.currentTimeStr, durationStr];
}

+(NSString *) stringForDuration:(NSTimeInterval)duration{
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


+(NSInteger) durationForString:(NSString *)str{
    NSArray *arr = [str componentsSeparatedByString:@":"];
    if(arr.count == 3){
        return [[arr objectAtIndex:0] intValue] * 3600 + [[arr objectAtIndex:1] intValue] * 60 + [[arr objectAtIndex:2] intValue];
    }
    return 0;    
}

@end

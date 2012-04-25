//
//  SquareSliderView.m
//  ReCloud
//
//  Created by hanl on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SquareSliderView.h"
#import "Constants.h"

@implementation SquareSliderView

@synthesize progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 50)];
        backView.backgroundColor = CUSTOM_COLOR(176.0, 215.0, 255.0); 
        [self addSubview:backView];
        [backView release];
        
        //progressView为可拖动的进度界面
        UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 2, backView.frame.size.height)];
        progressView.backgroundColor = [UIColor blackColor];
        progressView.alpha = 0.3;
        progressView.tag = TAG_SLIDER_VIEW;
        [self addSubview:progressView];
        [progressView release];
        
        //blockView为滑块
        UIView *blockView = [[[NSBundle mainBundle] loadNibNamed:@"SliderBlockView" owner:self options:nil] lastObject];
        CGRect rect = blockView.frame;
        rect.origin.x = progressView.frame.size.width - blockView.frame.size.width / 2;
        rect.origin.y = 0;
        blockView.frame = rect;
        blockView.tag = TAG_BLOCK_VIEW;
        [self addSubview:blockView];

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
    
    UIView *blockView = [self viewWithTag:TAG_BLOCK_VIEW];
    CGRect rect1 = blockView.frame;
    rect1.origin.x = progressView.frame.size.width - rect1.size.width / 2;
    blockView.frame = rect1;
    
    UILabel *timeLabel = (UILabel *)[blockView viewWithTag:TAG_SQUAEWSLIDERVIEW_TIMELABEL];
    timeLabel.text = [NSString stringWithFormat:@"%f", touchPoint.x];
    
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s", __FUNCTION__);
    
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    
    UIView *progressView = [self viewWithTag:TAG_SLIDER_VIEW];
    CGRect rect = progressView.frame;
    rect.size.width = touchPoint.x;
    progressView.frame = rect;
    
    UIView *blockView = [self viewWithTag:TAG_BLOCK_VIEW];
    CGRect rect1 = blockView.frame;
    rect1.origin.x = progressView.frame.size.width - rect1.size.width / 2;
    blockView.frame = rect1;
    
    UILabel *timeLabel = (UILabel *)[blockView viewWithTag:TAG_SQUAEWSLIDERVIEW_TIMELABEL];
    timeLabel.text = [NSString stringWithFormat:@"%f", touchPoint.x];
}


-(void) dealloc{
    
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


@end

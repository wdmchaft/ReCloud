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


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];        
        
        //progressView为可拖动的进度界面
        UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width / 2, frame.size.height)];
        progressView.backgroundColor = [UIColor blueColor];
        progressView.tag = TAG_SLIDER_VIEW;
        [self addSubview:progressView];
        [progressView release];
        
        CGFloat blockWidth = 30;
        //blockView为滑块
        UIView *blockView = [[UIView alloc] initWithFrame:CGRectMake(progressView.frame.size.width - blockWidth, 0, blockWidth, frame.size.height)];
        blockView.backgroundColor = [UIColor redColor];
        blockView.tag = TAG_BLOCK_VIEW;
        [self addSubview:blockView];
        [blockView release];

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
    rect1.origin.x = touchPoint.x - rect1.size.width;
    blockView.frame = rect1;
    
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
    rect1.origin.x = touchPoint.x - rect1.size.width;
    blockView.frame = rect1;
}


-(void) dealloc{
    
    [super dealloc];
}


@end

//
//  TagSliderView.h
//  ReCloud
//
//  Created by hanl on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TagSliderView : UIView{
   
    NSString *durationStr;    
    float duration;
    
}

@property (nonatomic, retain) NSMutableArray *tagViews;
@property (nonatomic, retain) NSString *currentTimeStr;
@property (nonatomic, setter = setProgress:) float progress;
@property (nonatomic, assign) float currentXpos;


-(id)           initWithFrame:(CGRect)frame andTotalTimeStr:(NSString *)str;
-(void)         setBackViewColor:(UIColor *)color;
-(void)         setSliderViewColor:(UIColor *)color;
-(void)         addTagView:(UIView *)view;
-(void)         addTagView:(UIView *)view atIndex:(NSInteger)index;
-(void)         portraitLayout;
-(void)         landscapeLayout;

+(NSString *)   stringForDuration:(NSTimeInterval)duration;
+(NSInteger)    durationForString:(NSString *)str;

@end

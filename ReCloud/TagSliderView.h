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
    NSInteger tagCount;
    float duration;
}

@property (nonatomic, setter = setProgress:) float progress;

-(id)           initWithFrame:(CGRect)frame andTotalTimeStr:(NSString *)str;
-(void)         setBackViewColor:(UIColor *)color;
-(void)         setSliderViewColor:(UIColor *)color;
-(void)         addTagView:(UIView *)view;
-(void)         setProgressForTimeStr:(NSString *)str;

+(NSString *)   stringForDuration:(NSTimeInterval)duration;
+(NSInteger)    durationForString:(NSString *)str;

@end

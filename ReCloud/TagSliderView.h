//
//  TagSliderView.h
//  ReCloud
//
//  Created by hanl on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TagSliderView : UIView

@property (nonatomic, assign) float progress;
@property (nonatomic, assign) float duration;

-(id)           initWithFrame:(CGRect)frame andTimeStr:(NSString *)str;
-(void)         setBackViewColor:(UIColor *)color;
-(void)         setSliderViewColor:(UIColor *)color;
-(void)         addTagView:(UIView *)view withFrame:(CGRect)rect;

+(NSString *)   stringForDuration:(NSTimeInterval)duration;
+(NSInteger)    durationForString:(NSString *)str;

@end

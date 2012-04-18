//
//  SquareSliderView.h
//  ReCloud
//
//  Created by hanl on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SquareSliderView : UIView

@property (nonatomic, assign) float progress;

-(void) setBackViewColor:(UIColor *)color;
-(void) setSliderViewColor:(UIColor *)color;

@end

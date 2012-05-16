//
//  UINavigationBar+Customized.m
//  ReCloud
//
//  Created by hanl on 12-5-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar+Customized.h"

@implementation UINavigationBar (Customized)

-(void) drawRect:(CGRect)rect{
    if([[[UIDevice currentDevice] systemVersion] floatValue] <= 4.9){
        UIImage *image = [UIImage imageNamed:@"top.png"];
        [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }else{
        [super drawRect:rect];
    }
}

@end

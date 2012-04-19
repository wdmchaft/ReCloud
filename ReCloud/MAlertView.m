//
//  MAlertView.m
//  SplitFun
//
//  Created by danal on 11-12-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "MAlertView.h"

#define kMAlertViewTextFieldHeight 30.0
#define kMAlertViewMargin 10.0

@implementation MAlertView

- (void)initialize{

}

//2 buttons supported at most

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    if ((self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles,nil])) {

    }
    return self;
}

- (void)layoutSubviews{

    CGRect rect = self.bounds;
    rect.size.height += textFieldCount*(kMAlertViewTextFieldHeight + kMAlertViewMargin);
    self.bounds = rect;
    float maxLabelY = 0.f;
    int textFieldIndex = 0;
    for (UIView *view in self.subviews) {

        if ([view isKindOfClass:[UIImageView class]]) {
            
        }
       else if ([view isKindOfClass:[UILabel class]]) {
           
            rect = view.frame;
            maxLabelY = rect.origin.y + rect.size.height;
        }
        else if ([view isKindOfClass:[UITextField class]]) {
            
            rect = view.frame;
            rect.size.width = self.bounds.size.width - 2*kMAlertViewMargin;
            rect.size.height = kMAlertViewTextFieldHeight;
            rect.origin.x = kMAlertViewMargin;
            rect.origin.y = maxLabelY + kMAlertViewMargin*(textFieldIndex+1) + kMAlertViewTextFieldHeight*textFieldIndex;
            view.frame = rect;
            textFieldIndex++;
        }
        else {  //UIThreePartButton
            
            rect = view.frame;
            rect.origin.y = self.bounds.size.height - 65.0;
            view.frame = rect;
        }
    }

}

- (void)addTextField:(UITextField *)aTextField placeHolder:(NSString *)placeHolder{
    if (aTextField != nil) {
        textFieldCount++;
        aTextField.frame = CGRectZero;
        aTextField.borderStyle = UITextBorderStyleRoundedRect;
        aTextField.placeholder = placeHolder;
        [self addSubview:aTextField];
//        [self setNeedsLayout];
    }
}

@end

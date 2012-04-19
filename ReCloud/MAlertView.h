//
//  MAlertView.h
//  SplitFun
//
//  Created by danal on 11-12-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MAlertView : UIAlertView {
    UITextField *passwdField;
    NSInteger textFieldCount;
}


- (void)addTextField:(UITextField *)aTextField placeHolder:(NSString *)placeHolder;

@end

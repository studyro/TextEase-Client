//
//  TEEditViewController.h
//  TextEase
//
//  Created by Zhang Studyro on 13-1-16.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TECommandCenter.h"
@interface TEEditViewController : UIViewController

@property (nonatomic, retain) UITextField *titleView;
@property (nonatomic, retain) UITextField *contentView;

@property (nonatomic, retain) TEText *text;

- (instancetype)initWithText:(TEText *)text;

@end

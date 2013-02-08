//
//  TEListViewController.h
//  TextEase
//
//  Created by Zhang Studyro on 13-1-15.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TEListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) UITableView *tableView;

@end

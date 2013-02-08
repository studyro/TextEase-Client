//
//  TEEditViewController.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-16.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "TEEditViewController.h"

@interface TEEditViewController ()

@end

@implementation TEEditViewController

- (void)dealloc
{
    [_text release];
    [_titleView release];
    [_contentView release];
    
    [super dealloc];
}

- (instancetype)initWithText:(TEText *)text
{
    if (self = [super init]) {
        _text = [text retain];
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveText:)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)] autorelease];
    
    _titleView = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 44.0)];
    _contentView = [[UITextField alloc] initWithFrame:CGRectMake(0.0, 44.0, 320.0, 100.0)];
    _titleView.borderStyle = UITextBorderStyleLine;
    _contentView.borderStyle = UITextBorderStyleLine;
    _titleView.font = [UIFont systemFontOfSize:16.0];
    _contentView.font = [UIFont systemFontOfSize:14.0];
    _titleView.backgroundColor = [UIColor whiteColor];
    _contentView.backgroundColor = [UIColor whiteColor];
    
    if (self.text.identifie) {
        [self.text finalizeContent];
        _titleView.text = self.text.title;
        _contentView.text = self.text.content;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationController.title = @"Text";
    [self.view addSubview:self.titleView];
    [self.view addSubview:self.contentView];
}

- (void)saveText:(id)sender
{
    if ([self.titleView.text length] == 0) {
        return;
    }
    
    self.text.title = self.titleView.text;
    self.text.content = self.contentView.text;
    
    if (self.text.identifie)
        [[TECommandCenter sharedCommandCenter] executeCommand:kTECommandUpdate toText:self.text];
    else
        [[TECommandCenter sharedCommandCenter] executeCommand:kTECommandCreate toText:self.text];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  TEListViewController.m
//  TextEase
//
//  Created by Zhang Studyro on 13-1-15.
//  Copyright (c) 2013年 Studyro Studio. All rights reserved.
//

#import "TEListViewController.h"
#import "TECommandCenter.h"
#import "TEExecuter.h"
#import "TEEditViewController.h"

#define kNavigationBarHeight 44.0
#define kStatusBarHeight 20.0

@interface TEListViewController () <TEExecuterDelegate>
@property (nonatomic, retain) NSMutableArray *textArray;
@property (nonatomic, retain) TEExecuter *executer;
@end

@implementation TEListViewController

- (void)dealloc
{
    [_tableView release];
    [_textArray release];
    [_executer release];
    
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height - kStatusBarHeight - kNavigationBarHeight) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createTextAction:)] autorelease];
    self.navigationItem.rightBarButtonItem =[[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)] autorelease];
    self.navigationController.title = @"Texts";
    
    self.executer = [[TEExecuter alloc] init];
    self.executer.delegate = self;
    
    [self reloadTextsTitles];
}

- (void)createTextAction:(id)sender
{
    TEText *text = [[TEText alloc] init];
    TEEditViewController *editViewController = [[TEEditViewController alloc] initWithText:text];
    [text release];
    
    UINavigationController *navi = [[[UINavigationController alloc] initWithRootViewController:editViewController] autorelease];
    [editViewController release];
    
    [self presentViewController:navi animated:YES completion:nil];
}

- (void)editAction:(id)sender
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    if (self.tableView.editing)
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
    else
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];}

- (void)reloadTextsTitles
{
    self.textArray = [NSMutableArray arrayWithArray:[TEText allTexts]];
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadTextsTitles];
    [self.executer sync];
}

#pragma mark - UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TEText *text = [self.textArray objectAtIndex:indexPath.row];
    TEEditViewController *editViewController = [[TEEditViewController alloc] initWithText:text];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:editViewController];
    [editViewController release];
    
    [self presentViewController:navi animated:YES completion:nil];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TEText *text = [[self.textArray objectAtIndex:indexPath.row] retain];
        [self.textArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [[TECommandCenter sharedCommandCenter] executeCommand:kTECommandDelete toText:text];
        [text release];
    }
}

#pragma mark - UITableViewDatasource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Text Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    TEText *text = [self.textArray objectAtIndex:indexPath.row];
    cell.textLabel.text = text.title;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.textArray count];
}

#pragma mark - TEExecuter Delegate Methods
- (void)executer:(TEExecuter *)executer didFinisheSyncWithInfo:(NSDictionary *)info
{
    if (info) {
        NSString *syncStatus = [info objectForKey:@"sync_status"];
        if ([syncStatus isEqualToString:@"synced"]) {
            return;
        }
        else if ([syncStatus isEqualToString:@"got"])
            [self reloadTextsTitles];
    }
}

- (void)executer:(TEExecuter *)executer didCompleteStepWithInfo:(NSDictionary *)info
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

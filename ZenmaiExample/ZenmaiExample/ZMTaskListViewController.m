//
//  ZMTaskListViewController.m
//  ZenmaiExample
//
//  Created by slightair on 2012/11/21.
//  Copyright (c) 2012年 slightair. All rights reserved.
//

#import "ZMTaskListViewController.h"
#import "ZMTaskManager.h"

enum Sections {
    TaskListViewSectionWaitTasks = 0,
    TaskListViewSectionCompleteTasks,
    NumberOfTaskListViewSections
};

@interface ZMTaskListViewController ()

@property(nonatomic, strong) ZMTaskManager *taskManager;
@property(nonatomic, strong) NSMutableArray *completeTasks;

@end

@implementation ZMTaskListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    ZMTaskManager *taskManager = [ZMTaskManager sharedManager];

    if (![taskManager restoreTasks] || taskManager.numberOfTasks == 0) {
        [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:10] userInfo:@{@"name" : @"hoge"}]];
        [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:20] userInfo:@{@"name" : @"fuga"}]];
        [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:30] userInfo:@{@"name" : @"piyo"}]];
        [taskManager addTask:[[ZMTask alloc] initWithDate:[NSDate dateWithTimeIntervalSinceNow:40] userInfo:@{@"name" : @"moge"}]];
    }

    NSNotificationCenter *notificationCenter = taskManager.notificationCenter;
    [notificationCenter addObserverForName:ZMTaskManagerTaskFireNotification
                                    object:nil
                                     queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification *notification){
                                    ZMTask *task = notification.userInfo[ZMTaskManagerNotificationTaskUserInfoKey];
                                    ZMTask *newTask = [[ZMTask alloc] initWithDate:[NSDate dateWithTimeInterval:10 + arc4random() % 5 sinceDate:task.date]
                                                                          userInfo:@{@"name" : task.userInfo[@"name"]}];
                                    [taskManager addTask:newTask];
                                    [self.completeTasks addObject:task];
                                }];

    [notificationCenter addObserverForName:ZMTaskManagerTickNotification
                                    object:nil
                                     queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification *notification){
                                    NSNumber *numberOfFiredTasks = notification.userInfo[ZMTaskManagerNotificationNumberOfFiredTasksUserInfoKey];
                                    NSLog(@"tick %@", numberOfFiredTasks);

                                    if ([numberOfFiredTasks integerValue] > 0) {
                                        [self.tableView reloadData];
                                    }
                                }];

    [notificationCenter addObserverForName:ZMTaskManagerResumedNotification
                                    object:nil
                                     queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification *notification){
                                    [self.tableView reloadData];
                                }];

    self.taskManager = taskManager;
    self.completeTasks = [NSMutableArray array];

    [self.taskManager startCheckTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return NumberOfTaskListViewSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger rows = 0;
    
    switch (section) {
        case TaskListViewSectionWaitTasks:
            rows = [[self.taskManager allTasks] count];
            break;
        case TaskListViewSectionCompleteTasks:
            rows = [self.completeTasks count];
            break;
        default:
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    ZMTask *task = nil;
    
    switch (indexPath.section) {
        case TaskListViewSectionWaitTasks:
            task = [[self.taskManager sortedTasks] objectAtIndex:indexPath.row];
            break;
        case TaskListViewSectionCompleteTasks:
            task = [self.completeTasks objectAtIndex:indexPath.row];
            break;
        default:
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            break;
    }
    
    if (task) {
        cell.textLabel.text = task.userInfo[@"name"];
        cell.detailTextLabel.text = [task.date description];
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section) {
        case TaskListViewSectionWaitTasks:
            title = @"Wait Tasks";
            break;
        case TaskListViewSectionCompleteTasks:
            title = @"Complete Tasks";
            break;
        default:
            title = @"";
            break;
    }
    
    return title;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end

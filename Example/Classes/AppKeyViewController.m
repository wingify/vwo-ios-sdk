//
//  AppKeyViewController.m
//  WingifyMobileApp
//
//  Created by Swapnil on 07/10/16.
//  Copyright © 2016 Wingify. All rights reserved.
//

#import "AppKeyViewController.h"

@interface AppKeyViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation AppKeyViewController {
    NSUserDefaults *defaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
}

- (void)customSetup
{
    defaults = [NSUserDefaults standardUserDefaults];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"keycell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    UILabel *label = (UILabel*)[cell viewWithTag:101];
    
    NSString *account = [defaults stringForKey:@"useAccount"];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    if (indexPath.row == 0) {
        label.text = @"Demo App for account 10";
        if([account isEqualToString:@"10"]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    } else {
        label.text = @"Demo App for account 196";
        if([account isEqualToString:@"196"]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    
    if(indexPath.row == 0) {
        [defaults setObject:@"10" forKey:@"useAccount"];
    } else {
        [defaults setObject:@"196" forKey:@"useAccount"];
    }
    
    [defaults synchronize];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self setCheckMark:indexPath];
}

-(void)setCheckMark:(NSIndexPath*)indexPath {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    
    NSIndexPath *iPath = [NSIndexPath indexPathForRow:(indexPath.row+1)%2 inSection:0];
    cell = [self.tableView cellForRowAtIndexPath:iPath];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
}
@end

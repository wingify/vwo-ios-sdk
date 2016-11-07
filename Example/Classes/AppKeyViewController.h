//
//  AppKeyViewController.h
//  WingifyMobileApp
//
//  Created by Swapnil on 07/10/16.
//  Copyright © 2016 Wingify. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppKeyViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

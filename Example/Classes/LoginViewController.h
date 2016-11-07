//
//  ColorViewController.h
//  WingifyMobileApp
//
//  Created by Swapnil Agarwal on 5/11/15.
//  Copyright (c) 2015 Wingify. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (nonatomic, strong) IBOutlet UILabel* label;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) NSString* text;
@property (weak, nonatomic) IBOutlet UIButton *variationSignin;
@property (weak, nonatomic) IBOutlet UIButton *variationSignup;
- (IBAction)refresh:(id)sender;

@end

//
//  ColorViewController.m
//  WingifyMobileApp
//
//  Created by Swapnil Agarwal on 5/11/15.
//  Copyright (c) 2015 Wingify. All rights reserved.
//

#import "LoginViewController.h"
#import "VWO.h"

@interface LoginViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customSetup];
}


- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
    
    _label.text = _text;
    _label.textColor = _color;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.variationSignin.titleLabel.text = ;
//    self.variationSignup.titleLabel.text = [VWO objectForKey:@"sign-up-text" defaultObject:@"or Try Us"];
    
    [self.variationSignin setTitle:[VWO objectForKey:@"sign-in-text" defaultObject:@"Let's start"] forState:UIControlStateNormal];
    [self.variationSignup setTitle:[VWO objectForKey:@"sign-up-text" defaultObject:@"or Try Us"] forState:UIControlStateNormal];
    NSLog(@"object = %@", [VWO objectForKey:@"sign-in-text"]);
    [self.variationSignin.titleLabel setNeedsLayout];
    [self.variationSignin.titleLabel layoutIfNeeded];
    [self.variationSignup.titleLabel setNeedsLayout];
    [self.variationSignup.titleLabel layoutIfNeeded];
}

#pragma mark state preservation / restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Save what you need here
    [coder encodeObject: _text forKey: @"text"];
    [coder encodeObject: _color forKey: @"color"];

    [super encodeRestorableStateWithCoder:coder];
}


- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Restore what you need here
    _color = [coder decodeObjectForKey: @"color"];
    _text = [coder decodeObjectForKey: @"text"];
    
    [super decodeRestorableStateWithCoder:coder];
}


- (void)applicationFinishedRestoringState
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Call whatever function you need to visually restore
    [self customSetup];
}

- (IBAction)variationSignInTapped:(id)sender {
    [VWO markConversionForGoal:@"loginTapped"];
}

- (IBAction)variationSignupTapped:(id)sender {
    [VWO markConversionForGoal:@"signupTapped"];
}


@end
//
//  MapViewController.m
//  WingifyMobileApp
//
//  Created by Swapnil Agarwal on 5/11/15.
//  Copyright (c) 2015 Wingify. All rights reserved.
//

#import "VariableViewController.h"
#import "VWO.h"

@interface VariableViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation VariableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self customSetup];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.controlBallTopConstraint.constant += 50;
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
        [self.controlView layoutIfNeeded];
    } completion:nil];
    
    // animate variation ball
    self.variationBallTopConstraint.constant += 50;
    NSNumber *speed = [VWO objectForKey:@"ball-speed" defaultObject:@3];
    [UIView animateWithDuration:[speed intValue] delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
        [self.variationView layoutIfNeeded];
    } completion:nil];
    
    self.variationLabel.text = [NSString stringWithFormat:@"Variation, ball speed = %i", speed.intValue];
    [self.variationLabel updateConstraints];
    [self.variationLabel layoutIfNeeded];
    
}

- (void)customSetup
{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark state preservation / restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"%s", __PRETTY_FUNCTION__);

    // Save what you need here
    
    [super encodeRestorableStateWithCoder:coder];
}


- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Restore what you need here
    
    [super decodeRestorableStateWithCoder:coder];
}


- (void)applicationFinishedRestoringState
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // Call whatever function you need to visually restore
    [self customSetup];
}

@end

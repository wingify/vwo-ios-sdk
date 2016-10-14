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
    
    self.controlBallTopConstraint.constant = 8 + 50;
    [UIView animateWithDuration:1.0f/2.0f delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse animations:^{
        [self.controlView layoutIfNeeded];
    } completion:nil];
    [self animateBall];
}

// animate variation ball
-(void)animateBall {
    
    
    // stop any already running animations
    [self.variationView.layer removeAllAnimations];
    for (CALayer *l in self.variationView.layer.sublayers)
    {
        [l removeAllAnimations];
    }
    
    self.variationBallTopConstraint.constant = 8;
    [self.variationView setNeedsLayout];
    [self.variationView layoutIfNeeded];
    
    self.variationBallTopConstraint.constant = 8 + 50;
    NSNumber *speed = [VWO objectForKey:@"ball-speed" defaultObject:@2];
    NSLog(@"speed = %f", [speed floatValue]);
    
    [UIView animateWithDuration:1.0f/[speed floatValue]
                          delay:0
                        options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse
                     animations:^{
                         [self.variationView layoutIfNeeded];
                     }
                     completion:nil
     ];
    
    self.variationLabel.text = [NSString stringWithFormat:@"Variation, ball speed = %.2f", speed.floatValue];
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

- (IBAction)refresh:(id)sender {
    [self animateBall];
}
@end

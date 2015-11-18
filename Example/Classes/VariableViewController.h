//
//  MapViewController.h
//  WingifyMobileApp
//
//  Created by Swapnil Agarwal on 5/11/15.
//  Copyright (c) 2015 Wingify. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VariableViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *controlBall;
@property (weak, nonatomic) IBOutlet UIImageView *variationBall;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlBallTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *variationBallTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UIView *variationView;
@property (weak, nonatomic) IBOutlet UILabel *controlLabel;

@property (weak, nonatomic) IBOutlet UILabel *variationLabel;

@end

//
//  LayoutViewController.h
//  WingifyMobileApp
//
//  Created by Swapnil Agarwal.
//  Copyright (c) 2016 Wingify. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LayoutViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *controlCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *variationCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *variationLabel;
- (IBAction)refresh:(id)sender;

@end

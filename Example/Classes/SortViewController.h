//
//  MapViewController.h
//  WingifyMobileApp
//
//  Created by Swapnil Agarwal.
//  Copyright (c) 2015 Wingify. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SortViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *controlCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *variationCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *variationLabel;

@end

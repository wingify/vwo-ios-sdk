//
//  MapViewController.h
//  WingifyMobileApp
//
//  Created by Swapnil Agarwal on 5/11/15.
//  Copyright (c) 2015 Wingify. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BannerViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *controlCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *variationCollectionView;

@property (weak, nonatomic) IBOutlet UIImageView *variationBannerview;
@end

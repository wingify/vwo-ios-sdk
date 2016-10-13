//
//  LayoutViewController.m
//  WingifyMobileApp
//
//  Created by Swapnil Agarwal on 5/11/15.
//  Copyright (c) 2016 Wingify. All rights reserved.
//

#import "LayoutViewController.h"
#import "VWO.h"
#import <QuartzCore/QuartzCore.h>


@interface LayoutViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation LayoutViewController {
    NSArray *products;
    NSArray *variationProducts;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    id iPhone = @{
                  @"name": @"iPhone 6",
                  @"price": @599,
                  @"popularity": @1,
                  @"image": @"P1.png"
                  };
    
    id nexus6 = @{
                  @"name": @"Nexus 6",
                  @"price": @499,
                  @"popularity": @2,
                  @"image": @"P4.png"
                  };
    id motoX = @{
                  @"name": @"Moto X",
                  @"price": @350,
                  @"popularity": @3,
                  @"image": @"P3.png"
                  };
    id motoG = @{
                  @"name": @"Moto G",
                  @"price": @450,
                  @"popularity": @4,
                  @"image": @"P2.png"
                  };
    
    id iPad = @{
                 @"name": @"iPad",
                 @"price": @760,
                 @"popularity": @5,
                 @"image": @"P5.jpeg"
                 };
    
    id vr = @{
                 @"name": @"Oculus VR",
                 @"price": @800,
                 @"popularity": @6,
                 @"image": @"P6.jpg"
                 };
    
    
    products = @[iPhone, nexus6, motoX, motoG, iPad, vr];
    
    [self customSetup];
    variationProducts = [NSArray arrayWithArray:products];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.itemSize = CGSizeMake(100, 100);
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.minimumInteritemSpacing = 20;
    flow.minimumLineSpacing = 10;
    [self.controlCollectionView setCollectionViewLayout:flow];
    
    
    
    UICollectionViewFlowLayout *flow2 = [[UICollectionViewFlowLayout alloc] init];
    flow2.itemSize = CGSizeMake(100, 100);
    flow2.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow2.minimumInteritemSpacing = 0;
    flow2.minimumLineSpacing = 10;
    [self.variationCollectionView setCollectionViewLayout:flow2];
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    @try {
        NSString *layout = [VWO objectForKey:@"layout" defaultObject:@"list"];
        
        [self.variationCollectionView reloadData];
        self.variationLabel.text = [NSString stringWithFormat:@"Variation (layout in %@)", layout];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }

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

#pragma mark CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return products.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    //    [cell.layer setCornerRadius:5.0f];
    //cell.clipsToBounds = YES;
    
    id phone;
    if (collectionView == self.controlCollectionView) {
        phone = products[row];
    } else {
        phone = variationProducts[row];
    }
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:101];
    
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:102];
    
    UILabel *priceLabel = (UILabel*)[cell viewWithTag:103];
    
    [imageView setImage:[UIImage imageNamed:phone[@"image"]]];
    nameLabel.text = phone[@"name"];
    priceLabel.text = [NSString stringWithFormat:@"$%@", phone[@"price"]];
    
    
//    cell.layer.borderWidth = 0.5f;
//    cell.layer.borderColor=[UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f].CGColor;

    
//    cell.layer.masksToBounds = NO;
//    cell.layer.borderColor = [UIColor whiteColor].CGColor;
//    cell.layer.borderWidth = 7.0f;
//    cell.layer.contentsScale = [UIScreen mainScreen].scale;
    
    
    // set shadow
//    cell.contentView.layer.masksToBounds = NO;
//    cell.contentView.layer.shadowOffset = CGSizeMake(0, 1);
//    cell.contentView.layer.shadowRadius = 1.0;
//    cell.contentView.layer.shadowColor = [UIColor blackColor].CGColor;
//    cell.contentView.layer.shadowOpacity = 0.5;

    
    cell.layer.borderColor = [UIColor colorWithRed:50.0f/255.0f green:50.0f/255.0f blue:50.0f/255.0f alpha:1.0f].CGColor;
    cell.layer.borderWidth = 0.5;
    cell.layer.cornerRadius = 3;
    
    cell.backgroundColor = [UIColor whiteColor];
    
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float cellHeight = 95;
    float cellWidth = (screenWidth/ 2.0) - 20; //Replace the divisor with the column count requirement. Make sure to have it in float.
    if (collectionView == self.controlCollectionView) {
        return CGSizeMake(cellWidth, cellHeight);
    } else {
        NSString *layout = [VWO objectForKey:@"layout" defaultObject:@"list"];
        if([layout isEqualToString:@"grid"]) {
            cellWidth = cellWidth/2;
        }
        
        return CGSizeMake(cellWidth, cellHeight);
        
    }
    
}

//#pragma mark collection view cell paddings
//- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
//}
//
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
//    
//    return 5.0;
//}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
//    return UIEdgeInsetsMake(20, 20, 20, 20);
//}

@end

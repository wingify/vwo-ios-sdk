//
//  MapViewController.m
//  WingifyMobileApp
//
//  Created by Swapnil Agarwal on 5/11/15.
//  Copyright (c) 2015 Wingify. All rights reserved.
//

#import "SortViewController.h"
#import "VWO.h"

@interface SortViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation SortViewController {
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
    
    products = @[iPhone, nexus6, motoX, motoG];
    
    [self customSetup];
    variationProducts = [NSArray arrayWithArray:products];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupVariation];
}

-(void)setupVariation{
    @try {
        NSString *sorting = [VWO variationForKey:@"sorting" defaultValue:@"popularity"];
        NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:sorting ascending:YES];
        NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
        variationProducts = [variationProducts sortedArrayUsingDescriptors:descriptors];
        
        [self.variationCollectionView reloadData];
        self.variationLabel.text = [NSString stringWithFormat:@"Variation (ordered by %@)", sorting];
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
    
    [imageView updateConstraints];
    [imageView setNeedsLayout];
    [imageView layoutIfNeeded];
    
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float cellWidth = (screenWidth/ 2.0) - 20; //Replace the divisor with the column count requirement. Make sure to have it in float.
    CGSize size = CGSizeMake(cellWidth, 110);
    
    return size;
}

- (IBAction)refresh:(id)sender {
     [self setupVariation];
}
@end

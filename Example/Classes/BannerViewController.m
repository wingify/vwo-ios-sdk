//
//  MapViewController.m
//  WingifyMobileApp
//
//  Created by Swapnil Agarwal on 5/11/15.
//  Copyright (c) 2015 Wingify. All rights reserved.
//

#import "BannerViewController.h"
#import "VWO.h"

@interface BannerViewController ()
@property (nonatomic) IBOutlet UIBarButtonItem* revealButtonItem;
@end

@implementation BannerViewController

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
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(variationBannerTapped:)];
    [self.variationBannerview addGestureRecognizer:tapGesture];
    [self.variationBannerview setUserInteractionEnabled:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *imageName = [VWO objectForKey:@"banner-image" defaultObject:@"B1.png"];
    
    if ([imageName hasPrefix:@"http"]) {
        [self downloadAndShowImage:imageName];
    } else {
        [self.variationBannerview setImage:[UIImage imageNamed:imageName]];
    }
}

-(void)downloadAndShowImage:(NSString*)imageName {
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:imageName] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.variationBannerview.image = [[UIImage alloc] initWithData:data];
            });
            
        }
        
    }] resume];
}

-(void)variationBannerTapped:(id)sender {
    [VWO markConversionForGoal:@"bannerTapped"];
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
    
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    //    [cell.layer setCornerRadius:5.0f];
    //cell.clipsToBounds = YES;
    
    
    // set shadow
    cell.layer.masksToBounds = NO;
    cell.layer.shadowOffset = CGSizeMake(0, 1);
    cell.layer.shadowRadius = 1.0;
    cell.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.layer.shadowOpacity = 0.5;
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:101];
    NSString *imageName = [NSString stringWithFormat:@"P%li.png", (long)row + 1];
    [imageView setImage:[UIImage imageNamed:imageName]];
    
    UILabel *nameLabel = (UILabel*)[cell viewWithTag:102];
    switch (row) {
        case 0:
            nameLabel.text = @"iPhone 6";
            break;
        case 1:
            nameLabel.text = @"Moto X";
            break;
        case 2:
            nameLabel.text = @"Moto G";
            break;
        default:
            break;
    }
    
    
    /*
     UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:iv.bounds
     byRoundingCorners:(UIRectCornerBottomRight)
     cornerRadii:CGSizeMake(500.0, 500.0)];
     
     CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
     shapeLayer.frame = iv.bounds;
     shapeLayer.path  = maskPath.CGPath;
     iv.layer.mask = shapeLayer;
     */
    
    
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float cellWidth = (screenWidth/ 2.0) - 20; //Replace the divisor with the column count requirement. Make sure to have it in float.
    cellWidth = cellWidth/3;
    CGSize size = CGSizeMake(cellWidth, cellWidth + 30);
    
    return size;
}

@end

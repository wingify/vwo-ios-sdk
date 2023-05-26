//
//  Response.h
//  Pods
//
//  Created by Harsh Raghav on 12/05/23.
//

@interface Response : NSObject

@property (nonatomic, assign) BOOL shouldServePreviousWinnerCampaign;
@property (nonatomic, assign) BOOL isNewUser;
@property (nonatomic, strong) NSString *winnerCampaign;

- (BOOL)shouldServePreviousWinnerCampaign;
- (void)setShouldServePreviousWinnerCampaign:(BOOL)shouldServePreviousWinnerCampaign;
- (void)setWinnerCampaign:(NSString *)winnerCampaig;
- (BOOL)isNewUser;
- (void)setNewUser:(BOOL)isNewUser;

@end

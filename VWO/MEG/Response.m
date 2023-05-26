//
//  Response.m
//  VWO
//
//  Created by Harsh Raghav on 12/05/23.
//

#import <Foundation/Foundation.h>
#import "Response.h"

@implementation Response
- (void)setShouldServePreviousWinnerCampaign:(BOOL)shouldServePreviousWinnerCampaign {
    _shouldServePreviousWinnerCampaign = shouldServePreviousWinnerCampaign;
}

- (void)setWinnerCampaign:(NSString *)winnerCampaign {
    _winnerCampaign = winnerCampaign;
}

- (void)setNewUser:(BOOL)isNewUser {
    _isNewUser = isNewUser;
}

@end

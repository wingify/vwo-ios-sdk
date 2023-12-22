//
//  MEGManager.h
//  Pods
//
//  Created by Harsh Raghav on 15/05/23.
//

#import <Foundation/Foundation.h>

#import "WinnerManager.h"

@interface MEGManager : NSObject

//@property (nonatomic, strong) VWO *sSharedInstance;
//@property (nonatomic, strong) VWOLocalData *mVWOLocalData;
@property (nonatomic, strong) WinnerManager *winnerManager;

//- (instancetype)initWithSharedInstance:(VWO *)sharedInstance;
- (NSString *)getCampaign:(NSString *)userId args:(NSDictionary *)args;

@end

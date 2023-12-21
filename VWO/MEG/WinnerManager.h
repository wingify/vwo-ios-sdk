//
//  WinnerManager.h
//  Pods
//
//  Created by Harsh Raghav on 09/05/23.
//
#import <Foundation/Foundation.h>
#import "Response.h"

@interface WinnerManager : NSObject

- (Response *)getSavedDetailsFor:(NSString *)userId args:(NSDictionary<NSString *,NSString *> *)args;
- (BOOL)save:(NSString *)userId winnerCampaign:(NSString *)winnerCampaign args:(NSDictionary<NSString *, NSString *> *)args;

@end

//
//  Mapping.h
//  Pods
//
//  Created by Harsh Raghav on 12/05/23.
//
#import <Foundation/Foundation.h>
@interface Mapping : NSObject

@property(nonatomic, assign)NSString *group;
@property(nonatomic, assign)NSString *testKey;
@property(nonatomic, assign)NSString *winnerCampaign;

- (void)setGroup:(NSString *)group;
- (void)setTestKey:(NSString *)testKey;
- (void)setWinnerCampaign:(NSString *)winnerCampaign;
- (NSDictionary *)getAsJson;
- (BOOL)isSameAs:(Mapping *)mapping;

@end

//
//  Weight.h
//  Pods
//
//  Created by Harsh Raghav on 04/05/23.
//


@interface Weight : NSObject

- (instancetype)init:(NSString *)UserId range:(NSArray<NSNumber *> *)range;
- (NSString *)getCampaign;
- (NSNumber *)getRangeStart;
- (NSNumber *)getRangeEnd;
- (NSArray<NSNumber *> *)getRange;

@end

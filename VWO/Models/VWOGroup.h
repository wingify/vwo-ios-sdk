//
//  VWOGroup.h
//  VWO
//
//  Created by Harsh Raghav on 07/12/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOGroup : NSObject

@property NSDictionary<NSNumber *, NSNumber *>  * campaignGroups;
@property NSDictionary<NSNumber *, id >  * groups;

- (instancetype)initWithDictionary:(NSDictionary *)groupDict

@end

NS_ASSUME_NONNULL_END

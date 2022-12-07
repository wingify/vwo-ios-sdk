//
//  MurmurHash.h
//  VWO
//
//  Created by Harsh Raghav on 01/12/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MurmurHash : NSObject

+(int)hash32:(NSString *) text;
@end

NS_ASSUME_NONNULL_END

//
//  Winner.h
//  Pods
//
//  Created by Harsh Raghav on 05/05/23.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"
#import "Pair.h"

@interface Winner : NSObject

@property (nonatomic, copy) NSString *user;

- (Winner *)fromJSONObject:(NSDictionary *)jsonObject;
- (void)addMapping:(Mapping *)mapping;
- (NSDictionary *)getJSONObject;
- (Pair *)getRemarkForUserArgs:(Mapping *)mapping args:(NSDictionary<NSString *, NSString *> *)args;

@end

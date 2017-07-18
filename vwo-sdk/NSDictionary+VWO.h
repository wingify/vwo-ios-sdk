//
//  NSDictionary+VWO.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 28/06/17.
//
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface NSDictionary (VWO)
- (nullable NSString*)toString;
- (NSArray<NSString *>*) keysMissingFrom:(NSArray<NSString *> *)mustHaveKeys;
@end
NS_ASSUME_NONNULL_END

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

/**
 * Returns the keys that are not in dictionary but are in 'mustHaveKeys'
 *
 * Does mustHaveKeys - self.allKeys
 *
 * @["a":1 "b":2 "c":3].keysMissingFrom(@["a", "b", "c", "d"])
 * Returns @["d"]
 *
 * @param mustHaveKeys List of the keys that dictionary must have
 * @return Missing keys
 */
- (NSArray<NSString *> *)keysMissingFrom:(NSArray<NSString *> *)mustHaveKeys;

- (nullable NSString *)toString;

- (NSArray<NSURLQueryItem *> *)toQueryItems;

@end

NS_ASSUME_NONNULL_END

//
//  VWOVariation.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VWOVariation : NSObject

@property(nonatomic, assign) int iD;
@property(atomic) NSString *name;
@property(readonly) BOOL isControl;

- (nullable instancetype)initWithDictionary:(NSDictionary *)variationDict;

    /// Fetches the value of key in changes. returns nil if not found
- (nullable id)valueOfKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

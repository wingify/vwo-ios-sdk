//
//  VAOVariation.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VAOVariation : NSObject<NSCoding>

@property(nonatomic, assign) int id;
@property(atomic) NSString *name;
@property(atomic, nullable) NSDictionary *changes;

- (nullable instancetype)initWithDictionary:(NSDictionary *) variationDict;

- (BOOL)isControl;

@end
NS_ASSUME_NONNULL_END

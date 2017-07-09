//
//  VAOVariation.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import <Foundation/Foundation.h>

@interface VAOVariation : NSObject<NSCoding>

@property(nonatomic, assign) int id;
@property(atomic) NSString *name;
@property(atomic) NSDictionary *changes;

- (instancetype)initWithDictionary:(NSDictionary *) variationDict;

-(BOOL)isControl;

@end

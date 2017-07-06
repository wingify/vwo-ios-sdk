//
//  VAOVariation.h
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import <Foundation/Foundation.h>

@interface VAOVariation : NSObject

@property(nonatomic, assign) int id;
@property(atomic) NSString *name;
@property(atomic) NSDictionary *changes;

- (instancetype)initWithNSDictionary:(NSDictionary *) variationDict;

-(BOOL)isControl;

@end

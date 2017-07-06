//
//  VAOVariation.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import "VAOVariation.h"
#import "NSDictionary+VWO.h"

static NSString * kId = @"id";
static NSString * kName = @"name";
static NSString * kChanges = @"changes";

@implementation VAOVariation

- (instancetype)initWithNSDictionary:(NSDictionary *) variationDict {
    self = [super init];
    if (self) {
        if ([variationDict hasKeys:@[kId, kName]]) {
            [self setId:[variationDict[kId] intValue]];
            [self setName:[variationDict[kName] stringValue]];
            [self setChanges:variationDict[kChanges]];
        }
    }
    return self;
}

-(BOOL)isControl {
    return (self.id == 1);
}

@end

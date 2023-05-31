//
//  Pair.m
//  VWO
//
//  Created by Harsh Raghav on 16/05/23.
//

#import <Foundation/Foundation.h>
#import "Pair.h"

@implementation Pair

- (instancetype)initWithFirst:(NSNumber *)first second:(id)second {
    self = [super init];
    if (self) {
        _first = first;
        _second = second;
    }
    return self;
}

@end

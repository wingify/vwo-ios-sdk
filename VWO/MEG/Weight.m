//
//  Weight.m
//  VWO
//
//  Created by Harsh Raghav on 04/05/23.
//

#import "Weight.h"

@interface Weight ()

// Private instance variable
@property (nonatomic, strong) NSString *campaign;
@property (nonatomic, strong) NSArray<NSNumber *> *range;

@end

@implementation Weight

- (instancetype)init:(NSString *)UserId range:(NSArray<NSNumber *> *)range
{
    self = [super init];
    if (self) {
        // Initialize private properties
        _campaign = UserId;
        _range = range;
    }
    return self;
}

- (NSString *)getCampaign {
    return _campaign;
}

- (NSNumber *)getRangeStart {
    return _range[0];
}

- (NSNumber *)getRangeEnd {
    return _range[1];
}

- (NSArray<NSNumber *> *)getRange {
    return _range;
}

@end

//
//  Pair.h
//  Pods
//
//  Created by Harsh Raghav on 16/05/23.
//

#import <Foundation/Foundation.h>
#import "Mapping.h"

typedef NS_ENUM(NSInteger, LocalUserSearchRemark) {
    ShouldReturnNull,
    NotFoundForPassedArgs,
    ShouldReturnWinnerCampaign
};

@interface Pair : NSObject

@property (nonatomic, strong) NSNumber *first;
@property (nonatomic, strong) id second;

- (instancetype)initWithFirst:(NSNumber *)first second:(id)second;

@end

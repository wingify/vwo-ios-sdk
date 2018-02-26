//
//  NSString+VWO.h
//  VWO
//
//  Created by Kaunteya Suryawanshi on 17/11/17.
//  Copyright © 2017 vwo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VWOComparisonResult) {
    VWOComparisonResultInvalid = 1,
    VWOComparisonResultLesser = 2,
    VWOComparisonResultGreater = 3,
    VWOComparisonResultEqual = 4,
};

NS_ASSUME_NONNULL_BEGIN

@interface NSString(VWO)

@property (readonly) NSString *toXDotY;
- (VWOComparisonResult)compareVersion:(NSString *)targetVersion;

@end

NS_ASSUME_NONNULL_END

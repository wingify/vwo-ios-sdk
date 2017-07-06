//
//  NSDictionary+VWO.h
//  Pods
//
//  Created by Kaunteya Suryawanshi on 28/06/17.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (VWO)
- (nullable NSString*)toString;
- (BOOL)hasKeys:(NSArray<NSString *> *_Nonnull)keys;
@end

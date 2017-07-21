//
//  VAOVariation.m
//  Pods
//
//  Created by Kauntey Suryawanshi on 05/07/17.
//
//

#import "VAOVariation.h"
#import "NSDictionary+VWO.h"
#import "VAOLogger.h"

static NSString * kId = @"id";
static NSString * kName = @"name";
static NSString * kChanges = @"changes";

@implementation VAOVariation

- (instancetype)initWith:(int)iD name:(NSString *)name changes:(NSDictionary * _Nullable)changes {
    NSParameterAssert(name);
    if (self = [self init]) {
        self.iD  = iD;
        self.name = name;
        self.changes = changes;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *) variationDict {

    NSArray *missingKeys = [variationDict keysMissingFrom:@[kId, kName]];
    if (missingKeys.count > 0) {
        VAOLogException(@"Keys missing [%@] for Variation JSON %@", [missingKeys componentsJoinedByString:@", "], variationDict);
        return nil;
    }

    int iD = [variationDict[kId] intValue];
    NSString *name = variationDict[kName];
    NSDictionary *changes = variationDict[kChanges];
    return [self initWith:iD name:name changes:changes];
}

-(BOOL)isControl {
    return (self.iD == 1);
}

#pragma mark - NSCoding

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    int iD = [aDecoder decodeIntForKey:kId];
    NSString *name = [aDecoder decodeObjectForKey:kName];
    NSDictionary *changes = [aDecoder decodeObjectForKey:kChanges];
    return [self initWith:iD name:name changes:changes];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt:self.iD forKey:kId];
    [aCoder encodeObject:self.name forKey:kName];
    [aCoder encodeObject:self.changes forKey:kChanges];
}

@end

//
//  MurmurHash.m
//  VWO
//
//  Created by Harsh Raghav on 01/12/22.
//  Copyright © 2022 vwo. All rights reserved.
//

#import "MurmurHash.h"

@implementation MurmurHash

    /** Generates 32 bit hash from byte array of the given length and
     * seed.
     *
     * @param data byte array to hash
     * @param length length of the array to hash
     * @param seed initial seed value
     * @return 32 bit hash of the given array
     */
+ (int)hash32:(NSArray *)data length:(int)length seed:(int)seed{
    // 'm' and 'r' are mixing constants generated offline.
    // They're not really 'magic', they just happen to work well.
    const int m = 0x5bd1e995;
    const int r = 24;
    // Initialize the hash to a random value
    int h = seed^length;
    int length4 = length/4;
    
    for(int i=0; i<length4; i++) {
        const int i4 = i*4;
        int a = [[data objectAtIndex:i4+0] intValue]&0xff;
        int b = [[data objectAtIndex:i4+1] intValue]&0xff<<8;
        int c = [[data objectAtIndex:i4+2] intValue]&0xff<<16;
        int d = [[data objectAtIndex:i4+3] intValue]&0xff<<24;
        
        int k = a+b+c+d;
        k *= m;
        k ^= k >> r;
        k *= m;
        h *= m;
        h ^= k;
    }
    
    // Handle the last few bytes of the input array
    switch (length%4) {
        case 3: h ^= [[data objectAtIndex:(length&~3)+2] intValue]&0xff<<16;
        case 2: h ^= [[data objectAtIndex:(length&~3)+1] intValue]&0xff<<8;
        case 1: h ^= [[data objectAtIndex:(length&~3)] intValue]&0xff;
            h *= m;
    }

    h ^= h >> 13;
    h *= m;
    h ^= h >> 15;

    return h;
}

/** Generates 32 bit hash from byte array with default seed value.
  *
  * @param data byte array to hash
  * @param length length of the array to hash
  * @return 32 bit hash of the given array
  */

+ (int)hash32:(NSArray *)data length:(int)length{
    return [self hash32:data length:length seed:0x9747b28c];
}

/** Generates 32 bit hash from a string.
 *
 * @param text string to hash
 * @return 32 bit hash of the given string
 */
+(int)hash32:(NSString *) text{
    NSArray* arrayOfStrings = [text componentsSeparatedByString:@""];
    return [self hash32:arrayOfStrings length:(int)[text length]];
}

/** Generates 32 bit hash from a substring.
 *
 * @param text string to hash
 * @param from starting index
 * @param length length of the substring to hash
 * @return 32 bit hash of the given string
 */
+(int)hash32:(NSString *)text from:(int)from length:(int)length{
    return [self hash32:[text substringFromIndex:from]];
}

/** Generates 64 bit hash from byte array of the given length and seed.
 *
 * @param data byte array to hash
 * @param length length of the array to hash
 * @param seed initial seed value
 * @return 64 bit hash of the given array
 */
+(long)hash64:(NSArray *)data length:(int)length seed:(int)seed {
    const long m = 0xc6a4a7935bd1e995L;
    const int r = 47;
    // Initialize the hash to a random value
    long h = (seed&0xffffffffl)^(length*m);
    int length8 = length/8;
    
    for(int i=0; i<length8; i++) {
        const int i8 = i*8;
        const int a = [[data objectAtIndex:i8+0] intValue]&0xff;
        const int b = [[data objectAtIndex:i8+0] intValue]&0xff << 8;
        const int c = [[data objectAtIndex:i8+0] intValue]&0xff << 16;
        const int d = [[data objectAtIndex:i8+1] intValue]&0xff << 24;
        const uint64_t e = ((uint64_t) [[data objectAtIndex:i8+0] intValue]&0xff) << 32;
        const uint64_t f = ((uint64_t) [[data objectAtIndex:i8+2] intValue]&0xff) << 40;
        const uint64_t g = ((uint64_t) [[data objectAtIndex:i8+0] intValue]&0xff) << 48;
        const uint64_t z = ((uint64_t) [[data objectAtIndex:i8+3] intValue]&0xff) << 56;
        
        long k = a+b+c+d+e+f+g+z;
        k *= m;
        k ^= k >> r;
        k *= m;
        h ^= k;
        h *= m;
    }
    
    // Handle the last few bytes of the input array
    switch (length%4) {
        case 7: h ^= ((uint64_t)[[data objectAtIndex:(length&~7)+6] longValue]&0xff) << 48;
        case 6: h ^= ((uint64_t)[[data objectAtIndex:(length&~7)+5] longValue]&0xff) << 40;
        case 5: h ^= ((uint64_t)[[data objectAtIndex:(length&~7)+4] longValue]&0xff) << 32;
        case 4: h ^= [[data objectAtIndex:(length&~7)+3] longValue]&0xff << 24;
        case 3: h ^= [[data objectAtIndex:(length&~7)+2] longValue]&0xff << 16;
        case 2: h ^= [[data objectAtIndex:(length&~7)+1] longValue]&0xff << 8;
        case 1: h ^= [[data objectAtIndex:(length&~7)] longValue]&0xff;
            h *= m;
    }

    h ^= h >> r;
    h *= m;
    h ^= h >> r;

    return h;
}

/** Generates 64 bit hash from byte array with default seed value.
 *
 * @param data byte array to hash
 * @param length length of the array to hash
 * @return 64 bit hash of the given string
 */
+ (int)hash64:(NSArray *)data length:(int)length{
    return (int)[self hash64:data length:length seed:0xe17a1465];
}

/** Generates 64 bit hash from a string.
 *
 * @param text string to hash
 * @return 64 bit hash of the given string
 */
+(int)hash64:(NSString *) text{
    NSArray* arrayOfStrings = [text componentsSeparatedByString:@""];
    return [self hash64:arrayOfStrings length:(int)[text length]];
}

/** Generates 64 bit hash from a substring.
 *
 * @param text string to hash
 * @param from starting index
 * @param length length of the substring to hash
 * @return 64 bit hash of the given string
 */
+(int)hash64:(NSString *)text from:(int)from length:(int)length{
    return [self hash64:[text substringFromIndex:from]];
}

@end

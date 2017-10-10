//
//  VWOFile.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 16/08/17.
//
//

#import "VWOFile.h"
#import "VWOLogger.h"

@implementation VWOFile

+ (NSURL *)messageQueue {
    NSError *error;
    NSURL *path = [NSFileManager.defaultManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (error != nil) {
        VWOLogException(@"Unable to create file VWOMessages.plist");
    }
    return [path URLByAppendingPathComponent:@"VWOMessages.plist"];
}

+ (NSURL *)campaignCache {
    NSError *error;
    NSURL *path = [NSFileManager.defaultManager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (error != nil) {
        VWOLogException(@"Unable to create file VWOCampaigns.plist");
    }
    return [path URLByAppendingPathComponent:@"VWOCampaigns.plist"];
}

@end

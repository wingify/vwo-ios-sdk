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

+ (NSURL *)activity {
    NSError *error;
    NSURL *path = [NSFileManager.defaultManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (error != nil) {
        VWOLogException(@"Unable to create file VWOActivity.plist");
    }
    return [path URLByAppendingPathComponent:@"VWOActivity.plist"];
}

+ (NSURL *)messages {
    NSError *error;
    NSURL *path = [NSFileManager.defaultManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (error != nil) {
        VWOLogException(@"Unable to create file VWOPendingMessages.plist");
    }
    return [path URLByAppendingPathComponent:@"VWOPendingMessages.plist"];
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
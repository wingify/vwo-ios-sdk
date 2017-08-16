//
//  VAOFile.m
//  Pods
//
//  Created by Kaunteya Suryawanshi on 16/08/17.
//
//

#import "VAOFile.h"
#import "VAOLogger.h"

@implementation VAOFile

+ (NSURL *)activityPath {
    NSError *error;
    NSURL *path = [NSFileManager.defaultManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (error != nil) {
        VAOLogException(@"Unable to create file VWOActivity.plist");
    }
    return [path URLByAppendingPathComponent:@"VWOActivity.plist"];
}

+ (NSURL *)messagesPath {
    NSError *error;
    NSURL *path = [NSFileManager.defaultManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (error != nil) {
        VAOLogException(@"Unable to create file VWOPendingMessages.plist");
    }
    return [path URLByAppendingPathComponent:@"VWOPendingMessages.plist"];
}

+ (NSURL *)campaignCachePath {
    NSError *error;
    NSURL *path = [NSFileManager.defaultManager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&error];
    if (error != nil) {
        VAOLogException(@"Unable to create file VWOCampaigns.plist");
    }
    return [path URLByAppendingPathComponent:@"VWOCampaigns.plist"];
}

@end

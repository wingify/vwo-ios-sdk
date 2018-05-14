
#import "VWOCampaignCache.h"
#import "VWOLogger.h"
#import "NSURLSession+Synchronous.h"
#import "VWOCampaign.h"

@implementation VWOCampaignCache

+ (void)writeFromSettingsFile:(NSString *)settingsFile to:(NSURL *)cacheLocation {
    if ([NSFileManager.defaultManager fileExistsAtPath:cacheLocation.path]) {
        return;
    }
    NSURL *settingsFileURL = [NSBundle.mainBundle URLForResource:settingsFile withExtension:@"json"];
    if (settingsFileURL) {
        NSData *data = [NSData dataWithContentsOfURL:settingsFileURL];
        BOOL isIt = [data writeToURL:cacheLocation atomically:YES];
        VWOLogDebug(@"Settings copied to cache: %@", isIt ? @"success" : @"failed");
    }
}

+ (void)writeFromNetworkResponse:(NSURL *)url
                  timeout:(NSTimeInterval)timeout
            to:(NSURL *)cacheLocation
                    error:(NSString **)errorString {

    VWOLogDebug(@"Fetching settings from network");
    [NSURLRequest requestWithURL:url]
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url
                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                            timeoutInterval:timeout];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLSession.sharedSession sendSynchronousDataTaskWithRequest:urlRequest
                                                                returningResponse:&response
                                                                            error:&error];

    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    if (statusCode >= 500 && statusCode <=599) { return; }

    if (data) {
        if (statusCode >= 400 && statusCode <= 499) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            VWOLogError(@"Client side error %@", json[@"message"]);
            *errorString = json[@"message"];
            return;
        }

        BOOL isIt = [data writeToURL:cacheLocation atomically:YES];
        VWOLogInfo(@"Cache updated: %@", isIt ? @"success" : @"failed");
    }
}

/// Error is generated when campaign cache is empty
+ (nullable NSArray<VWOCampaign *> *)getCampaingsFromCache:(NSURL *)cacheLocation
                                               error:(NSString **)errorString {

    NSData *settingsData = [NSData dataWithContentsOfURL:cacheLocation];
    if (settingsData == nil) {
        *errorString = @"Campaigns not available";
        return nil;
    }

    NSError *jsonerror;
    NSArray<NSDictionary *> *jsonArray = [NSJSONSerialization JSONObjectWithData:settingsData options:0 error:&jsonerror];
    VWOLogDebug(@"%@", jsonArray);

    //Convert JsonArray of campiagns to VWOCampaign array
    NSMutableArray<VWOCampaign *> *newCampaignList = [NSMutableArray new];
    for (NSDictionary *campaignDict in jsonArray) {
        VWOCampaign *aCampaign = [[VWOCampaign alloc] initWithDictionary:campaignDict];
        if (aCampaign) { [newCampaignList addObject:aCampaign]; }
    }
    return newCampaignList;
}

@end

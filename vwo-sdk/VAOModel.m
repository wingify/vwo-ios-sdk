//
//  VAOModel.m
//  VAO
//
//  Created by Wingify on 26/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//

#import "VAOModel.h"
#import "VAOAPIClient.h"
#import "VAOController.h"
#import "VAORavenClient.h"
#import "VAOUtils.h"

@implementation VAOModel

NSMutableDictionary *campaigns;

+ (instancetype)sharedInstance{
    static VAOModel *instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    if (self = [super init]) {
        NSString *campaignsPlist = [self getCampaignPath];
        campaigns = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryWithContentsOfFile:campaignsPlist]];
        if ([[campaigns allKeys] count] > 0) {
            [VAOUtils setIsNewVisitor:NO];
        }
    }
    return self;
}

- (NSString*)getCampaignPath {
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/__vaocampaigns.plist"];
}

- (void)downloadMetaWithCompletionBlock:(void(^)(NSMutableArray *meta))completionBlock
                        withCurrentMeta:(NSMutableDictionary*)currentPairs asynchronously:(BOOL)async {
    
    [[VAOAPIClient sharedInstance] pullABData:currentPairs preview:NO success:^(NSMutableArray *array) {
        
//        VAOLog(@"the json from server is = %@", array);
        
        if (completionBlock) {
            completionBlock(array);
        }
    } failure:^(NSError *error) {
        VAOLog(@"Failed to connect to the VAO server to download AB logs. %@\n", error);
    } isSynchronous:!async];
}

- (NSMutableDictionary*)loadMeta {
    NSString *abPlist = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/__vaojson.plist"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:abPlist];
    return dict;
}

- (void)saveMeta:(NSDictionary *)meta {
    /**
     * we assume that `meta` is the unabridged meta to be saved and is not polluted by any merging of old/original values.
     * Original values, in particular, may not be serializable at all, e.g., images.
     */
    @try {
        NSString *abPlist = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/__vaojson.plist"];
        [meta writeToFile:abPlist atomically:YES];
    }
    @catch (NSException *exception) {
        VAORavenCaptureException(exception);
    }
    @finally {
        
    }
}

- (NSArray *)loadMessages {
    NSString *messagesPlist = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/__vaomessages.plist"];
    NSArray *messages = [NSArray arrayWithContentsOfFile:messagesPlist];
    return messages;
}

- (void)saveMessages:(NSArray *)messages {
    @try {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSString *messagesPlist = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/__vaomessages.plist"];
            [messages writeToFile:messagesPlist atomically:YES];
        });

    }
    @catch (NSException *exception) {
        VAORavenCaptureException(exception);
    }
    @finally {
        
    }
}

/**
 *  Returns YES is user has been made part of any experiment so far
 *  Returns NO otherwise
 */
- (BOOL)isUserPartOfAnyExperiment {
    return ([[campaigns allKeys] count] > 0);
}

/**
 *  Returns YES is user has been made part of the experiment id
 *  Returns NO otherwise
 */
- (BOOL)hasBeenPartOfExperiment:(NSString*)experimentId {
    return (campaigns[experimentId] != nil && ([campaigns[experimentId][@"varId"] isEqualToString:@"0"] == NO));
}

- (NSMutableDictionary*)getCurrentExperimentsVariationPairs {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSDictionary *campaignCopy = [campaigns copy];
    
    for (NSDictionary *experimentId in campaignCopy) {
        dictionary[experimentId] = campaignCopy[experimentId][@"varId"];
    }
    return dictionary;
}

/**
    maintain list of expid-varid
    find exp-id for key,
    if this exp-id exists then already a part, otherwise make part and insert this exp id
 
 */
- (void)checkAndMakePartOfExperiment:(NSString*)experimentId variationId:(NSString*)variationId{
    if (campaigns[experimentId] == nil) {
        campaigns[experimentId] = @{@"varId":variationId};
        
        @try {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSString *campaignsPlist = [self getCampaignPath];
                [[campaigns copy] writeToFile:campaignsPlist atomically:YES];
            });
        }
        @catch (NSException *exception) {
            VAORavenCaptureException(exception);
        }
        @finally {
            
        }
        
        if ([variationId isEqualToString:@"0"] == NO) {
            [[VAOAPIClient sharedInstance] pushVariationRenderWithExperimentId:[experimentId integerValue]
                                                                   variationId:variationId];
        }

    }
}

/**
 *  Returns YES if goal has never been triggered
 *  Returns NO otherwise
 */
- (BOOL)shouldTriggerGoal:(NSString*)goalId forExperiment:(NSString*)experimentId {
    NSMutableDictionary *experimentDict = [NSMutableDictionary dictionaryWithDictionary:campaigns[experimentId]];
    NSArray *goals = experimentDict[@"goals"];
    if ([goals containsObject:goalId] == NO) {
        NSMutableArray *newGoalsArray = [NSMutableArray arrayWithArray:goals];
        [newGoalsArray addObject:goalId];
        experimentDict[@"goals"] = newGoalsArray;
        campaigns[experimentId] = experimentDict;
        NSString *campaignsPlist = [self getCampaignPath];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[campaigns copy] writeToFile:campaignsPlist atomically:YES];
        });
        return YES;
    }
    
    return NO;
}

@end

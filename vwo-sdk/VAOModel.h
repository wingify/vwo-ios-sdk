//
//  VAOModel.h
//  VAO
//
//  Created by Wingify on 26/08/13.
//  Copyright (c) 2013 Wingify Software Pvt. Ltd. All rights reserved.
//
//
//  Model (of MVC fame) for the whole SDK. This manages all data persistence.
//

#import <Foundation/Foundation.h>

@interface VAOModel : NSObject

+ (instancetype)sharedInstance;

- (void)downloadMetaWithCompletionBlock:(void(^)(NSMutableArray *meta))completionBlock
                        withCurrentMeta:(NSMutableDictionary*)currentMeta asynchronously:(BOOL)async;
- (NSArray *)loadMessages;
- (void)saveMeta:(NSDictionary *)meta;
- (NSMutableDictionary*)loadMeta;
- (void)saveMessages:(NSArray *)messages;
- (BOOL)hasBeenPartOfExperiment:(NSString*)experimentId;
- (void)checkAndMakePartOfExperiment:(NSString*)experimentId variationId:(NSString*)variationId;
- (BOOL)shouldTriggerGoal:(NSString*)goalId forExperiment:(NSString*)experimentId;
- (BOOL)isUserPartOfAnyExperiment;
- (NSMutableDictionary*)getCurrentExperimentsVariationPairs;
@end

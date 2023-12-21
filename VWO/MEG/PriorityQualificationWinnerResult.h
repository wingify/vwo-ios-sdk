//
//  PriorityQualificationWinnerResult.h
//  Pods
//
//  Created by Harsh Raghav on 05/05/23.
//
#import <Foundation/Foundation.h>
@interface PriorityQualificationWinnerResult : NSObject

- (BOOL)isGroupInPriority;
- (BOOL)isPriorityCampaignFound;
- (BOOL)isQualified;
- (BOOL)isNotQualified;
- (void)setGroupInPriority:(BOOL)groupInPriority;
- (void)setPriorityCampaignFound:(BOOL)priorityCampaignFound;
- (void)setQualified:(BOOL)qualified;
- (BOOL)shouldContinueWithFurtherChecks;

@end

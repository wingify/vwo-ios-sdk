//
//  PriorityQualificationWinnerResult.m
//  VWO
//
//  Created by Harsh Raghav on 05/05/23.
//

#import "PriorityQualificationWinnerResult.h"

@interface PriorityQualificationWinnerResult ()

// Private instance variable

/**
* To identify whether this check was done for {groupId} or just the {test_key}.
*/
@property (nonatomic, assign) BOOL isGroupInPriority;

/**
 * Will be set true when all the conditions are met. When this flag is set to true, all the conditions are
 * satisfied and the related campaign can be a winner.
 */
@property (nonatomic, assign) BOOL isQualified;

/**
 * Will be true if the priority campaign was found, this will be helpful for optimization
 * when a campaign was found but was not qualified as a winner.
 */
@property (nonatomic, assign) BOOL isPriorityCampaignFound;

@end

@implementation PriorityQualificationWinnerResult


- (BOOL)isGroupInPriority {
    return _isGroupInPriority;
}

- (BOOL)isPriorityCampaignFound {
    return _isPriorityCampaignFound;
}

- (BOOL)isQualified {
    return _isQualified;
}

- (BOOL)isNotQualified {
    return !_isQualified;
}

- (void)setGroupInPriority:(BOOL)groupInPriority {
    _isGroupInPriority = groupInPriority;
}

- (void)setPriorityCampaignFound:(BOOL)priorityCampaignFound {
    _isPriorityCampaignFound = priorityCampaignFound;
}

- (void)setQualified:(BOOL)qualified {
    _isQualified = qualified;
}

- (BOOL)shouldContinueWithFurtherChecks {
    // if true will continue with the unequal weight distribution
    // if false will return null from that point itself.
    return (_isGroupInPriority && !_isQualified);
}

@end

/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBSession.h"

@class FBElementCache;
@class AgentForHost;

@interface FBSession ()
@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, copy, readwrite) NSString *activeSessionIdentifier;
@property (nonatomic, strong, readwrite) FBElementCache *elementCache;
@property (nonatomic, strong, readwrite) AgentForHost *appAgent;

/**
 Sets session as current session
 */
+ (void)markSessionActive:(FBSession *)session;

@end

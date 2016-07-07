/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FBFailureProofTestCase.h"

#import "FBExceptionHandler.h"
#import "FBLogger.h"
#import "FBXCTestCaseImplementationFailureHoldingProxy.h"
#import "FBSession.h"

@interface FBFailureProofTestCase ()
@property (nonatomic, assign) BOOL didRegisterAXTestFailure;
@end

@implementation FBFailureProofTestCase

- (void)setUp
{
  [super setUp];
  self.continueAfterFailure = YES;
  self.internalImplementation = (_XCTestCaseImplementation *)[FBXCTestCaseImplementationFailureHoldingProxy proxyWithXCTestCaseImplementation:self.internalImplementation];
}

/**
 Private XCTestCase method used to block and tunnel failure messages
 */
- (void)_enqueueFailureWithDescription:(NSString *)description
                                inFile:(NSString *)filePath
                                atLine:(NSUInteger)lineNumber
                              expected:(BOOL)expected
{
  [FBLogger logFmt:@"Enqueue Failure:\nDescription: %@\nFilepath: %@\nlineNumber: %lu\nExpected: %d", description, filePath, (unsigned long)lineNumber, expected];
  const BOOL isPossibleDeadlock = ([description rangeOfString:@"Failed to get refreshed snapshot"].location != NSNotFound);
  if (!isPossibleDeadlock) {
    self.didRegisterAXTestFailure = YES;
  }
  else if (self.didRegisterAXTestFailure) {
    self.didRegisterAXTestFailure = NO; // Reseting to NO to enable future deadlock detection
    [[NSException exceptionWithName:FBApplicationDeadlockDetectedException
                             reason:@"Can't communicate with deadlocked application"
                           userInfo:nil]
     raise];
  }
  const BOOL isPossibleCrashAtStartUp = ([description rangeOfString:@"Application is not running"].location != NSNotFound);
  const BOOL isPossibleCrashDuringTest = ([description rangeOfString:@"Failed to copy attributes after 30 retries"].location != NSNotFound);
  if (isPossibleCrashAtStartUp || isPossibleCrashDuringTest) {
    NSLog(@"gogleyin detect app crash");
    [[NSException exceptionWithName:FBApplicationCrashedException reason:@"Application is not running, possibly crashed" userInfo:nil] raise];
  }
}

@end

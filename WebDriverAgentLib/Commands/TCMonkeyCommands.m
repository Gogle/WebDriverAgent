//
//  TCMonkeyCommands.m
//  WebDriverAgent
//
//  Created by gogleyin on 6/29/16.
//  Copyright © 2016 Tencent. All rights reserved.
//

#import "TCMonkeyCommands.h"
#import "FBRouteRequest.h"
#import "XCUIElement.h"
#import "FBElementTypeTransformer.h"
#import "FBSession.h"
#import "FBApplication.h"
#import "XCUIElement+FBTap.h"
#import "AgentForHost.h"
#import "FBKeyboard.h"
#import "FBResponsePayload.h"
#import "XCUIApplication+FBHelpers.h"

@implementation TCMonkeyCommands

#pragma mark - <FBCommandHandler>

+ (NSArray *)routes
{
  return
  @[
    [[FBRoute POST:@"/getTestedAppTree"] respondWithTarget:self action:@selector(handleGetTestedAppTree:)],
    [[FBRoute POST:@"/superProcess"] respondWithTarget:self action:@selector(handleSuperProcessElement:)],
    [[FBRoute POST:@"/connectToApp"] respondWithTarget:self action:@selector(handleConnectToAppAtPort:)],
    [[FBRoute GET:@"/getActiveAppPID"].withoutSession respondWithTarget:self action:@selector(getActiveAppPID:)],
    ];
}

+ (id<FBResponsePayload>)handleGetTestedAppTree:(FBRouteRequest *)request
{
  FBApplication *application = request.session.application;
  if (!application || !application.running) {
      NSUInteger alertCount = [application.alerts count];
      NSLog(@"Alerts count: %lu", (unsigned long)alertCount);
      if (alertCount == 0) {
          [[NSException exceptionWithName:FBApplicationCrashedException reason:@"Application is not running, possibly crashed" userInfo:nil] raise];
      }
  }
  const BOOL accessibleTreeType = [request.arguments[@"accessible"] boolValue];
  return FBResponseWithStatus(FBCommandStatusNoError, @{ @"tree": (accessibleTreeType ? application.fb_accessibilityTree : application.fb_tree) });
}

+ (id<FBResponsePayload>)handleSuperProcessElement:(FBRouteRequest *)request
{
  NSString *typeName = request.arguments[@"className"];
  NSString *index = request.arguments[@"index"];
  NSString *value = request.arguments[@"value"];
  NSLog(@"Calling SuperProcess with type %@ at index %@ with value %@", typeName, index, value);
  XCUIElementType type = [FBElementTypeTransformer elementTypeWithTypeName:typeName];
  NSError *error = [self.class processElementWithType:type atIndex:[index integerValue] under:request.session.application usingValue:value];
  if (error) {
    if ([request.session testedApplicationRunning]) {
      return FBResponseWithError(error);
    } else {
      [[NSException exceptionWithName:FBApplicationCrashedException reason:@"Application is not running, possibly crashed" userInfo:nil] raise];
    }
  }
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)handleConnectToAppAtPort:(FBRouteRequest *)request
{
  NSString *port = request.parameters[@"port"];
  NSLog(@"Calling ConnectToApp at port %@", port);
  [request.session.appAgent connectToLocalIPv4AtPort:(in_port_t)[port intValue]];
  return FBResponseWithOK();
}

+ (id<FBResponsePayload>)getActiveAppPID:(FBRouteRequest *)request
{
  return FBResponseWithStatus(FBCommandStatusNoError, @([FBApplication fb_activeApplication].processID));
}

+ (NSError *)processElementWithType:(XCUIElementType)type atIndex:(NSUInteger)index under:(XCUIElement *)element usingValue:(NSString *)value
{
  NSError *error = nil;
  NSArray<XCUIElement *> *elements = [[element descendantsMatchingType:type] allElementsBoundByIndex];
    NSLog(@"Count of type %@: %lu", [FBElementTypeTransformer stringWithElementType:type], (unsigned long)[elements count]);
  if (index >= [elements count]) {
    NSLog(@"Index of the element to process is beyond count.");
    return nil;
  }
  XCUIElement *element_chosen = [elements objectAtIndex:index];
  if (type == XCUIElementTypeSearchField || type == XCUIElementTypeTextField || type == XCUIElementTypeSecureTextField) {
    if (!element_chosen.hasKeyboardFocus && ![element_chosen fb_tapWithError:&error]) {
      return error;
    }
    if (value == (id)[NSNull null] || value.length == 0) {
      value = [NSString stringWithFormat:@"This is a sentencce for newmonkey testing.\n"];
    } else {
      if (![value hasSuffix:@"\n"]) {
        value = [value stringByAppendingString:@"\n"];
      }
    }
    if (![FBKeyboard typeText:value error:&error]) {
      return error;
    }
    return nil;
  }
  if (![element_chosen fb_tapWithError:&error]) {
    return error;
  }
  return nil;
}

@end

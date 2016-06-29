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

@implementation TCMonkeyCommands

#pragma mark - <FBCommandHandler>

+ (NSArray *)routes
{
  return
  @[
    [[FBRoute POST:@"/superTap"] respondWithTarget:self action:@selector(handleSuperTapElement:)],
    ];
}

+ (id<FBResponsePayload>)handleSuperTapElement:(FBRouteRequest *)request
{
  NSString *typeName = request.parameters[@"className"];
  NSString *index = request.parameters[@"index"];
  NSLog(@"Calling Super Tap with type %@ at index %@", typeName, index);
  XCUIElementType type = [FBElementTypeTransformer elementTypeWithTypeName:typeName];
  return [self.class tapElementWithType:type atIndex:[index integerValue] under:request.session.application];
}

+ (id<FBResponsePayload>)tapElementWithType:(XCUIElementType)type atIndex:(NSUInteger)index under:(XCUIElement *)element
{
  NSArray<XCUIElement *> *elements = [[element descendantsMatchingType:type] allElementsBoundByIndex];
  //    NSLog(@"%@", elements);
  if (index >= [elements count]) {
    NSLog(@"Index of the element to tap is beyond count.");
    return FBResponseWithOK();
  }
  NSError *error = nil;
  if (![[elements objectAtIndex:index] fb_tapWithError:&error]) {
    return FBResponseWithError(error);
  }
  return FBResponseWithOK();
}

@end

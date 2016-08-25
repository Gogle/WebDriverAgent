//
//  AgentForHost.h
//  WebDriverAgent
//
//  Created by gogleyin on 6/29/16.
//  Copyright © 2016 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
  TCFrameTypeDeviceInfo = 100,
  TCFrameTypeTextMessage = 101,
};

typedef struct _PTExampleTextFrame {
  uint32_t length;
  uint8_t utf8text[100];
} PTExampleTextFrame;

@interface AgentForHost : NSObject
- (void)connectToLocalIPv4AtPort:(in_port_t)port;
@end

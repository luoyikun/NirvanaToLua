//
//  ChannelAgentAccessor.h
//  NirvanaIOS
//
//  Created by njmac on 2018/1/23.
//  Copyright © 2018年 nirvana. All rights reserved.
//
#ifndef ChannelAgentAccessor_h
#define ChannelAgentAccessor_h

#import <Foundation/Foundation.h>
#import "NSBundleBundelHelper.h"
#import "ChannelAgent.h"
#import "DefaultChannelAgent.h"

@interface ChannelAgentAccessor : NSObject
+(id<ChannelAgent>)getAgent;
@end

#endif /* ChannelAgentAccessor_h */

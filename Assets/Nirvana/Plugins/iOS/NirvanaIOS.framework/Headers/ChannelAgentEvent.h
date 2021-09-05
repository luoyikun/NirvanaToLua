//
//  ChannelAgentEvent.h
//  NirvanaIOS
//
//  Created by njmac on 2018/1/24.
//  Copyright © 2018年 nirvana. All rights reserved.
//
#ifndef ChannelAgentEvent_h
#define ChannelAgentEvent_h

#import <Foundation/Foundation.h>

@interface ChannelAgentEvent : NSObject

+ (void(^)(BOOL))initCallback;
+ (void)setInitCallback:(void(^)(BOOL))value;

+ (void(^)(NSString *))loginCallback;
+ (void)setLoginCallback:(void(^)(NSString *))value;

+ (void(^)(NSString *))logoutCallback;
+ (void)setLogoutCallback:(void(^)(NSString *))value;

+ (void(^)())exitCallback;
+ (void)setExitCallback:(void(^)())value;

+(void)initialized:(BOOL)result;
+(void)login:(NSString *)data;
+(void)logout:(NSString *)data;

@end

#endif /* ChannelAgentEvent_h */

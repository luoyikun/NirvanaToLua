//
//  ChannelAgent.h
//  NirvanaIOS
//
//  Created by njmac on 2018/1/23.
//  Copyright © 2018年 nirvana. All rights reserved.
//

#ifndef ChannelAgent_h
#define ChannelAgent_h

#import "AppDelegateEventListener.h"

@protocol ChannelAgent <AppDelegateEventListener>

- (NSString *)ChannelID;
- (NSString *)AgentID;
- (NSString *)InitUrl;

- (void)initialize;
- (void)login:(NSString *)userInfo;
- (void)logout:(NSString *)userInfo;
- (void)pay:(NSString *)userInfo orderID:(NSString *)orderID productID:(NSString *)productID amount:(double)amount;
- (void)ReportEnterZone:(NSString *)userInfo;
- (void)ReportCreateRole:(NSString *)userInfo;
- (void)ReportLoginRole:(NSString *)userInfo;
- (void)ReportLogoutRole:(NSString *)userInfo;
- (void)ReportLevelUp:(NSString *)userInfo;
- (void)OpenUrlWithUrl:(NSString *)url;
- (void)FacebookActiveWithType:(NSString *)type;

@end

#endif /* ChannelAgent_h */

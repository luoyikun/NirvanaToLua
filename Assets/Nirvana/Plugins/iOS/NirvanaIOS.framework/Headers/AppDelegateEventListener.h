//
//  AppDelegateEventListener.h
//  NirvanaIOS
//
//  Created by njmac on 2018/1/23.
//  Copyright © 2018年 nirvana. All rights reserved.
//
#ifndef AppDelegateEventListener_h
#define AppDelegateEventListener_h

#import <Foundation/Foundation.h>

static NSString * NSNotificationOnOpenURL = @"NSNotificationOnOpenURL";
@protocol AppDelegateEventListener <NSObject>
@optional
-(void)didFinishLaunching:(NSNotification  *)notification;
-(void)onOpenURL:(NSNotification  *)notification;
@end

@interface AppDelegateEvent : NSObject
+(void)registerAppDelegateEventListener:(id<AppDelegateEventListener>)listener;
+(void)unregisterAppDelegateEventListener:(id<AppDelegateEventListener>)listener;
@end

#endif /* AppDelegateEventListener_h */

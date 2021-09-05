//
//  DeviceTool.h
//  NirvanaIOS
//
//  Created by njmac on 2018/1/24.
//  Copyright © 2018年 nirvana. All rights reserved.
//
#ifndef DeviceTool_h
#define DeviceTool_h

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "AdSupport/AdSupport.h"
#import "MacFinder.h"

@interface DeviceTool : NSObject
+(NSString *)getDeviceID;
+(NSString *)getVersion;
@end

#endif /* DeviceTool_h */

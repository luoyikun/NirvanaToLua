//
//  ChannelTools.h
//  NirvanaIOS
//
//  Created by njmac on 2018/1/23.
//  Copyright © 2018年 nirvana. All rights reserved.
//
#ifndef ChannelTools_h
#define ChannelTools_h

#import <Foundation/Foundation.h>

@interface ChannelTools : NSObject

+(NSString*)getJSONStringFromDictionary:(NSDictionary *)dictionary;
+(NSDictionary*)getDictionaryFromJSONString:(NSString *)jsonString;

@end

#endif /* ChannelTools_h */

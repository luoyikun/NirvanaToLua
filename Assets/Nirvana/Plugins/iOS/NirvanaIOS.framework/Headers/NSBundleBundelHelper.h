//
//  NSBundle+BundelHelper.h
//  NirvanaIOS
//
//  Created by njmac on 2018/1/24.
//  Copyright © 2018年 nirvana. All rights reserved.
//

#ifndef NSBundleBundelHelper_h
#define NSBundleBundelHelper_h

#import <Foundation/Foundation.h>

@interface NSBundle (BundelHelper)
+(id)findValue:(NSString *)key;
+(NSBundle *)findBundle:(NSString *)key;
@end

#endif /* NSBundleBundelHelper_h */

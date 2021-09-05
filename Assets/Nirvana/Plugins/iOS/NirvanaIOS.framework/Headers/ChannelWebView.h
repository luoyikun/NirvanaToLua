//
//  WebView.h
//  NirvanaIOS
//
//  Created by njmac on 2018/1/31.
//  Copyright © 2018年 nirvana. All rights reserved.
//
#ifndef ChannelWebView_h
#define ChannelWebView_h
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewControllerFinder.h"

@interface NirvanaIOS_ChannelAgent_WebView : NSObject<UIWebViewDelegate, UIAlertViewDelegate>
+ (NirvanaIOS_ChannelAgent_WebView *)shared;
- (void)OpenWithUrl:(NSString *)url;
@end
#endif /* ChannelWebView_h */

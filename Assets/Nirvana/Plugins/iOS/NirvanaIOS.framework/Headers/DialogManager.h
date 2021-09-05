//
//  DialogManager.h
//  NirvanaIOS
//
//  Created by njmac on 2018/1/24.
//  Copyright © 2018年 nirvana. All rights reserved.
//
#ifndef DialogManager_h
#define DialogManager_h

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface DialogManager : NSObject

+(void)showMessage:(NSString *)title message:(NSString *)message buttonLabel:(NSString *)buttonLabel buttonListener:(void(^)(void))buttonListener;

+(void)showConfirm:(NSString *)title message:(NSString *)message confirmLabel:(NSString *)confirmLabel confirmListener:(void(^)(void))confirmListener cancelLabel:(NSString *)cancelLabel cancelListener:(void(^)(void))cancelListener;

@end

#endif /* DialogManager_h */

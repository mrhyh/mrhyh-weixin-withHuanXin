//
//  Header.h
//  iOSAppTemplate
//
//  Created by ylgwhyh on 16/1/25.
//  Copyright © 2016年 lbk. All rights reserved.
//

#ifndef Header_h
#define Header_h


#endif /* Header_h */


#import <Availability.h>

#ifndef __IPHONE_3_0
#warning "This project uses features only available in iOS SDK 3.0 and later."
#endif

#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//#import "EMAlertView.h"
//#import "TTGlobalUICommon.h"
//    #import "UIViewController+HUD.h"
#import "UIViewController+HUD.h"
#import "UIViewController+DismissKeyboard.h"
#import "NSString+Valid.h"
//#import "EaseUI.h"

#import "EaseMob.h"

#endif

#define appKeyString @"1401699#huanxintest" //环信的key
#define apnsCertNameString @"huanxintest" //证书名称


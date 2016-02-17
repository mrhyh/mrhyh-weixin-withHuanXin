//
//  TLChatBoxViewController.h
//  iOSAppTemplate
//
//  Created by libokun on 15/10/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//  发消息栏“加号”弹出的页面及其上面按钮的方法

#import <UIKit/UIKit.h>
#import "TLMessage.h"

@class TLChatBoxViewController;
@protocol TLChatBoxViewControllerDelegate <NSObject>
- (void) chatBoxViewController:(TLChatBoxViewController *)chatboxViewController
        didChangeChatBoxHeight:(CGFloat)height;
- (void) chatBoxViewController:(TLChatBoxViewController *)chatboxViewController
                   sendMessage:(TLMessage *)message;
@end


@interface TLChatBoxViewController : UIViewController

@property id<TLChatBoxViewControllerDelegate>delegate;


@end

//
//  TLConversationViewController.h
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import "CommonTableViewController.h"
#import "EaseMob.h"

@interface TLConversationViewController : CommonTableViewController

@property (nonatomic) BOOL isInvisible;
@property (nonatomic, strong) NSMutableArray *data;      // 消息列表数据

- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation;

@end

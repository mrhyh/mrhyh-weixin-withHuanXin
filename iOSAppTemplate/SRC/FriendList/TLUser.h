//
//  TLUser.h
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMChatManagerDefs.h"


@interface TLUser : NSObject


@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *groupSubject; //群组的主题

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *nikename;
@property (nonatomic, strong) NSString *avatarURL;
@property (nonatomic, strong) NSString *motto;
@property (nonatomic, strong) NSString *phoneNumber;

@property (nonatomic, strong) NSString *pinyin;
@property (nonatomic, strong) NSString *initial;


@property (nonatomic, strong) NSString *groupID; //群ID
//@property (nonatomic, assign) NSInteger *emConversationType; //群ID

//@property (nonatomic, assign) NSInteger conversationType;

@property (nonatomic) EMMessageType eMmessageType; //聊天类型(单聊、群聊等)

@end

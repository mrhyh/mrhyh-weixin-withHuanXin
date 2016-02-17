//
//  TLConversationCell.h
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import "CommonTableViewCell.h"
#import "TLConversation.h"

@interface TLConversationCell : CommonTableViewCell

@property (nonatomic, strong) TLConversation *conversation;
@property (nonatomic, strong) NSString *nameString;

@property (nonatomic, strong) NSString *from;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) NSUInteger messageCount;
@property (nonatomic, strong) NSURL *avatarURL;

@end

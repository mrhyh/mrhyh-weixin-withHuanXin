//
//  TLFriendCell.h
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import "CommonTableViewCell.h"
#import "TLUser.h"
#import "EaseImageView.h"
#import "MKNumberBadgeView.h"

@interface TLFriendCell : CommonTableViewCell

@property (nonatomic, strong) TLUser *user;
@property (nonatomic, strong) EaseImageView *avatarView;

@property (nonatomic, assign) NSInteger unreadCount;

@end

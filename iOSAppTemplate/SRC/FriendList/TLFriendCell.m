//
//  TLFriendCell.m
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import "TLFriendCell.h"



@interface TLFriendCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UIButton *avatarButton;

@property (nonatomic, strong) MKNumberBadgeView* badgeOne;
@end

@implementation TLFriendCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.avatarImageView];
        [self.avatarImageView addSubview:self.badgeOne];
        //[self addSubview:_avatarView];
        //[self addSubview:self.avatarButton];
        [self addSubview:self.usernameLabel];
    }
    return self;
}

- (void) layoutSubviews
{
    self.leftFreeSpace = self.frameHeight *  0.18;
    [super layoutSubviews];
    
    float spaceX = self.frameHeight * 0.18;
    float spaceY = self.frameHeight * 0.17;
    float imageWidth = self.frameHeight - spaceY * 2;
    [_avatarImageView setFrame:CGRectMake(spaceX, spaceY, imageWidth, imageWidth)];
    //[_avatarView setFrame:CGRectMake(spaceX, spaceY, imageWidth, imageWidth)];
    
    float labelX = imageWidth + spaceX * 2;
    float labelWidth = self.frameWidth - labelX - spaceX * 1.5;
    [_usernameLabel setFrame:CGRectMake(labelX, spaceY, labelWidth, imageWidth)];
}

- (void) setUser:(TLUser *)user
{
    [_avatarImageView setImage:[UIImage imageNamed:[NSString stringWithFormat: @"%@", user.avatarURL]]];
    //[_avatarView.imageView setImage:[UIImage imageNamed:[NSString stringWithFormat: @"%@", user.avatarURL]]];
    
    [_avatarButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat: @"%@", user.avatarURL]] forState:UIControlStateNormal];
    _avatarButton.backgroundColor = [UIColor grayColor];
    [_usernameLabel setText:user.username];
}

#pragma mark - Getter and Setter
- (UIImageView *) avatarImageView
{
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
    }
    return _avatarImageView;
}

- (UIButton *) avatarButton{
    if (_avatarButton == nil){
        _avatarButton = [[UIButton alloc] init];
        
    }
    return _avatarButton;
}

- (UILabel *) usernameLabel
{
    if (_usernameLabel == nil) {
        _usernameLabel = [[UILabel alloc] init];
        [_usernameLabel setFont:[UIFont systemFontOfSize:17.0f]];
    }
    return _usernameLabel;
}

- (MKNumberBadgeView *)badgeOne{
    if(_badgeOne == nil){
        _badgeOne = [[MKNumberBadgeView alloc] init];
        _badgeOne.value = 3;
        
        _badgeOne.fillColor = [UIColor redColor];
        _badgeOne.hideWhenZero = YES;

    }
    return _badgeOne;
}

@end

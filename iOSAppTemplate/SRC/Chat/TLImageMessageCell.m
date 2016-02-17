//
//  TLImageMessageCell.m
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/10/16.
//  Copyright © 2015年 lbk. All rights reserved.
//  图片消息的cell

#import "TLImageMessageCell.h"
#import "UIImageView+WebCache.h"

@implementation TLImageMessageCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self insertSubview:self.messageImageView belowSubview:self.messageBackgroundImageView];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    float y = self.avatarImageView.originY - 3;
    if (self.message.ownerTyper == TLMessageOwnerTypeSelf) {
        float x = self.avatarImageView.originX - self.messageImageView.frameWidth - 5;
        [self.messageImageView setOrigin:CGPointMake(x , y)];
        [self.messageBackgroundImageView setFrame:CGRectMake(x, y, self.message.messageSize.width+ 10, self.message.messageSize.height + 10)];
    }
    else if (self.message.ownerTyper == TLMessageOwnerTypeOther) {
        float x = self.avatarImageView.originX + self.avatarImageView.frameWidth + 5;
        [self.messageImageView setOrigin:CGPointMake(x, y)];
        [self.messageBackgroundImageView setFrame:CGRectMake(x, y, self.message.messageSize.width+ 10, self.message.messageSize.height + 10)];
    }
}

#pragma mark - Getter and Setter（设置图片cell）
- (void) setMessage:(TLMessage *)message
{
    [super setMessage:message];
    if(message.imagePath != nil) {
        UIImage *imageTemp;
        if (message.imagePath.length > 0) {
            [self.messageImageView setImage:message.image];
            imageTemp = [UIImage imageWithContentsOfFile:message.imagePath];
            
        }
        else {
            // network Image
            [self.messageImageView sd_setImageWithURL:message.imageURL];
        }
        
        [self.messageImageView setSize:CGSizeMake(message.messageSize.width + 10, message.messageSize.height + 10)];
        [self.messageImageView setImage:imageTemp];
        
//        if(imageTemp != nil){
//            [self.messageImageView setSize:CGSizeMake(WIDTH_SCREEN / 2, imageTemp.size.width / WIDTH_SCREEN * imageTemp.size.height)];
//        }
        
    }
    
    //消息发送者和接受者的消息背景图
    switch (self.message.ownerTyper) {
        case TLMessageOwnerTypeSelf:
            self.messageBackgroundImageView.image = [[UIImage imageNamed:@"message_sender_background_reversed"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
            break;
            
        case TLMessageOwnerTypeOther:
            [self.messageBackgroundImageView setImage:[[UIImage imageNamed:@"message_receiver_background_reversed"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch]];
            break;
        default:
            break;
    }
}

- (UIImageView *) messageImageView
{
    if (_messageImageView == nil) {
        _messageImageView = [[UIImageView alloc] init];
        [_messageImageView setContentMode:UIViewContentModeScaleAspectFill];
        [_messageImageView setClipsToBounds:YES];
    }
    return _messageImageView;
}


@end

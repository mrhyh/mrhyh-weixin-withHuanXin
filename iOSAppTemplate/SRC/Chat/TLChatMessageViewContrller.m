//
//  TLChatMessageViewContrller.m
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/24.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import "TLChatMessageViewContrller.h"

#import "TLTextMessageCell.h"
#import "TLImageMessageCell.h"
#import "TLVoiceMessageCell.h"
#import "TLSystemMessageCell.h"
#import "TLMessageCell.h"

@interface TLChatMessageViewContrller ()

@end

@implementation TLChatMessageViewContrller

#pragma mark - LifeCycle
- (void) viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:DEFAULT_CHAT_BACKGROUND_COLOR];
    
    [self.tableView setTableFooterView:[UIView new]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

#pragma mark - Public Methods
- (void) addNewMessage:(TLMessage *)message
{
    [self.data addObject:message];
    
    [self.tableView reloadData];
    
    if (self.data.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_data.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void) scrollToBottom
{
    if (_data.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_data.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *CellIdentifier = @"CellIdentifier";
    TLMessage *message = [_data objectAtIndex:indexPath.row];
    
    if (message.messageType == TLMessageTypeText){
        
        TLTextMessageCell *cell = (TLTextMessageCell *)[tableView dequeueReusableCellWithIdentifier:message.cellIndentify];
        
        if (cell == nil){
            cell = [[TLTextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:message.cellIndentify];
        }
        
        //cell.messageTextLabel.text = message.text;
        //cell.messageText = message.text;
        [cell setMessage:message];
        return cell;
        
    } else if (message.messageType == TLMessageTypeImage){
        TLImageMessageCell *cell = (TLImageMessageCell *)[tableView dequeueReusableCellWithIdentifier:message.cellIndentify];
        
        if (cell == nil){
            cell = [[TLImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:message.cellIndentify];
        }
        
        [cell setMessage:message];
        return cell;
    }else {
        TLVoiceMessageCell *cell = (TLVoiceMessageCell *)[tableView dequeueReusableCellWithIdentifier:message.cellIndentify];
        
        if(cell == nil){
            cell = [[TLVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:message.cellIndentify];
        }
        
        [cell setMessage:message];
        return cell;
    }
}


#pragma mark - UITableViewCellDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLMessage *message = [_data objectAtIndex:indexPath.row];
    return message.cellHeight;
}

#pragma mark - UIScrollViewDelegate


#pragma mark - Event Response
- (void) didTapView
{
    if (_delegate && [_delegate respondsToSelector:@selector(didTapChatMessageView:)]) {
        [_delegate didTapChatMessageView:self];
    }
}

#pragma mark - Getter

- (NSMutableArray *) data
{
    if (_data == nil) {
        _data = [[NSMutableArray alloc] init];
    }
    return _data;
}

@end

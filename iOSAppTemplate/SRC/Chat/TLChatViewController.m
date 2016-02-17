//
//  TLChatViewController.m
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/24.
//  Copyright (c) 2015年 lbk. All rights reserved.
//  收发消息控制器

#import <AVFoundation/AVFoundation.h>
#import "TLChatViewController.h"
#import "TLChatMessageViewContrller.h"
#import "TLChatBoxViewController.h"
#import "TLUserHelper.h"
#import "EaseMob.h"
#import "EMTextMessageBody.h"
#import "EMChatText.h"
#import "EaseLocationViewController.h"
#import "ChatGroupDetailViewController.h"

@interface TLChatViewController () <TLChatMessageViewControllerDelegate, TLChatBoxViewControllerDelegate, IChatManagerDelegate, EMCallManagerDelegate>
{
    CGFloat viewHeight;
    EMConversation *conversation;
    UITextView * textview;
    double cellIdentify;
   
}

@property (nonatomic, strong) TLChatMessageViewContrller *chatMessageVC;
@property (nonatomic, strong) TLChatBoxViewController *chatBoxVC;

@end

@implementation TLChatViewController

#pragma mark - LifeCycle
- (void) viewDidLoad {
    [super viewDidLoad];
    
    if(_user.eMmessageType != eMessageTypeChat){
        [self initRightButton];
    }
   
    [self.navigationItem setTitle:_user.username];
    if(_user.eMmessageType == eConversationTypeGroupChat){
        [self.navigationItem setTitle:_user.groupSubject];
    }
        
    cellIdentify = 0.0;
   // [self initHuanXinChat];
    
    [self initWithConversationChatter:_user.username conversationType:_user.eMmessageType];
    NSLog(@"userName =%@",_user.username);
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    viewHeight = HEIGHT_SCREEN - HEIGHT_NAVBAR - HEIGHT_STATUSBAR;
    
    [self.view addSubview:self.chatMessageVC.view];
    [self addChildViewController:self.chatMessageVC];
    [self.view addSubview:self.chatBoxVC.view];
    [self addChildViewController:self.chatBoxVC];
}

#pragma mark - TLChatMessageViewControllerDelegate
- (void) didTapChatMessageView:(TLChatMessageViewContrller *)chatMessageViewController
{
    [self.chatBoxVC resignFirstResponder];
}

- (void)rightBarButtonDown{
    NSLog(@"rightBarButtonDown...");
    
    ChatGroupDetailViewController *chatGroupDetailVC = [[ChatGroupDetailViewController alloc] init];
    
    ChatGroupDetailViewController *detailController = [[ChatGroupDetailViewController
                                                        alloc] init];
    detailController.groupId = _user.username;
    [self.navigationController pushViewController:chatGroupDetailVC animated:YES];
}

- (void)initRightButton{
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonicon_more"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonDown)];
    [self.navigationItem setRightBarButtonItem:rightBarButtonItem];
}

#pragma mark - TLChatBoxViewControllerDelegate
#pragma mark - 发送信息
- (void) chatBoxViewController:(TLChatBoxViewController *)chatboxViewController sendMessage:(TLMessage *)message
{
    if(message.messageType == TLMessageTypeText){
        
        EMChatText *txtChat = [[EMChatText alloc] initWithText:message.text];
        EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:txtChat];
        
        // 生成message
        EMMessage *emMessage = [[EMMessage alloc] initWithReceiver:_user.username bodies:@[body]];
        if(_user.eMmessageType == eMessageTypeChat){ //单聊
            emMessage.messageType = eMessageTypeChat;
        }else{ //群聊
            emMessage.messageType = eMessageTypeGroupChat;
        }
        
        EMError *error = nil;
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        //    [chatManager asyncResendMessage:message progress:nil];
        [chatManager sendMessage:emMessage progress:nil error:&error];
        
    }else if (message.messageType == TLMessageTypeImage) {
        
        EMChatImage *imgChat = [[EMChatImage alloc] initWithUIImage:message.image displayName:@"图片"];
        EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithChatObject:imgChat];
        
        // 生成message
        EMMessage *emMessage = [[EMMessage alloc] initWithReceiver:_user.username bodies:@[body]];
        
        if(_user.eMmessageType == eMessageTypeChat){ //单聊
            emMessage.messageType = eMessageTypeChat;
        }else{ //群聊
            emMessage.messageType = eMessageTypeGroupChat;
        }
        
        EMError *error = nil;
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        //    [chatManager asyncResendMessage:message progress:nil];
        [chatManager sendMessage:emMessage progress:nil error:&error];
        
    }else if (message.messageType == TLMessageTypeVoice){
        
        EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:message.voicePath displayName:@"audio"];
        //voice.duration = aDuration;
        EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithChatObject:voice];
        
        // 生成message
        EMMessage *emMessage = [[EMMessage alloc] initWithReceiver:_user.username bodies:@[body]];
        
        if(_user.eMmessageType == eMessageTypeChat){ //单聊
            emMessage.messageType = eMessageTypeChat;
        }else{ //群聊
            emMessage.messageType = eMessageTypeGroupChat;
        }
        
        EMError *error = nil;
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        //    [chatManager asyncResendMessage:message progress:nil];
        [chatManager sendMessage:emMessage progress:nil error:&error];
        
    }else {
        
        EMChatLocation *locChat = [[EMChatLocation alloc] initWithLatitude:message.coordinate.latitude longitude:message.coordinate.longitude address:message.address];
        EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithChatObject:locChat];
        
        // 生成message
        EMMessage *emMessage = [[EMMessage alloc] initWithReceiver:_user.username bodies:@[body]];
        if(_user.eMmessageType == eMessageTypeChat){ //单聊
            emMessage.messageType = eMessageTypeChat;
        }else{ //群聊
            emMessage.messageType = eMessageTypeGroupChat;
        }
        
        EMError *error = nil;
        id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
        //    [chatManager asyncResendMessage:message progress:nil];
        [chatManager sendMessage:emMessage progress:nil error:&error];
        
        NSLog(@"经纬度：%f,%f,地址%@",message.coordinate.latitude, message.coordinate.longitude, message.address);

    }
    
    
//    if (error) {
//        UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"error" message:@"发送失败" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//        [a show];
//    }
    
    //message.from = [TLUserHelper sharedUserHelper].user;
    [self.chatMessageVC addNewMessage:message];
    
    //[self.chatMessageVC scrollToBottom];
}

// 收到消息的回调，带有附件类型的消息可以用SDK提供的下载附件方法下载（后面会讲到）
-(void)didReceiveMessage:(EMMessage *)message
{
    id<IEMMessageBody> msgBody = message.messageBodies.firstObject;
    
    TLMessage *recMessage = [[TLMessage alloc] init];
   
    // 消息中的扩展属性
    NSDictionary *ext = message.ext;
    NSLog(@"消息中的扩展属性是 -- %@",ext);
   
    switch (msgBody.messageBodyType) {
        case eMessageBodyType_Text:
        {
            // 收到的文字消息
            recMessage.text = ((EMTextMessageBody *)msgBody).text;
            recMessage.messageType = TLMessageTypeText;
            NSLog(@"收到的文字是 txt -- %@",recMessage.text);
            
            if(message.ext != nil){
                if(message.ext[@"名片"] != nil){
                    NSString *prefixName = @"名片: ";
                    recMessage.text = [prefixName stringByAppendingFormat:recMessage.text];
                }
            }
            
            [self addMessage:recMessage];
        }
            break;
            
        case eMessageBodyType_Image:
        {
            // 得到一个图片消息body
            EMImageMessageBody *body = ((EMImageMessageBody *)msgBody);
            NSLog(@"大图remote路径 -- %@"   ,body.remotePath);
            NSLog(@"大图local路径 -- %@"    ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
            NSLog(@"大图的secret -- %@"    ,body.secretKey);
            NSLog(@"大图的W -- %f ,大图的H -- %f",body.size.width,body.size.height);
            NSLog(@"大图的下载状态 -- %lu",body.attachmentDownloadStatus);

            // 缩略图sdk会自动下载
            NSLog(@"小图remote路径 -- %@"   ,body.thumbnailRemotePath);
            NSLog(@"小图local路径 -- %@"    ,body.thumbnailLocalPath);
            NSLog(@"小图的secret -- %@"    ,body.thumbnailSecretKey);
            NSLog(@"小图的W -- %f ,大图的H -- %f",body.thumbnailSize.width,body.thumbnailSize.height);
            NSLog(@"小图的下载状态 -- %lu",body.thumbnailDownloadStatus);
        
            
            [[EaseMob sharedInstance].chatManager asyncFetchMessageThumbnail:message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                if (!error) {
                    NSLog(@"缩略图下载成功");
                    recMessage.messageType = TLMessageTypeImage;
                    recMessage.imagePath = body.thumbnailLocalPath;
                    recMessage.image = [UIImage imageWithContentsOfFile:body.thumbnailLocalPath];
                    
                    [self addMessage:recMessage];
                    
                }
            } onQueue:nil];
            
        }
            break;
        case eMessageBodyType_Location:
        {
            EMLocationMessageBody *body = (EMLocationMessageBody *)msgBody;
            NSLog(@"纬度-- %f",body.latitude);
            NSLog(@"经度-- %f",body.longitude);
            NSLog(@"地址-- %@",body.address);

            
            
//            recMessage.coordinate.latitude = body.latitude;
//            recMessage.coordinate.longitude = body.longitude;
            recMessage.address = body.address;
            
            [self addMessage:recMessage];
        }
            break;
        case eMessageBodyType_Voice:
        {
            // 音频sdk会自动下载
            EMVoiceMessageBody *body = (EMVoiceMessageBody *)msgBody;
            NSLog(@"音频remote路径 -- %@"      ,body.remotePath);
            NSLog(@"音频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在（音频会自动调用）
            NSLog(@"音频的secret -- %@"        ,body.secretKey);
            NSLog(@"音频文件大小 -- %lld"       ,body.fileLength);
            NSLog(@"音频文件的下载状态 -- %lu"   ,body.attachmentDownloadStatus);
            NSLog(@"音频的时间长度 -- %lu"      ,body.duration);
            
            
            
            [self addMessage:recMessage];
        }
            break;
        case eMessageBodyType_Video:
        {
            EMVideoMessageBody *body = (EMVideoMessageBody *)msgBody;
            
            NSLog(@"视频remote路径 -- %@"      ,body.remotePath);
            NSLog(@"视频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
            NSLog(@"视频的secret -- %@"        ,body.secretKey);
            NSLog(@"视频文件大小 -- %lld"       ,body.fileLength);
            NSLog(@"视频文件的下载状态 -- %lu"   ,body.attachmentDownloadStatus);
            NSLog(@"视频的时间长度 -- %lu"      ,body.duration);
            NSLog(@"视频的W -- %f ,视频的H -- %f", body.size.width, body.size.height);
            
            // 缩略图sdk会自动下载
            NSLog(@"缩略图的remote路径 -- %@"     ,body.thumbnailRemotePath);
            NSLog(@"缩略图的local路径 -- %@"      ,body.thumbnailRemotePath);
            NSLog(@"缩略图的secret -- %@"        ,body.thumbnailSecretKey);
            NSLog(@"缩略图的下载状态 -- %lu"      ,body.thumbnailDownloadStatus);
            
            [self addMessage:recMessage];
        }
            break;
        case eMessageBodyType_File:
        {
            EMFileMessageBody *body = (EMFileMessageBody *)msgBody;
            NSLog(@"文件remote路径 -- %@"      ,body.remotePath);
            NSLog(@"文件local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
            NSLog(@"文件的secret -- %@"        ,body.secretKey);
            NSLog(@"文件文件大小 -- %lld"       ,body.fileLength);
            NSLog(@"文件文件的下载状态 -- %lu"   ,body.attachmentDownloadStatus);
            
            [self addMessage:recMessage];
        }
            break;
            
        case eMessageBodyType_Command:
        {
            
        }
            break;
        default:
            break;
    }
    
    //recMessage.from = [TLUserHelper sharedUserHelper].user;
}



-(void)didReceiveCmdMessage:(EMMessage *)cmdMessage{
    // cmd消息中的扩展属性
    NSDictionary *ext = cmdMessage.ext;
    NSLog(@"cmd消息中的扩展属性是 -- %@",ext);
}

- (BOOL)updateMessageDeliveryStateToDB{
    
    return YES;
}


//将收到的消息统一加入消息数组
- (void)addMessage:(TLMessage *)message{
    
    //消息的公共部分
    TLMessage *recMessage = [[TLMessage alloc] init];
    recMessage = message;
    recMessage.ownerTyper = TLMessageOwnerTypeOther;
    recMessage.date = [NSDate date];
    recMessage.from.username = message.from.username;
    cellIdentify++;
    recMessage.cellIndentify = [NSString stringWithFormat:@"%f",cellIdentify];
    
    [self.chatMessageVC addNewMessage:message];
}

// 当收到图片或视频时，SDK会自动下载缩略图，并回调该方法，如果下载失败，可以通过
// asyncFetchMessageThumbnail:progress 方法主动获取
-(void)didFetchMessageThumbnail:(EMMessage *)aMessage error:(EMError *)error{
    if (!error) {
        NSLog(@"下载缩略图成功，下载后的message是 -- %@",aMessage);
    }
}

/*!
 @method
 @brief 收到"已送达回执"时的回调方法
 @discussion 发送方收到接收方发送的一个收到消息的回执, 但不意味着接收方已阅读了该消息
 @param resp 收到的"已送达回执"对象, 包括 from, to, chatId等
 @result
 */
- (void)didReceiveHasDeliveredResponse:(EMReceipt *)resp{
    
}

- (void) chatBoxViewController:(TLChatBoxViewController *)chatboxViewController didChangeChatBoxHeight:(CGFloat)height
{
    self.chatMessageVC.view.frameHeight = viewHeight - height;
    self.chatBoxVC.view.originY = self.chatMessageVC.view.originY + self.chatMessageVC.view.frameHeight;
    [self.chatMessageVC scrollToBottom];
}

#pragma mark - Getter and Setter
- (void) setUser:(TLUser *)user
{
    _user = user;
    [self.navigationItem setTitle:user.username];
}

- (TLChatMessageViewContrller *) chatMessageVC
{
    if (_chatMessageVC == nil) {
        _chatMessageVC = [[TLChatMessageViewContrller alloc] init];
        [_chatMessageVC.view setFrame:CGRectMake(0, HEIGHT_STATUSBAR + HEIGHT_NAVBAR, WIDTH_SCREEN, viewHeight - HEIGHT_TABBAR)];
        [_chatMessageVC setDelegate:self];
    }
    return _chatMessageVC;
}

- (TLChatBoxViewController *) chatBoxVC
{
    if (_chatBoxVC == nil) {
        _chatBoxVC = [[TLChatBoxViewController alloc] init];
        [_chatBoxVC.view setFrame:CGRectMake(0, HEIGHT_SCREEN - HEIGHT_TABBAR, WIDTH_SCREEN, HEIGHT_SCREEN)];
        [_chatBoxVC setDelegate:self];
    }
    return _chatBoxVC;
}

- (void)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMMessageType)conversationType
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    [[EaseMob sharedInstance].callManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
    
    //开始新建会话/获取会话列表
    conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:conversationChatter conversationType:conversationType];
    
    textview= [[UITextView alloc] initWithFrame:CGRectMake(0, 64, WIDTH_SCREEN, 200)];
    [self.view addSubview:textview];
    textview.backgroundColor = [UIColor grayColor];
    
    //先请求了照相隐私
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus==AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {//请求访问照相功能.
            if(granted){//点击允许访问时调用
                //用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                NSLog(@"Granted access to %@", mediaType);
                
            }
            else {
                NSLog(@"Not granted access to %@", mediaType);
            }
        }];
        
    }
    
    //给对话框赋值,填充之前的聊天记录.
    [self addWithConversationChatter:conversationChatter conversationType:conversationType];
}

//加载当前用户的会话
- (void)addWithConversationChatter:(NSString *)conversationChatter
                  conversationType:(EMConversationType)conversationType{
    //从会话管理者中获得当前会话.
    EMConversation *conversation2 =  [[EaseMob sharedInstance].chatManager conversationForChatter:conversationChatter conversationType:conversationType] ;
    
    //conversation
    NSString * context = @"";//用于制作对话框中的内容.(现在还没有分自己发送的还是别人发送的.)
    NSArray * arrcon;
    NSArray * arr;
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;//制作时间戳
    arr = [conversation2 loadAllMessages]; // 获得内存中所有的会话.
    arrcon = [conversation2 loadNumbersOfMessages:10 before:timestamp]; //根据时间获得5调会话. (时间戳作用:获得timestamp这个时间以前的所有/5会话)
    
    //    for (EMMessage * hehe in arrcon) {
    //        id<IEMMessageBody> messageBody = [hehe.messageBodies firstObject];
    //        NSString *messageStr = nil;
    //        messageStr = ((EMTextMessageBody *)messageBody).text;
    //        //        [context stringByAppendingFormat:@"%@",messageStr ];
    //
    //        if (![hehe.from isEqualToString:_user.username]) {//如果是自己发送的.
    //            context = [NSString stringWithFormat:@"%@\n\t\t\t\t\t我说:%@",context,messageStr];
    //        }else{
    //            context = [NSString stringWithFormat:@"%@\n%@",context,messageStr];
    //        }
    //
    //    }
    
    textview.text = context;
}

-(void)dealloc{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
}




@end

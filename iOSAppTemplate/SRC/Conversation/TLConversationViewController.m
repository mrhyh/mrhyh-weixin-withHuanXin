//
//  TLConversationViewController.m
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import "TLConversationViewController.h"
#import "TLFriendSearchViewController.h"
#import "TLChatViewController.h"
#import "TLConversationCell.h"
#import "EMConversation.h"
#import "EaseMob.h"

@interface TLConversationViewController () <UISearchBarDelegate, IChatManagerDelegate, EMCallManagerDelegate>
{
    NSString * mes;
    //    EMConversation *conversation;
    UILabel * unreadLabel;
    
    dispatch_queue_t _messageQueue;
    
    UITextField * sendToUser;
    
    UITableView * mytableview;
    
    NSMutableArray * huihuaArray;
}

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) TLFriendSearchViewController *searchVC;
@property (nonatomic, strong) TLChatViewController *chatVC;
@property (nonatomic, strong) UIBarButtonItem *navRightButton;

@property (strong, nonatomic) EMConversation *conversation;//会话管理者
@property (strong, nonatomic) NSMutableArray *messages;
@property (nonatomic) BOOL isPlayingAudio;//判断是否已经播放了音频

@end

@implementation TLConversationViewController

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadRecentConversation];
    // 添加观察者  注册当属性发生改变的时候被调用的
    [unreadLabel addObserver:self forKeyPath:@"unreadLabel" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self setHidesBottomBarWhenPushed:NO];
    [self.navigationItem setTitle:@"消息"];
    [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    
    [self initHuanXin];
    
    // subView
    [self.navigationItem setRightBarButtonItem:self.navRightButton]; // nav菜单
    [self.tableView setTableHeaderView:self.searchController.searchBar];
    [self.tableView registerClass:[TLConversationCell class] forCellReuseIdentifier:@"ConversationCell"];
    
    // data
    //_data = [self getTestData];
    
    unreadLabel= [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 50, 30)];
    unreadLabel.text = @"测试";
    unreadLabel.backgroundColor = [UIColor yellowColor];
    [unreadLabel setTextColor:[UIColor blackColor]];
    //[self.view addSubview:unreadLabel];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setHidesBottomBarWhenPushed:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"ConversationCell";
    TLConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    
    if (cell == nil) {
        cell = [[TLConversationCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identify];
    }
    
//    @property (nonatomic, strong) NSString *from;
//    @property (nonatomic, strong) NSDate *date;
//    @property (nonatomic, strong) NSString *message;
//    @property (nonatomic, assign) NSUInteger messageCount;
//    @property (nonatomic, strong) NSURL *avatarURL;
    
    EMConversation *conversation = [_data objectAtIndex:indexPath.row];
    //cell.nameString = conversation.chatter;
    cell.from = conversation.chatter;
    cell.messageCount = [conversation unreadMessagesCount];
    
    NSLog(@"chatter = %@",conversation.chatter);
    if (conversation.conversationType == eConversationTypeChat) {
        
    }else{
        NSString *imageName = @"groupPublicHeader";
        if (![conversation.ext objectForKey:@"groupSubject"] || ![conversation.ext objectForKey:@"isPublic"]){
            NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.chatter]) {
                    cell.conversation.from = group.groupSubject;
                    imageName = group.isPublic ? @"groupPublicHeader" : @"groupPrivateHeader";
                    
                    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                    [ext setObject:group.groupSubject forKey:@"groupSubject"];
                    [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                    conversation.ext = ext;
                    break;
                    
                } else {
                    
                    cell.conversation.from = [conversation.ext objectForKey:@"groupSubject"];
                    imageName = [[conversation.ext objectForKey:@"isPublic"] boolValue] ? @"groupPublicHeader" : @"groupPrivateHeader";
                }
                //cell.placeholderImage = [UIImage imageNamed:imageName];
                cell.conversation.avatarURL = [NSURL URLWithString:@"10.jpeg"];

            }
        }
    }
    
    cell.conversation.messageCount = [self unreadMessageCountByConversation:conversation];
    
    //[cell setConversation:_data[indexPath.row]];
    [cell setTopLineStyle:CellLineStyleNone];
    if (indexPath.row == _data.count - 1) {
        [cell setBottomLineStyle:CellLineStyleFill];
    }
    else {
        [cell setBottomLineStyle:CellLineStyleDefault];
    }
    return cell;
    

}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        EMConversation *conversation = [_data objectAtIndex:indexPath.row];
        
        [_data removeObjectAtIndex:indexPath.row];
        [[EaseMob sharedInstance].chatManager removeConversationByChatter:conversation.chatter deleteMessages:YES append2Chat:YES];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 63;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获得点中的会话对象.
    EMConversation *conversation = [_data objectAtIndex:indexPath.row];
    
    //EMConversation *_conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:conversationChatter conversationType:conversationType];
    
    [conversation markAllMessagesAsRead:YES];
    
    if (_chatVC == nil) {
        _chatVC = [[TLChatViewController alloc] init];
    }

    TLUser *user7 = [[TLUser alloc] init];
    user7.eMmessageType = (EMMessageType)conversation.conversationType;
    user7.userID = @"XB";
    user7.nikename = @"小贝";
    user7.avatarURL = @"10.jpeg";
    
    if (conversation.conversationType == eConversationTypeChat) {
        user7.username = conversation.chatter;
    }else if (conversation.conversationType == eConversationTypeGroupChat){
        
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *group in groupArray) {
            if ([group.groupId isEqualToString:conversation.chatter]) {
                user7.username = group.groupSubject;
                NSLog(@"groupID =%@",group.groupId);
                user7.username = group.groupId;
                break;
            }
        }
    }else{ //聊天室
        
    }
    
    _chatVC.user = user7;
    
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
    
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:_chatVC animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

-(void)refreshDataSource
{
    //    huihuaArray = huihuaArray;
    [self.tableView reloadData];
}

#pragma mark - Event Response
- (void) navRightButtonDown
{
    
}

#pragma mark - Private Methods
- (NSMutableArray *) getTestData
{
    NSMutableArray *models = [[NSMutableArray alloc] initWithCapacity:20];
    
    TLConversation *item1 = [[TLConversation alloc] init];
    item1.from = [NSString stringWithFormat:@"莫小贝"];
    item1.message = @"帅哥你好！！";
    item1.avatarURL = [NSURL URLWithString:@"10.jpeg"];
    item1.date = [NSDate date];
    [models addObject:item1];
    
    return models;
}

#pragma mark - UISearchBarDelegate

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.tabBarController.tabBar setHidden:YES];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tabBarController.tabBar setHidden:NO];
}

#pragma mark - Getter and Setter
- (UIBarButtonItem *) navRightButton
{
    if (_navRightButton == nil) {
        _navRightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"barbuttonicon_add"] style:UIBarButtonItemStylePlain target:self action:@selector(navRightButtonDown)];
    }
    return _navRightButton;
}

- (TLFriendSearchViewController *) searchVC
{
    if (_searchVC == nil) {
        _searchVC = [[TLFriendSearchViewController alloc] init];
    }
    return _searchVC;
}

- (UISearchController *) searchController
{
    if (_searchController == nil) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:_searchVC];
        [_searchController setSearchResultsUpdater: self.searchVC];
        [_searchController.searchBar setPlaceholder:@"搜索"];
        [_searchController.searchBar setBarTintColor:DEFAULT_SEARCHBAR_COLOR];
        [_searchController.searchBar sizeToFit];
        [_searchController.searchBar setDelegate:self];
        [_searchController.searchBar.layer setBorderWidth:0.5f];
        [_searchController.searchBar.layer setBorderColor:WBColor(220, 220, 220, 1.0).CGColor];
    }
    return _searchController;
}

- (void) initHuanXin{
    //    初始化
    _isPlayingAudio = NO;
    _data = [[NSMutableArray alloc] init];
    
    //    NSArray *cons2  =[[[EaseMob sharedInstance] chatManager] conversations];//从内存中读取列表
    //获取会话列表
    NSArray *cons1 = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    
    [_data addObjectsFromArray:cons1];
    
#warning 以下三行代码必须写，注册为SDK的ChatManager的delegate
    //    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
#warning 把self注册为SDK的delegate
    [self registerNotifications];
    
#pragma mark - 注册消息中心,当call view消失以后就会启动这个方法.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callControllerClose:) name:@"callControllerClose" object:nil];
    [self removeEmptyConversationsFromDB];
}

-(void)registerNotifications
{
    [self unregisterNotifications];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    [[EaseMob sharedInstance].callManager removeDelegate:self];
}

#pragma  mark -处理会话信息.
//处理会话信息.
- (void)handleCallNotification:(NSNotification *)notification
{
    id object = notification.object;
    if ([object isKindOfClass:[NSDictionary class]]) {
        //开始call
        self.isInvisible = YES;
    }
    else
    {
        //结束call
        self.isInvisible = NO;
    }
}

// 得到未读消息条数
- (NSInteger)unreadMessageCountByConversation:(EMConversation *)conversation
{
    NSInteger ret = 0;
    ret = conversation.unreadMessagesCount;
    
    return  ret;
}

#pragma mark - 1
// 未读消息数量变化回调
-(void)didUnreadMessagesCountChanged
{
    [self setupUnreadMessageCount];
}

-(void)setupUnreadMessageCount
{
    //将没有阅读的会话加入到数组中
    NSArray *conversations = [[[EaseMob sharedInstance] chatManager] conversations];
    NSInteger unreadCount = 0;
    [_data removeAllObjects];
    [_data addObjectsFromArray:conversations];
    
    [self.tableView reloadData];
    //conversation
    for (EMConversation *conversation1 in conversations) {
        unreadCount += conversation1.unreadMessagesCount;
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
    
    unreadLabel.text =[NSString stringWithFormat:@"%i",(int)unreadCount];
}

- (void) loadRecentConversation{
    [self didUnreadMessagesCountChanged];
}

- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    NSMutableArray *needRemoveConversations;
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.conversationType == eConversationTypeChatRoom)) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation.chatter];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count > 0) {
        [[EaseMob sharedInstance].chatManager removeConversationsByChatters:needRemoveConversations
                                                             deleteMessages:YES
                                                                append2Chat:NO];
    }
}


@end
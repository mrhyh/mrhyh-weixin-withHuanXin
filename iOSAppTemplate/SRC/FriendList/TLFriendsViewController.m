//
//  TLFriendsViewController.m
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import "TLFriendsViewController.h"
#import "TLDataHelper.h"
#import "TLUIHelper.h"

#import "TLFriendSearchViewController.h"
#import "TLAddFriendViewController.h"
#import "TLDetailsViewController.h"

#import "TLFriendCell.h"
#import "TLFriendHeaderView.h"
#import "EaseMob.h"
#import "GroupListViewController.h"

#import "ApplyViewController.h"
#import "TLChatViewController.h"
#import "UIViewController+HUD.h"


@interface TLFriendsViewController () <UISearchBarDelegate, IChatManagerDelegate, EMCallManagerDelegate>

@property (nonatomic, strong) TLSettingGrounp *functionGroup;     // 功能列表

@property (nonatomic, strong) UIBarButtonItem *addFriendButton;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UILabel *footerLabel;

@property (nonatomic, strong) TLAddFriendViewController *addFriendVC;
@property (nonatomic, strong) TLFriendSearchViewController *searchVC;
@property (nonatomic, strong) TLDetailsViewController *detailsVC;


@property (nonatomic, strong) NSArray *buddyList; //好友
@property (nonatomic, strong) NSArray *blockedList; //黑名单

@property (nonatomic) NSInteger unapplyCount;

@end

@implementation TLFriendsViewController

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initHuanXin];
    
    [self setHidesBottomBarWhenPushed:NO];
    [self.navigationItem setTitle:@"通讯录"];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setSeparatorStyle: UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
    [self.tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    [self.tableView setSectionIndexColor:DEFAULT_NAVBAR_COLOR];
    
    // SubViews
    [self.tableView registerClass:[TLFriendCell class] forCellReuseIdentifier:@"FriendCell"];
    [self.tableView registerClass:[TLFriendHeaderView class] forHeaderFooterViewReuseIdentifier:@"WBFriendHeaderView"];
    [self.tableView setTableHeaderView:self.searchController.searchBar];
    [self.tableView setTableFooterView:self.footerLabel];
    
    [self.navigationItem setRightBarButtonItem:self.addFriendButton];
    
    _friendsArray = [[NSMutableArray alloc] initWithCapacity:0];
    [self reloadDataSource];
    
    /*先从内存加载数据*/
    //1. 取内存中的好友 该方法比较特殊，只有在您之前获取过好友列表的情况下才会有值，且不能保证最新。
     _buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    
    //2. 取内存中的黑名单
    _blockedList = [[EaseMob sharedInstance].chatManager blockedList];
    
    [self reloadDataSource];
    
    /*从网络异步加载数据*/
    
    // 1. 异步加载好友数据
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        if (!error) {
            NSLog(@"获取好友成功 -- %@",buddyList);
#warning 应该先将数组清空
            _buddyList = buddyList;
            
            // 2. 异步加载黑名单
            [[EaseMob sharedInstance].chatManager asyncFetchBlockedListWithCompletion:^(NSArray *blockedList, EMError *error) {
                if (!error) {
                    NSLog(@"获取黑名单成功 -- %@",blockedList);
                    _blockedList = blockedList;
                    [self reloadDataSource];
                }
            } onQueue:nil];
            
        }
    } onQueue:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadApplyView];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self setHidesBottomBarWhenPushed:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return _data.count + 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _functionGroup.itemsCount;
    }
    NSArray *array = [_data objectAtIndex:section - 1];
    return array.count;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    TLFriendHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"WBFriendHeaderView"];
    [view setTitle:[self.section objectAtIndex:section]];
    return view;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    if (indexPath.section == 0) {
        TLSettingItem *item = [_functionGroup itemAtIndex:indexPath.row];
        TLUser *user = [[TLUser alloc] init];
        user.username = item.title;
        user.avatarURL = item.imageName;
        [cell setUser:user];
        [cell setTopLineStyle:CellLineStyleNone];
        cell.avatarView.badge = self.unapplyCount;
        cell.unreadCount = 3;
        
        indexPath.row == _functionGroup.itemsCount - 1 ? [cell setBottomLineStyle:CellLineStyleNone] :[cell setBottomLineStyle:CellLineStyleDefault];
    }
    else {
        NSArray *array = [_data objectAtIndex:indexPath.section - 1];
        TLUser *user = [array objectAtIndex:indexPath.row];
        [cell setUser:user];
        [cell setTopLineStyle:CellLineStyleNone];
        
        if (indexPath.row == array.count - 1) {
            indexPath.section == _data.count ? [cell setBottomLineStyle:CellLineStyleFill] :[cell setBottomLineStyle:CellLineStyleNone];
        }
        else {
            [cell setBottomLineStyle:CellLineStyleDefault];
        }
    }
    
    return cell;
}

// 拼音首字母检索
- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _section;
}

// 检索时空出搜索框
- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if(index == 0) {
        [self.tableView scrollRectToVisible:_searchController.searchBar.frame animated:NO];
        return -1;
    }
    return index;
}

#pragma mark - UITableViewDelegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.5f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 22.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if(indexPath.row == 0){ //申请与通知
            
            [self.navigationController pushViewController:[ApplyViewController shareController] animated:YES];

        }else if (indexPath.row == 1){ //群组
            
            GroupListViewController *groupListVC = [[GroupListViewController alloc] init];
            [self setHidesBottomBarWhenPushed:YES];
            [self.navigationController pushViewController:groupListVC animated:YES];
            
        }else if (indexPath.row == 2){ //聊天室列表
        
        }
    }
    else {
        
        //仿微信原跳转界面
//        NSArray *array = [_data objectAtIndex:indexPath.section - 1];
//        self.detailsVC.user = [array objectAtIndex:indexPath.row];;
//        [self setHidesBottomBarWhenPushed:YES];
//        [self.navigationController pushViewController:self.detailsVC animated:YES];
        
        //获得点中的会话对象.
        NSArray *array = [_data objectAtIndex:indexPath.section - 1];
        TLUser *user = [array objectAtIndex:indexPath.row];
        EMConversation *conversation = [_data objectAtIndex:indexPath.row];
        TLChatViewController *_chatVC;
        
        if (_chatVC == nil) {
            _chatVC = [[TLChatViewController alloc] init];
        }
        
        TLUser *user7 = [[TLUser alloc] init];
        //NSLog(@"conversation.conversationType =%ld", (long)conversation.conversationType);
        //user7.eMmessageType = (EMMessageType)conversation.conversationType;
        user7.eMmessageType = eMessageTypeChat;
        user7.userID = @"XB";
        user7.nikename = @"小贝";
        user7.avatarURL = @"10.jpeg";
        user7.username = user.username;
        
        _chatVC.user = user7;
        
        [[EaseMob sharedInstance].chatManager removeDelegate:self];
        [[EaseMob sharedInstance].callManager removeDelegate:self];
        
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:_chatVC animated:YES];
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        

    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
        NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
        
        NSArray *array = [_data objectAtIndex:indexPath.section - 1];
        TLUser *user = [array objectAtIndex:indexPath.row];
        //EMConversation *conversation = [_data objectAtIndex:indexPath.row];
        
        if ([user.username isEqualToString:loginUsername]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"friend.notDeleteSelf", @"can't delete self") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
        }
        
        EMError *error = nil;
        [[EaseMob sharedInstance].chatManager removeBuddy:user.username removeFromRemote:YES error:&error];
        if (!error) {
            [[EaseMob sharedInstance].chatManager removeConversationByChatter:user.username deleteMessages:YES append2Chat:YES];
            
            [tableView beginUpdates];
            [[_data objectAtIndex:(indexPath.section - 1)] removeObjectAtIndex:indexPath.row];
            [_data removeObject:user];
            [tableView  deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView  endUpdates];
        }
        else{
            [self showHint:[NSString stringWithFormat:NSLocalizedString(@"deleteFailed", @"Delete failed:%@"), error.description]];
            [tableView reloadData];
        }
    }
}

#pragma mark - UISearchBarDelegate
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    _searchVC.friendsArray = self.friendsArray;
    [self.tabBarController.tabBar setHidden:YES];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tabBarController.tabBar setHidden:NO];
}

#pragma mark - Event Response
- (void) addFriendButtonDown
{
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:self.addFriendVC animated:YES];
}

#pragma mark - Getter and Setter
- (UIBarButtonItem *) addFriendButton
{
    if (_addFriendButton == nil) {
        _addFriendButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"contacts_add_friend"] style:UIBarButtonItemStylePlain target:self action:@selector(addFriendButtonDown)];
    }
    return _addFriendButton;
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
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self.searchVC];
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

- (UILabel *) footerLabel
{
    if (_footerLabel == nil) {
        _footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, WIDTH_SCREEN, 49.0f)];
        [_footerLabel setBackgroundColor:[UIColor whiteColor]];
        [_footerLabel setTextColor:[UIColor grayColor]];
        [_footerLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _footerLabel;
}

- (TLAddFriendViewController *) addFriendVC
{
    if (_addFriendVC == nil) {
        _addFriendVC = [[TLAddFriendViewController alloc] init];
    }
    return _addFriendVC;
}

- (TLDetailsViewController *) detailsVC
{
    if (_detailsVC == nil) {
        _detailsVC = [[TLDetailsViewController alloc] init];
    }
    return _detailsVC;
}


- (void)reloadDataSource
{
    [self.friendsArray removeAllObjects];
    
    //将黑名单中的人从好友名单删除
    for (EMBuddy *buddy in _buddyList) {
        if (![_blockedList containsObject:buddy.username]) {
            
            TLUser *user1 = [[TLUser alloc] init];
            user1.username = buddy.username;
            user1.nikename = @"测试";
            user1.userID = @"Testing";
            user1.avatarURL = @"1.jpg";
            [_friendsArray addObject:user1];
        }
    }
    
//    NSDictionary *loginInfo = [[[EaseMob sharedInstance] chatManager] loginInfo];
//    NSString *loginUsername = [loginInfo objectForKey:kSDKUsername];
//    if (loginUsername && loginUsername.length > 0) {
//        EMBuddy *loginBuddy = [EMBuddy buddyWithUsername:loginUsername];
//        
//        [self.friendsArray addObject:loginBuddy];
//    }
    
    //排序
    _data = [TLDataHelper getFriendListDataBy:_friendsArray];
    //[self _sortDataArray:self.friendsArray];
    
    _functionGroup = [TLUIHelper getFriensListItemsGroup];
    
    _data = [TLDataHelper getFriendListDataBy:_friendsArray];
    _section = [TLDataHelper getFriendListSectionBy:_data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [_footerLabel setText:[NSString stringWithFormat:@"%lu位联系人", (unsigned long)_friendsArray.count]];
    });
    
    [self.tableView reloadData];
}

- (void)initHuanXin{
#warning 以下三行代码必须写，注册为SDK的ChatManager的delegate
    //    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
#warning 把self注册为SDK的delegate
    [self registerNotifications];
    
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

- (void)reloadApplyView
{
    NSInteger count = [[[ApplyViewController shareController] dataSource] count];
    self.unapplyCount = count;
    [self.tableView reloadData];
}

- (void)reloadGroupView
{
    [self reloadApplyView];
    
    if (_tlFriendsVC) {
        [_tlFriendsVC reloadDataSource];
    }
}

@end

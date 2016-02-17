//
//  TLAddFriendViewController.m
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/16.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import "TLAddFriendViewController.h"
#import <EaseMob.h>
#import "UIViewController+HUD.h"

@interface TLAddFriendViewController ()

@property(nonatomic, strong)UITextField *userNameTextField;//用户名

@end

@implementation TLAddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"添加好友"];
    
    UILabel *usernameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 100, 80, 50)];
    usernameLabel.text = @"用户名";
    usernameLabel.font = [UIFont systemFontOfSize:25];
    [self.view addSubview:usernameLabel];
    
    _userNameTextField = [[UITextField alloc]initWithFrame:CGRectMake(usernameLabel.frame.origin.x + usernameLabel.frame.size.width + 10, usernameLabel.frame.origin.y, 250, 50)];
    _userNameTextField.borderStyle = 3;
    _userNameTextField.placeholder = @"请输入用户名";
    [self.view addSubview:_userNameTextField];
    
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    addButton.frame = CGRectMake(170, 300, 50, 50);
    addButton.titleLabel.font = [UIFont systemFontOfSize:25];
    [addButton setTitle:@"添加" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(didClickAddButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addButton];
}

-(void)didClickAddButton
{
    EMError * error;
    BOOL isSuccess = [[EaseMob sharedInstance].chatManager addBuddy:_userNameTextField.text message:@"我想加您为好友" error:&error];
    //__weak UIPageViewController *weakSelf = self;
    
    [self showHudInView:self.view hint:@"加友消息发送成功！"];
    if (isSuccess && !error) {
        
        NSLog(@"添加成功");
        [self performSelector:@selector(delayAction) withObject:nil afterDelay:1.0f];
        
    } else{
        NSLog(@"%@",error);
    }
    
}

- (void)delayAction{
    __weak UIPageViewController *weakSelf = self;
    [weakSelf hideHud];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

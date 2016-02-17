//
//  TLSettingViewController.m
//  iOSAppTemplate
//
//  Created by 李伯坤 on 15/9/30.
//  Copyright (c) 2015年 lbk. All rights reserved.
//

#import "TLSettingViewController.h"
#import "TLNewsNotiViewController.h"
#import "LoginViewController.h"
#import "EaseMob.h"
#import "UIViewController+HUD.h"

#import "TLUIHelper.h"

@interface TLSettingViewController() <UIActionSheetDelegate>
{
    
}
@end

@implementation TLSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"设置"];
    
    self.data = [TLUIHelper getSettingVCItems];
}


#pragma mark - UITableViewDelegate
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLSettingGrounp *group = [self.data objectAtIndex:indexPath.section];
    TLSettingItem *item = [group itemAtIndex: indexPath.row];
    if ([item.title isEqualToString:@"新消息通知"]) {
        TLNewsNotiViewController *newsNotiVC = [[TLNewsNotiViewController alloc] init];
        [self.navigationController pushViewController:newsNotiVC animated:YES];
    }
    
    if ([item.title isEqualToString:@"退出登录"]) {
        [self outPut];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)outPut{
    NSLog(@"退出登录...");
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"退出不会删除账号信息"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:@"退出"
                                  otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIBarStyleDefault;
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        [self showHudInView:self.view hint:@"正在退出..."];
        
        EMError *error = nil;
        NSDictionary *info = [[EaseMob sharedInstance].chatManager logoffWithUnbindDeviceToken:YES/NO error:&error];
        if (!error && info) {
            NSLog(@"退出成功");
            
            __weak UIPageViewController *weakSelf = self;
            [weakSelf hideHud];
            
            LoginViewController *LoginVC = [[LoginViewController alloc] init];
            [self.navigationController presentViewController:LoginVC animated:YES completion:nil];
        }
        
    }else if (buttonIndex == 1) {
         NSLog(@"取消");
    }
}

@end

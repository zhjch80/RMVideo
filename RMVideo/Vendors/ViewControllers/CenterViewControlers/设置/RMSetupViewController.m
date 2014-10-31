//
//  RMSetupViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMSetupViewController.h"
#import "UtilityFunc.h"
#import "RMSetUpTableViewCell.h"
#import "RMMyDownLoadViewController.h"
#import "AESCrypt.h"
#import "RMDownMoreViewController.h"
#import "RMVideoPlayHistoryViewController.h"
#import "RMUserFeedbackViewController.h"
#import "RMAboutAppViewController.h"
#import "RMMoreAppViewController.h"
#import "RMLoginViewController.h"
#import "UMSocial.h"

@interface RMSetupViewController ()

@end

@implementation RMSetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"设置";
    
    leftBarButton.hidden = YES;
    rightBarButton.frame = CGRectMake(0, 0, 35, 20);
    [rightBarButton setBackgroundImage:LOADIMAGE(@"cancle_btn_image", kImageTypePNG) forState:UIControlStateNormal];
    dataArray = [NSMutableArray arrayWithArray:@[@[@"我的收藏",@"我的下载",@"播放历史"],@[@"用户反馈",@"清理缓存"],@[@"关于",@"分享给朋友",@"去给评分",@"更多应用"]]];
    
    [self loadCustomView];
    
}

- (void)loadCustomView {
    UIView * headTableView = [[UIView alloc] init];
    headTableView.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1];
    headTableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 10);
    mainTableView.tableHeaderView = headTableView;

}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0)
        return 3;
    else if (section==1)
        return 2;
    else
        return 4;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"IDENTIFIER";
    RMSetUpTableViewCell *cell = [mainTableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[NSBundle mainBundle]loadNibNamed:@"RMSetUpTableViewCell" owner:self options:nil]lastObject];
        if(indexPath.section==1&&indexPath.row==1){
            cell.subtitleString.text = @"18.8M";
        }
        if(indexPath.section==0){
            cell.backgroundColor = [UtilityFunc colorWithHexString:@"#E1DECE"];
            cell.cellTItleString.textColor = [UIColor redColor];
            cell.cellAccessoryTypeImage.image = [UIImage imageNamed:@"cell_accessoryType_red"];
        }
        else{
            cell.backgroundColor = [UIColor whiteColor];
            cell.cellTItleString.textColor = [UtilityFunc colorWithHexString:@"#9D9D9D"];
            cell.cellAccessoryTypeImage.image = [UIImage imageNamed:@"cell_accessoryType_white"];
        }
        cell.cellTItleString.text = [[dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section{
    return 15.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                    //我的收藏
                case 0:{
                    __unsafe_unretained RMSetupViewController *unSafeSelf = self;
                    RMDownMoreViewController *moreVC = [[RMDownMoreViewController alloc] init];
                    [unSafeSelf.navigationController pushViewController:moreVC animated:YES];
                }
                    break;
                    //我的下载
                case 1:{
                    RMMyDownLoadViewController *downLoadViewContro = [[RMMyDownLoadViewController alloc] init];
                    [self.navigationController pushViewController:downLoadViewContro animated:YES];
                    //[[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
                }
                    break;
                    //播放历史
                case 2:{
                    RMVideoPlayHistoryViewController *playHistory = [[RMVideoPlayHistoryViewController alloc] init];
                    [self.navigationController pushViewController:playHistory animated:YES];
                    //[[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
                    
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:{
            switch (indexPath.row) {
                    //用户反馈
                case 0:{
                    RMUserFeedbackViewController *userFeedback = [[RMUserFeedbackViewController alloc] init];
                     [self.navigationController pushViewController:userFeedback animated:YES];
                }
                    break;
                    //清理缓存
                case 1:{
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:{
            switch (indexPath.row) {
                    //关于
                case 0:{
                    RMAboutAppViewController *aboutContro = [[RMAboutAppViewController alloc] init];
                    [self.navigationController pushViewController:aboutContro animated:YES];
                }
                    break;
                    //分享给朋友
                case 1:{}
                    break;
                    //评分
                case 2:{
                    
                }
                    break;
                    //更多应用
                case 3:{
                    RMMoreAppViewController *moreControl = [[RMMoreAppViewController alloc] init];
                    [self.navigationController pushViewController:moreControl animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}

-(IBAction)loginOrExitButtonClick:(UIButton *)sender{
    //登录
    if(sender.tag == 1){
        RMLoginViewController *loginControl = [[RMLoginViewController alloc] init];
        [self.navigationController pushViewController:loginControl animated:YES];
    }
    //退出登录
    else if(sender.tag ==2){
        [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToSina  completion:^(UMSocialResponseEntity *response){
            NSLog(@"response is %@",response);
        }];
        [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToTencent  completion:^(UMSocialResponseEntity *response){
            NSLog(@"response is %@",response);
        }];
    }
}

#pragma mrak - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            break;
        }
        case 2:{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
            break;
        }

        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

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
#import "SDImageCache.h"
#import <StoreKit/StoreKit.h>
#import "RMMoreWonderfulViewController.h"
#import "RMCustomNavViewController.h"
#import "RMCustomPresentNavViewController.h"

@interface RMSetupViewController ()<UMSocialUIDelegate,SKStoreProductViewControllerDelegate>

@end

@implementation RMSetupViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_Setup" timed:YES];

    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSString * loginStatus = [AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD];
    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
    //已登录
    if([loginStatus isEqualToString: @"islogin"]){
        mainTableView.frame = CGRectMake(mainTableView.frame.origin.x, mainTableView.frame.origin.y, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight-44-44-49);
        self.exitbtn.hidden = NO;
        self.loginBtn.hidden = YES;
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:@"HeadImageURL"]] placeholderImage:LOADIMAGE(@"user_head_Image", kImageTypePNG)];
        self.userNameLable.text = [dict objectForKey:@"userName"];
    }
    //未登录
    else{
        mainTableView.frame = CGRectMake(mainTableView.frame.origin.x, mainTableView.frame.origin.y, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight-44-44);
        self.exitbtn.hidden = YES;
        self.loginBtn.hidden = NO;
        [self.headImageView setImage:LOADIMAGE(@"user_head_Image", kImageTypePNG)];
        self.userNameLable.text = @"";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_Setup" withParameters:nil];
}

#pragma mark - 登录后即推荐

- (void)loginSuccessRecommendmethod {
    RMMoreWonderfulViewController * moreWonderfulCtl = [[RMMoreWonderfulViewController alloc] init];
    RMCustomPresentNavViewController * moreWonderfulNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:moreWonderfulCtl];
    [self presentViewController:moreWonderfulNav animated:YES completion:^{
    }];
    [moreWonderfulCtl setupNavTitle:@"你可能喜欢的内容" SwitchingBarButtonDirection:@"right"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessRecommendmethod) name:@"loginSuccessRecommendmethod" object:nil];
    
    self.title = @"设置";
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = 15;
    leftBarButton.hidden = YES;
    rightBarButton.frame = CGRectMake(0, 0, 35, 20);
    [rightBarButton setBackgroundImage:LOADIMAGE(@"cancle_btn_image", kImageTypePNG) forState:UIControlStateNormal];

    self.headView.frame = CGRectMake(self.headView.frame.origin.x, self.headView.frame.origin.y, [UtilityFunc shareInstance].globleWidth, self.headView.frame.size.height);
    self.loginBtn.frame = CGRectMake([UtilityFunc shareInstance].globleWidth-18-self.loginBtn.frame.size.width, self.loginBtn.frame.origin.y, self.loginBtn.frame.size.width, self.loginBtn.frame.size.height);
    self.exitbtn.frame = CGRectMake(0, [UtilityFunc shareInstance].globleHeight-49-44, [UtilityFunc shareInstance].globleWidth, 49);
    
    dataArray = [NSMutableArray arrayWithArray:@[@[@"我的收藏",@"我的缓存",@"播放历史"],@[@"用户反馈",@"清理缓存"],@[@"关于",@"分享给朋友",@"去给评分",@"更多应用"]]];
    
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
            float tmpSize = [[SDImageCache sharedImageCache] getSize];
            NSString *clearCacheName = tmpSize >= 1 ? [NSString stringWithFormat:@"%.2fM",tmpSize/1024.0/1024.0] : [NSString stringWithFormat:@"0.0M"];
            cell.subtitleString.text = clearCacheName;
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
                    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
                    if (![[AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD] isEqualToString:@"islogin"]){
                        RMLoginViewController * loginCtl = [[RMLoginViewController alloc] init];
                        RMCustomPresentNavViewController * loginNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:loginCtl];
                        [self presentViewController:loginNav animated:YES completion:^{
                        }];
                        return;
                    }
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
                    [SVProgressHUD showWithStatus:@"清理中" maskType:SVProgressHUDMaskTypeClear];
                    [self performSelector:@selector(clearImageMemory) withObject:nil afterDelay:1];
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
                case 1:{
                    [SVProgressHUD showWithStatus:@"请稍后..." maskType:SVProgressHUDMaskTypeBlack];
                    [self performSelector:@selector(willStartShare) withObject:nil afterDelay:1.0];
                }
                    break;
                    //评分
                case 2:{
                    NSString *evaluateString = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/r-evolve/id%@?mt=8",kAppleId];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:evaluateString]];
                    
//                    //初始化控制器
//                    SKStoreProductViewController *storeProductViewContorller = [[SKStoreProductViewController alloc] init];
//                    //设置代理请求为当前控制器本身
//                    storeProductViewContorller.delegate = self;
//                    //加载一个新的视图展示
//                    [storeProductViewContorller loadProductWithParameters:
//                     //appId唯一的
//                     @{SKStoreProductParameterITunesItemIdentifier : @"id791488575"} completionBlock:^(BOOL result, NSError *error) {
//                         //block回调
//                         if(error){
//                             NSLog(@"error %@ with userInfo %@",error,[error userInfo]);
//                         }else{
//                             //模态弹出appstore
//                             [self presentViewController:storeProductViewContorller animated:YES completion:^{
//                                 
//                             }];
//                         }
//                     }];
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

- (void)willStartShare {
    if ([UtilityFunc isConnectionAvailable] == 0){
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
        return;
    }
    [SVProgressHUD dismiss];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"546f02cefd98c5c6a60041bb"
                                      shareText:@"精彩内容，精准推荐，尽在小花儿视频，你想看的都在这里"
                                     shareImage:nil
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToTencent,nil]
                                       delegate:self];
    
}

- (void)clearImageMemory{
    
    NSLog(@"清理之前个数----%d",[[SDImageCache sharedImageCache] getDiskCount]);
    [[SDImageCache sharedImageCache] clearDisk];
    NSLog(@"清理之后个数----%d",[[SDImageCache sharedImageCache] getDiskCount]);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
    RMSetUpTableViewCell *cell = (RMSetUpTableViewCell *)[mainTableView cellForRowAtIndexPath:indexPath];
    float tmpSize = [[SDImageCache sharedImageCache] getSize];
    NSString *clearCacheName = tmpSize >= 1 ? [NSString stringWithFormat:@"%.2fM",tmpSize/1024.0/1024.0] : [NSString stringWithFormat:@"0.0M"];
    cell.subtitleString.text = clearCacheName;
    [SVProgressHUD dismiss];
}

-(IBAction)loginOrExitButtonClick:(UIButton *)sender{
    //登录
    if(sender.tag == 1){
        RMLoginViewController * loginCtl = [[RMLoginViewController alloc] init];
        RMCustomPresentNavViewController * LoginNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:loginCtl];
        
        [self presentViewController:LoginNav animated:YES completion:^{
            
            
        }];
    }
    //退出登录
    else if(sender.tag ==2){
        [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToSina  completion:^(UMSocialResponseEntity *response){
        }];
        [[UMSocialDataService defaultDataService] requestUnOauthWithType:UMShareToTencent  completion:^(UMSocialResponseEntity *response){
        }];
        CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
        [storage beginUpdates];
        NSString * loginStatus = [AESCrypt encrypt:@"notlogin" password:PASSWORD];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [storage setObject:loginStatus forKey:LoginStatus_KEY];
        [storage setObject:dict forKey:UserLoginInformation_KEY];
        [storage endUpdates];
        mainTableView.frame = CGRectMake(mainTableView.frame.origin.x, mainTableView.frame.origin.y, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight-44-44);
        self.exitbtn.hidden = YES;
        self.loginBtn.hidden = NO;
        [self.headImageView setImage:LOADIMAGE(@"user_head_Image", kImageTypePNG)];
        self.userNameLable.text = @"";
    }
}

#pragma mrak - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            break;
        }
        case 2:{
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
            }
            [self dismissViewControllerAnimated:YES completion:^{
          
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
            break;
        }

        default:
            break;
    }
}
//取消按钮监听
//- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController{
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//    }];
//}

//根据`responseCode`得到发送结果,如果分享成功
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

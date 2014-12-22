//
//  RMLoginViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMLoginViewController.h"
#import "UMSocial.h"
#import "RMGenderTabViewController.h"

@interface RMLoginViewController ()<UMSocialUIDelegate,RMAFNRequestManagerDelegate>
{
    NSString *userName;
    NSString *headImageURLString;
    RMAFNRequestManager *manager;
}
@property (nonatomic, strong) NSArray* btnImgWithTitleArr;
@end

@implementation RMLoginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_Login" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_Login" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"登录"];
    self.btnImgWithTitleArr = [[NSArray alloc] initWithObjects:@"logo_weibo", @"txwb", @"新浪微博登录", @"腾讯微博登录", nil];

    leftBarButton.hidden = YES;
    rightBarButton.frame = CGRectMake(0, 0, 35, 20);
    [rightBarButton setBackgroundImage:LOADIMAGE(@"cancle_btn_image", kImageTypePNG) forState:UIControlStateNormal];
    self.lableTitle.text = [NSString stringWithFormat:@"使用社交账号登录到%@",kAppName];
    manager = [[RMAFNRequestManager alloc] init];
    manager.delegate = self;
}

- (IBAction)buttonMethod:(UIButton *)sender {
    switch (sender.tag) {
        case 101:{
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSString * loginStatus = [AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD];
            loginType = usingSinaLogin;
            BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToSina];
            if(isOauth){
                if([loginStatus isEqualToString: @"islogin"]){
                    [self showAlertView];
                }else{
                    NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
                    UMSocialAccountEntity *sinaAccount = [snsAccountDic valueForKey:UMShareToSina];
                    userName = sinaAccount.userName;
                    headImageURLString = sinaAccount.iconURL;
                    [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeBlack];
                    [manager postLoginWithSourceType:@"4" sourceId:sinaAccount.usid username:[sinaAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:[headImageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
            }
            else{
                UINavigationController *oauthController = [[UMSocialControllerService defaultControllerService] getSocialOauthController:UMShareToSina];
                [self presentViewController:oauthController animated:YES completion:nil];
            }
            [UMSocialControllerService defaultControllerService].socialUIDelegate = self;
            break;
        }
        case 102:{
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSString * loginStatus = [AESCrypt decrypt:[storage objectForKey:LoginStatus_KEY] password:PASSWORD];
            
            loginType = usingTencentLogin;
            BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToTencent];
            if(isOauth){
                if([loginStatus isEqualToString: @"islogin"]){
                    [self showAlertView];
                }else{
                    NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
                    UMSocialAccountEntity *tencentAccount = [snsAccountDic valueForKey:UMShareToTencent];
                    userName = tencentAccount.userName;
                    headImageURLString = tencentAccount.iconURL;
                    [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeBlack];
                    [manager postLoginWithSourceType:@"2" sourceId:tencentAccount.usid username:[tencentAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:[headImageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                }
            }
            else{
                UINavigationController *oauthController = [[UMSocialControllerService defaultControllerService] getSocialOauthController:UMShareToTencent];
                [self presentViewController:oauthController animated:YES completion:nil];
            }
            [UMSocialControllerService defaultControllerService].socialUIDelegate = self;

            break;
        }

        default:
            break;
    }
}

- (void)showAlertView{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该登陆方式已经登录成功了" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alertView show];
}

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
    //授权成功后的回调函数
    if (response.viewControllerType == UMSViewControllerOauth) {
        
        NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
        
        if(loginType == usingTencentLogin){
            BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToTencent];
            if(isOauth){
                UMSocialAccountEntity *tencentAccount = [snsAccountDic valueForKey:UMShareToTencent];
                userName = tencentAccount.userName;
                headImageURLString = tencentAccount.iconURL;
                [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeBlack];
                [manager postLoginWithSourceType:@"2" sourceId:tencentAccount.usid username:[tencentAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:[headImageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }else if ( loginType == usingSinaLogin){
            BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToSina];
            if(isOauth){
                UMSocialAccountEntity *sinaAccount = [snsAccountDic valueForKey:UMShareToSina];
                userName = sinaAccount.userName;
                headImageURLString = sinaAccount.iconURL;
                [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeBlack];
                [manager postLoginWithSourceType:@"4" sourceId:sinaAccount.usid username:[sinaAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:[headImageURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:userName forKey:@"userName"];
    [dict setValue:headImageURLString forKey:@"HeadImageURL"];
    [dict setValue:[data objectAtIndex:0] forKey:@"token"];
     CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
     [storage beginUpdates];
     NSString * loginStatus = [AESCrypt encrypt:@"islogin" password:PASSWORD];
    [storage setObject:dict forKey:UserLoginInformation_KEY];
     [storage setObject:loginStatus forKey:LoginStatus_KEY];
     [storage endUpdates];
    [SVProgressHUD dismiss];
    RMGenderTabViewController *viewContro = [[RMGenderTabViewController alloc] init];
    [self.navigationController pushViewController:viewContro animated:YES];
//    [self performSelector:@selector(dissmissCurrentCtl) withObject:nil afterDelay:1];
}

- (void)requestError:(NSError *)error {
    NSLog(@"error:%@",error);
}

//#pragma mark - 返回上个CTL 并且登录后即推荐
//
//- (void)dissmissCurrentCtl {
//    [SVProgressHUD dismiss];
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
//        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
//    }
//    [self dismissViewControllerAnimated:NO completion:^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccessRecommendmethod" object:nil];
//    }];
//}

#pragma mark - base Method

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

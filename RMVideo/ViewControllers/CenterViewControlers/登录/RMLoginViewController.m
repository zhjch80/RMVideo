//
//  RMLoginViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMLoginViewController.h"
#import "UMSocial.h"
#import "RMCustomNavViewController.h"

@interface RMLoginViewController ()<UMSocialUIDelegate,RMAFNRequestManagerDelegate>
{
    NSString *userName;
    NSString *headImageURLString;
    RMAFNRequestManager *manager;
}
@property (nonatomic, strong) NSArray* btnImgWithTitleArr;
@end

@implementation RMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"登录"];
    self.btnImgWithTitleArr = [[NSArray alloc] initWithObjects:@"logo_weibo", @"logo_qq", @"微博登录", @"QQ登录", nil];

    leftBarButton.hidden = YES;
    rightBarButton.frame = CGRectMake(0, 0, 35, 20);
    [rightBarButton setBackgroundImage:LOADIMAGE(@"cancle_btn_image", kImageTypePNG) forState:UIControlStateNormal];

    
    UILabel* tipTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 50)];
    tipTitle.backgroundColor = [UIColor clearColor];
    tipTitle.text = [NSString stringWithFormat:@"使用社交账号登录到%@",kAppName];
    tipTitle.textAlignment = NSTextAlignmentCenter;
    tipTitle.font = [UIFont systemFontOfSize:16.0];
    tipTitle.textColor = [UIColor colorWithRed:0.16 green:0.16 blue:0.16 alpha:1];
    [self.view addSubview:tipTitle];
    
    UIView* verticalLine = [[UIView alloc] initWithFrame:CGRectMake([UtilityFunc shareInstance].globleWidth/2-0.5, 50, 1, 50)];
    verticalLine.backgroundColor = [UIColor colorWithRed:0.69 green:0.69 blue:0.69 alpha:1];
    [self.view addSubview:verticalLine];
    
    for (int i=0; i<2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake([UtilityFunc shareInstance].globleWidth/4 * (1-i)+ ([UtilityFunc shareInstance].globleWidth/4)*3*i - i*50, 50, 50, 50);
        [button setBackgroundImage:LOADIMAGE([self.btnImgWithTitleArr objectAtIndex:i], kImageTypePNG) forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonMethod:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 101+i;
        button.backgroundColor = [UIColor clearColor];
        [self.view addSubview:button];
        
        UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake([UtilityFunc shareInstance].globleWidth/4 * (1-i)+ ([UtilityFunc shareInstance].globleWidth/4)*3*i - i*50, 100, 100, 40)];
        title.text = [self.btnImgWithTitleArr objectAtIndex:2+i];
        title.textAlignment = NSTextAlignmentLeft;
        title.font = [UIFont systemFontOfSize:14.0];
        title.tag = 201+i;
        title.textColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1];
        title.backgroundColor = [UIColor clearColor];
        [self.view addSubview:title];
    }

    manager = [[RMAFNRequestManager alloc] init];
    manager.delegate = self;
}

- (void)buttonMethod:(UIButton *)sender {
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
    [self performSelector:@selector(dissmissCurrentCtl) withObject:nil afterDelay:1];
}

- (void)requestError:(NSError *)error {
    NSLog(@"error:%@",error);
}

#pragma mark - 返回上个CTL 并且登录后即推荐

- (void)dissmissCurrentCtl {
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:NO completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccessRecommendmethod" object:nil];
    }];
}

#pragma mark - base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{

            break;
        }
        case 2:{
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

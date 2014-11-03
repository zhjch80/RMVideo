//
//  RMLoginViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMLoginViewController.h"
#import "UMSocial.h"
#import "RMAFNRequestManager.h"

@interface RMLoginViewController ()<UMSocialUIDelegate,RMAFNRequestManagerDelegate>
{
    NSString *userName;
    NSString *headImageURLString;
    RMAFNRequestManager *manager;
}
@end
@implementation RMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"登录"];
    
    leftBarButton.hidden = YES;
    rightBarButton.frame = CGRectMake(0, 0, 35, 20);
    [rightBarButton setBackgroundImage:LOADIMAGE(@"cancle_btn_image", kImageTypePNG) forState:UIControlStateNormal];
    self.line.frame = CGRectMake([UtilityFunc shareInstance].globleWidth/2+100, self.line.frame.origin.y, self.line.frame.size.width, self.line.frame.size.height);
    manager = [[RMAFNRequestManager alloc] init];
    manager.delegate = self;

}

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
        
            break;
        }
        case 2:{
            [self.navigationController popViewControllerAnimated:YES];
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

- (IBAction)weiboLogin:(UIButton *)sender {
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
            [manager postLoginWithSourceType:@"4" sourceId:sinaAccount.usid username:[sinaAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:nil];
        }
    }
    else{
        UINavigationController *oauthController = [[UMSocialControllerService defaultControllerService] getSocialOauthController:UMShareToSina];
        [self presentViewController:oauthController animated:YES completion:nil];
    }
    [UMSocialControllerService defaultControllerService].socialUIDelegate = self;

}

- (IBAction)tencentLogin:(UIButton *)sender {
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
            [manager postLoginWithSourceType:@"2" sourceId:tencentAccount.usid username:[tencentAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:nil];
        }
    }
    else{
        UINavigationController *oauthController = [[UMSocialControllerService defaultControllerService] getSocialOauthController:UMShareToTencent];
        [self presentViewController:oauthController animated:YES completion:nil];
    }
    [UMSocialControllerService defaultControllerService].socialUIDelegate = self;
    
}

- (void)showAlertView{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"该登陆方式已经登录成功了" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alertView show];
}
- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
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
                [manager postLoginWithSourceType:@"2" sourceId:tencentAccount.usid username:[tencentAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:nil];
            }
        }else if ( loginType == usingSinaLogin){
            BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToSina];
            if(isOauth){
                UMSocialAccountEntity *sinaAccount = [snsAccountDic valueForKey:UMShareToSina];
                userName = sinaAccount.userName;
                headImageURLString = sinaAccount.iconURL;
                [SVProgressHUD showWithStatus:@"登录中" maskType:SVProgressHUDMaskTypeBlack];
                [manager postLoginWithSourceType:@"4" sourceId:sinaAccount.usid username:[sinaAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:nil];
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
}

@end

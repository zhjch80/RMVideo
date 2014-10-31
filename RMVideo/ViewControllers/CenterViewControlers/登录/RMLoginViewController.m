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
    
    BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToSina];
    if(isOauth){
        
        NSLog(@"YES");
        NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
        UMSocialAccountEntity *sinaAccount = [snsAccountDic valueForKey:UMShareToSina];
        NSLog(@"sina nickName is %@, iconURL is %@",sinaAccount.userName,sinaAccount.iconURL);
    }
    else{
        UINavigationController *oauthController = [[UMSocialControllerService defaultControllerService] getSocialOauthController:UMShareToSina];
        [self presentViewController:oauthController animated:YES completion:nil];
    }
    [UMSocialControllerService defaultControllerService].socialUIDelegate = self;

}

- (IBAction)tencentLogin:(UIButton *)sender {
    
    BOOL isOauth = [UMSocialAccountManager isOauthAndTokenNotExpired:UMShareToTencent];
    if(isOauth){
        
        NSLog(@"YES");
        NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
        UMSocialAccountEntity *sinaAccount = [snsAccountDic valueForKey:UMShareToTencent];
        NSLog(@"sina nickName is %@, iconURL is %@",sinaAccount.userName,sinaAccount.iconURL);
    }
    else{
        UINavigationController *oauthController = [[UMSocialControllerService defaultControllerService] getSocialOauthController:UMShareToTencent];
        [self presentViewController:oauthController animated:YES completion:nil];
    }
    [UMSocialControllerService defaultControllerService].socialUIDelegate = self;

}

- (void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //授权成功后的回调函数
    if (response.viewControllerType == UMSViewControllerOauth) {
        
        //NSLog(@"didFinishOauthAndGetAccount response is %@",response);
        NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
        UMSocialAccountEntity *sinaAccount = [snsAccountDic valueForKey:UMShareToTencent];
        NSLog(@"sina nickName is %@, iconURL is %@ token:%@",sinaAccount.userName,sinaAccount.iconURL,sinaAccount.accessToken);
        RMAFNRequestManager *manager = [[RMAFNRequestManager alloc] init];
        manager.delegate = self;
        [manager postLoginWithSourceType:@"2" sourceId:sinaAccount.usid username:[sinaAccount.userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] headImageURL:nil];
    }
    
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
}

@end

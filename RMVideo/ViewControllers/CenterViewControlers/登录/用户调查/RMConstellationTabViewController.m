//
//  RMConstellationTabViewController.m
//  yemianbuju
//
//  Created by 润华联动 on 14-12-17.
//  Copyright (c) 2014年 润华联动. All rights reserved.
//

#import "RMConstellationTabViewController.h"

@interface RMConstellationTabViewController ()<RMAFNRequestManagerDelegate>{
    NSString *likeTypeString;
    NSString *constellationString;
    RMAFNRequestManager * manager;
    NSMutableDictionary * InfoDic;
}

@end

@implementation RMConstellationTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
    manager = [[RMAFNRequestManager alloc] init];
}

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)likeGenreBtnClick:(UIButton *)sender {
    //重口味
    if(sender.tag == 200){
        likeTypeString = @"1";
        [SmallFreshBtn setImage:[UIImage imageNamed:@"no-select_cellImage"] forState:UIControlStateNormal];
        [HeavyTasteBtn setImage:[UIImage imageNamed:@"select_cellImage"] forState:UIControlStateNormal];
    }
    //小清新
    else{
        likeTypeString = @"2";
        [HeavyTasteBtn setImage:[UIImage imageNamed:@"no-select_cellImage"] forState:UIControlStateNormal];
        [SmallFreshBtn setImage:[UIImage imageNamed:@"select_cellImage"] forState:UIControlStateNormal];
    }
}

- (IBAction)constellation:(UIButton *)sender {
    constellationString = sender.titleLabel.text;
    [sender setBackgroundImage:[UIImage imageNamed:@"redbg"] forState:UIControlStateNormal];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    for(int i=100; i<112; i++){
        if(i==sender.tag) continue;
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        [button setBackgroundImage:[UIImage imageNamed:@"bg"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (IBAction)finishBtnClick:(UIButton *)sender {
    InfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
               self.genderString, @"gender",
               self.yearString, @"age",
               likeTypeString, @"preferences",
               constellationString, @"constellation",
               nil];
    if(likeTypeString==nil||constellationString==nil){
        UIAlertView *alview = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请选择相应的选项" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alview show];
        return;
    }
    if ([UtilityFunc isConnectionAvailable] == 0){
        [SVProgressHUD showErrorWithStatus:kShowConnectionAvailableError duration:1.0];
        return ;
    }
    [self startRequestInfoWithDic:InfoDic];
}

#pragma mark - request

- (void)startRequestInfoWithDic:(NSMutableDictionary *)infoDic {
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeClear];
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
    manager.delegate = self;
    [manager getLoginAfterSetInfoWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] withGender:[InfoDic objectForKey:@"gender"] withAge:[InfoDic objectForKey:@"age"] withPreferences:[InfoDic objectForKey:@"preferences"] withConstellation:[InfoDic objectForKey:@"constellation"]];
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if ([[[data objectAtIndex:0] objectForKey:@"code"] integerValue] == 4001){
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessCallback" object:nil];
        if ([self.viewControlerrIdentify isEqualToString:@"LoginCtl"]){
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
        }
    }else{
        [SVProgressHUD showErrorWithStatus:@"信息提交失败，请重新提交" duration:1.0];
    }
    [SVProgressHUD dismiss];
}

- (void)requestError:(NSError *)error {
    [SVProgressHUD dismiss];
    NSLog(@"Info error:%@",error);
}

@end

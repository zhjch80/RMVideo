//
//  RMUserFeedbackViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMUserFeedbackViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface RMUserFeedbackViewController ()

@end

@implementation RMUserFeedbackViewController

- (void) navgationBarButtonClick:(UIBarButtonItem *)sender{
    
    if(sender.tag==1){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        if(self.feedBackTextView.text && ![self.feedBackTextView.text isEqualToString:@""]){
            RMAFNRequestManager *manager = [[RMAFNRequestManager alloc] init];
            manager.delegate = self;
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
            [manager postUserFeedbackWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] andFeedBackString:[self.feedBackTextView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请填写您宝贵的意见" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_Setup_UserFeedback" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_Setup_UserFeedback" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"用户反馈";
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
    rightBarButton.frame = CGRectMake(0, 0, 38, 23);
    [rightBarButton setBackgroundImage:LOADIMAGE(@"tijiao", kImageTypePNG) forState:UIControlStateNormal];
    self.feedBackTextView.layer.masksToBounds = YES;
    [self.feedBackTextView.layer setCornerRadius:10];
    self.feedBackTextView.layer.borderColor = [UIColor blackColor].CGColor;
    self.feedBackTextView.layer.borderWidth = 1;

}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的意见已成功提交" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

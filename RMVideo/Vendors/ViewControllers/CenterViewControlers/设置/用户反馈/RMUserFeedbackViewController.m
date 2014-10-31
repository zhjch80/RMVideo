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
            [manager postUserFeedbackWithToken:@"" andFeedBackString:[self.feedBackTextView.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请填写您宝贵的意见" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"用户反馈";
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
    [rightBarButton setImage:nil forState:UIControlStateNormal];
    [rightBarButton setTitle:@"提交" forState:UIControlStateNormal];
    rightBarButton.titleLabel.font = [UIFont systemFontOfSize:11];
    self.feedBackTextView.layer.masksToBounds = YES;
    [self.feedBackTextView.layer setCornerRadius:10];
    self.feedBackTextView.layer.borderColor = [UIColor blackColor].CGColor;
    self.feedBackTextView.layer.borderWidth = 1;

}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    if([[data objectAtIndex:0] intValue]==4001){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的意见已成功提交" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alertView show];
    }
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

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
        //提交
        NSLog(@"%@",self.feedBackTextView.text);
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

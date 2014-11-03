//
//  RMStarSearchResultViewController.m
//  RMVideo
//
//  Created by runmobile on 14-11-3.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMStarSearchResultViewController.h"
#import "RMStarSearchResultCell.h"

@interface RMStarSearchResultViewController ()

@end

@implementation RMStarSearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [leftBarButton setBackgroundImage:LOADIMAGE(@"backup_img", kImageTypePNG) forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    [self setTitle:@"搜索结果"];
    
    NSLog(@"count:%d \n obj:%@",self.resultData.count,self.resultData);
    
}

#pragma mark - base Method 

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
            break;
        }
        case 2:{
            
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  RMSoHotListViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMSoHotListViewController.h"
#import "RMDailyListViewController.h"

#import "RMImageView.h"
#import "RMSetupViewController.h"
#import "RMSearchViewController.h"

@interface RMSoHotListViewController ()

@end

@implementation RMSoHotListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setTitle:@"全网热榜"];
    [leftBarButton setImage:[UIImage imageNamed:@"setup"] forState:UIControlStateNormal];
    [rightBarButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    float spacetop = ([UtilityFunc shareInstance].globleAllHeight-(20-64-49)-280)/2;
    float spaceleft = ([UtilityFunc shareInstance].globleWidth-196)/2;
    NSArray *imageArray = [NSArray arrayWithObjects:@"hotPlay_ribang",@"hotPlay_zhoubang",@"hotPlay_yuebang", nil];
    for(int i=0;i<3;i++){
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:LOADIMAGE([imageArray objectAtIndex:i],kImageTypePNG) forState:UIControlStateNormal];
        btn.frame = CGRectMake(spaceleft, spacetop+i*20+i*80- 54 - 49, 196, 80);
        [self.view addSubview:btn];
        btn.tag = 100+i;
        [btn addTarget:self action:@selector(topTypeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)topTypeBtnClick:(UIButton *)sender{
    RMDailyListViewController *viewController = [[RMDailyListViewController alloc] init];
    if(sender.tag == 100){
        viewController.topType = @"1";
    }else if(sender.tag == 101){
        viewController.topType = @"2";
        
    }else if (sender.tag == 102){
        viewController.topType = @"3";
        
    }
    [self.navigationController pushViewController:viewController animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender{
    switch (sender.tag) {
        case 1:{
            RMSetupViewController * setupCtl = [[RMSetupViewController alloc] init];
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:setupCtl] animated:YES completion:^{
                
            }];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
            break;
        }
        case 2:{
            RMSearchViewController * searchCtl = [[RMSearchViewController alloc] init];
            
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:searchCtl] animated:YES completion:^{
                
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
            break;
        }
            
        default:
            break;
    }
}

@end

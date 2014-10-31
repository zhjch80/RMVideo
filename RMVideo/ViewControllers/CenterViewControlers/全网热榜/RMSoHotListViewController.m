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

@interface RMSoHotListViewController ()

@end

@implementation RMSoHotListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self setTitle:@"全网热榜"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarButtonClick:)];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)rightBarButtonClick:(UIBarButtonItem *)barButtonItem{
    
    RMDailyListViewController *viewController = [[RMDailyListViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
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

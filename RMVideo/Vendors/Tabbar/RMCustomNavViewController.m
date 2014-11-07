//
//  RMCustomNavViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-11-6.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMCustomNavViewController.h"

@interface RMCustomNavViewController ()

@end

@implementation RMCustomNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIDeviceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return NO;
}

//- (NSUInteger)supportedInterfaceOrientations{
//    return UIInterfaceOrientationPortrait;//只支持这一个方向(正常的方向)
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

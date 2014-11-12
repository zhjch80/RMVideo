//
//  RMCustomPresentNavViewController.m
//  RMVideo
//
//  Created by runmobile on 14-11-11.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMCustomPresentNavViewController.h"

#define JuV [[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0

@interface RMCustomPresentNavViewController ()

@end

@implementation RMCustomPresentNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
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

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

//iOS7 上注释掉该方法

//- (NSUInteger)supportedInterfaceOrientations{
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
//        NSLog(@"123123123");
//        return UIInterfaceOrientationLandscapeLeft;//只支持这一个方向(正常的方向)
//    }else{
//        
//        NSLog(@"456456456");
//        return UIInterfaceOrientationPortrait;//只支持这一个方向(正常的方向)
//    }
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

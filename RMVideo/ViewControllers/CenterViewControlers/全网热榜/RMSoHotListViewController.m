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
#import "RMCustomNavViewController.h"
#import "RMCustomPresentNavViewController.h"

@interface RMSoHotListViewController ()

@end

@implementation RMSoHotListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_SoHotList" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_SoHotList" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    [self setTitle:@"全网热榜"];
    [leftBarButton setImage:[UIImage imageNamed:@"setup"] forState:UIControlStateNormal];
    [rightBarButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    
    NSArray * arr_4 = [NSArray arrayWithObjects:@"rb_day_4@2x", @"rb_week_4@2x", @"rb_month_4@2x", nil];
    NSArray * arr_5 = [NSArray arrayWithObjects:@"rb_day_5@2x", @"rb_week_5@2x", @"rb_month_5@2x", nil];
    NSArray * arr_6 = [NSArray arrayWithObjects:@"rb_day_6", @"rb_week_6", @"rb_month_6", nil];
    NSArray * arr_6p = [NSArray arrayWithObjects:@"rb_day_6p", @"rb_week_6p", @"rb_month_6p", nil];

    for (int i=0; i<3; i++){
        RMImageView * imageView = [[RMImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        imageView.backgroundColor = [UIColor clearColor];
        imageView.tag = 501+i;
        [imageView addTarget:self WithSelector:@selector(clickImageMethod:)];
        if (IS_IPHONE_4_SCREEN){
            imageView.frame = CGRectMake(0, 0+i*128, 320, 128);
            imageView.image = LOADIMAGE([arr_4 objectAtIndex:i], kImageTypePNG);
        }else if (IS_IPHONE_5_SCREEN){
            imageView.frame = CGRectMake(0, 0+i*152, 320, 152);
            imageView.image = LOADIMAGE([arr_5 objectAtIndex:i], kImageTypePNG);
        }else if (IS_IPHONE_6_SCREEN) {
            imageView.frame = CGRectMake(0, 0+i*185, 375, 185);
            imageView.image = LOADIMAGE([arr_6 objectAtIndex:i], kImageTypePNG);
        }else{
            imageView.frame = CGRectMake(0, 0+i*207.5, 414, 207.5);
            imageView.image = LOADIMAGE([arr_6p objectAtIndex:i], kImageTypePNG);
        }
        
        [self.view addSubview:imageView];
    }
}

- (void)clickImageMethod:(RMImageView *)image {
    RMDailyListViewController *viewController = [[RMDailyListViewController alloc] init];
    switch (image.tag) {
        case 501:{
            viewController.topType = @"1";
            break;
        }
        case 502:{
            viewController.topType = @"2";
            break;
        }
        case 503:{
            viewController.topType = @"3";
            break;
        }
            
        default:
            break;
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
            [self presentViewController:[[RMCustomPresentNavViewController alloc] initWithRootViewController:setupCtl] animated:YES completion:^{
                
            }];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
            break;
        }
        case 2:{
            RMSearchViewController * searchCtl = [[RMSearchViewController alloc] init];
            
            [self presentViewController:[[RMCustomPresentNavViewController alloc] initWithRootViewController:searchCtl] animated:YES completion:^{
                
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
            break;
        }
            
        default:
            break;
    }
}

@end

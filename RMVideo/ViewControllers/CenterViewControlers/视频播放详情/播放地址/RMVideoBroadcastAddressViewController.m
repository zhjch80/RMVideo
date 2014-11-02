//
//  RMVideoBroadcastAddressViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMVideoBroadcastAddressViewController.h"

#import "RMAFNRequestManager.h"
#import "RMPublicModel.h"
#import "UIImageView+AFNetworking.h"

@interface RMVideoBroadcastAddressViewController () {
    NSMutableArray * dataArr;
}

@end

@implementation RMVideoBroadcastAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dataArr = [[NSMutableArray alloc] initWithObjects:@"优酷", @"乐视", @"爱奇艺", @"搜狐视频", @"腾讯视频", @"土豆", @"PPS", @"PPTV", @"时光网", @"迅雷看看", nil];
    
    int value = 0;
    for (int i=0; i<3; i++){
        for (int j=0; j<4; j++) {
            if (value == 10){
                return;
            }
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(16 + j*75, 20 + i*75, 60, 60);
            [button setBackgroundImage:LOADIMAGE(@"logo_tx", kImageTypePNG) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(subButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            value ++;
        }
    }
    
}

- (void)subButtonClick:(UIButton *)sender {
    NSLog(@"播放地址");
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

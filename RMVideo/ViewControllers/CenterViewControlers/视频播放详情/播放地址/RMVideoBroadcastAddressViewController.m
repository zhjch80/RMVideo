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
    NSMutableArray * logoNameArr;
    NSMutableDictionary * logoDic;
    NSMutableArray * dataArr;
}

@end

@implementation RMVideoBroadcastAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dataArr = [[NSMutableArray alloc] init];
    logoNameArr = [[NSMutableArray alloc] initWithObjects:@"优酷", @"乐视", @"爱奇艺", @"搜狐视频", @"腾讯视频", @"土豆", @"PPS", @"PPTV", @"时光网", @"迅雷看看", nil];
    
    logoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
               @"logo_yk", @"1",
               @"logo_xlkk", @"2",
               @"logo_tx", @"3",
               @"logo_ls", @"4",
               @"logo_pptv", @"5",
               @"logo_aqy", @"6",
               @"logo_td", @"7",
               nil];
}

- (void)subButtonClick:(UIButton *)sender {
    NSInteger index = sender.tag - 301;
    NSMutableDictionary * dic = [dataArr objectAtIndex:index];
    //TODO:跳转到播放界面或者选集界面 接口不完全
    NSLog(@"index:%d jumpurl:%@",index,[dic objectForKey:@"jumpurl"]);
}

- (void)updateBroadcastAddress:(RMPublicModel *)model {
    dataArr = model.playurlArr;
    int value = 0;
    for (int i=0; i<3; i++){
        for (int j=0; j<4; j++) {
            if (value == [dataArr count]){
                return;
            }
            NSMutableDictionary * dic = [dataArr objectAtIndex:value];
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(16 + j*75, 20 + i*75, 60, 60);
            [button setBackgroundImage:LOADIMAGE([logoDic objectForKey:[dic objectForKey:@"source_type"]], kImageTypePNG) forState:UIControlStateNormal];
            button.tag = value + 301;
            [button addTarget:self action:@selector(subButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:button];
            value ++;
        }
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

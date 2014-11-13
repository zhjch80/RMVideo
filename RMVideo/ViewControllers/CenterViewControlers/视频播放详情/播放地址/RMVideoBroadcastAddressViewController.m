//
//  RMVideoBroadcastAddressViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMVideoBroadcastAddressViewController.h"
#import "CustomVideoPlayerController.h"
#import "Database.h"
#import "RMVideoPlaybackDetailsViewController.h"
#import "RMWebViewPlayViewController.h"
#import "RMCustomPresentNavViewController.h"

@interface RMVideoBroadcastAddressViewController () {
    NSMutableArray * logoNameArr;
    NSMutableDictionary * logoDic;
    NSMutableArray * dataArr;
}
@property (nonatomic, strong) RMPublicModel *publicModel;
@end

@implementation RMVideoBroadcastAddressViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_StarDetail_BroadcastAddress" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_StarDetail_BroadcastAddress" withParameters:nil];
}

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
    RMVideoPlaybackDetailsViewController * videoPlaybackDetailsCtl = self.videoPlayDelegate;

    if ([NSString stringWithFormat:@"%@",[dic objectForKey:@"m_down_url"]].length == 0){
        //跳转web
        //保存数据sqlit
        RMPublicModel *insertModel = [[RMPublicModel alloc] init];
        insertModel.name = self.publicModel.name;
        insertModel.pic_url = self.publicModel.pic;
        insertModel.jumpurl = [dic objectForKey:@"jumpurl"];
        insertModel.playTime = @"0";
        [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
        //跳转
        RMWebViewPlayViewController *webView = [[RMWebViewPlayViewController alloc] init];
        RMCustomPresentNavViewController * webNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:webView];
        webView.urlString = [dic objectForKey:@"jumpurl"];
        [videoPlaybackDetailsCtl presentViewController:webNav animated:YES completion:^{
        }];
    }else{
        //使用custom play 播放mp4
        //保存数据sqlit
        RMPublicModel *insertModel = [[RMPublicModel alloc] init];
        insertModel.name = self.publicModel.name;
        insertModel.pic_url = self.publicModel.pic;
        insertModel.reurl = [dic objectForKey:@"m_down_url"];
        insertModel.playTime = @"0";
        [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
        
        //跳转
        CustomVideoPlayerController *playContro = [[CustomVideoPlayerController alloc] init];
        [playContro createPlayerViewWithURL:[dic objectForKey:@"m_down_url"] isPlayLocalVideo:NO];
        [playContro createTopTool];
        [videoPlaybackDetailsCtl presentViewController:playContro animated:YES completion:^{
            
        }];
    }
}

- (void)updateBroadcastAddress:(RMPublicModel *)model {
//    video_type ==1 为电影   video_type ==2 电视剧  video_type ==3 综艺
    
    self.publicModel = model;
    if ([model.video_type integerValue] == 1){
        dataArr = model.playurlArr;//保存电影数据
    }else{
        dataArr = model.playurlsArr;//保存电视剧及综艺数据
    }
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

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
    RMPublicModel *publicModel;
}

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
    publicModel = [[RMPublicModel alloc] init];
    publicModel.pic_url = @"http://f.hiphotos.baidu.com/image/w%3D310/sign=7437de58d2a20cf44690f8de460b4b0c/e1fe9925bc315c60191d32308fb1cb1348547760.jpg";
    publicModel.name = @"新影片";
}

- (void)subButtonClick:(UIButton *)sender {
    NSInteger index = sender.tag - 301;
    
    NSMutableDictionary * dic = [dataArr objectAtIndex:index];
    NSLog(@"index:%d jumpurl:%@",index,[dic objectForKey:@"jumpurl"]);
    
    RMPublicModel *insertModel = [[RMPublicModel alloc] init];
    insertModel.name = publicModel.name;
    insertModel.pic_url = publicModel.pic_url;
    insertModel.reurl = [dic objectForKey:@"jumpurl"];
    insertModel.playTime = @"0";
    [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
    
    RMVideoPlaybackDetailsViewController * videoPlaybackDetailsCtl = self.videoPlayDelegate;
//    CustomVideoPlayerController *playContro = [[CustomVideoPlayerController alloc] init];
////    [playContro createPlayerViewWithURL:[dic objectForKey:@"jumpurl"] isPlayLocalVideo:NO];
//    [playContro createPlayerViewWithURL:@"http://106.38.249.19/youku/65627388FF3C7A5D74795177/0300200100540028BE5B4905CF07DDD2EA7A92-268F-6D8E-02C5-CAD970EFBB61.mp4" isPlayLocalVideo:NO];
//    [playContro createTopTool];
//    [videoPlaybackDetailsCtl presentViewController:playContro animated:YES completion:^{
//        
//    }];
    RMWebViewPlayViewController *webView = [[RMWebViewPlayViewController alloc] init];
    RMCustomPresentNavViewController * webNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:webView];
    webView.urlString = @"http://v.youku.com/v_show/id_XNzgyODExNDY4.html?from=y1.3-movie-grid-1095-9921.95742.2-1";
    [videoPlaybackDetailsCtl presentViewController:webNav animated:YES completion:^{
        
        
    }];
//    [videoPlaybackDetailsCtl.navigationController pushViewController:webNav animated:YES];
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

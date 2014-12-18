//
//  RMVideoBroadcastAddressViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMVideoBroadcastAddressViewController.h"
#import "RMPlayer.h"
#import "RMModel.h"
#import "Database.h"
#import "RMVideoPlaybackDetailsViewController.h"
#import "RMWebViewPlayViewController.h"
#import "RMCustomPresentNavViewController.h"

@interface RMVideoBroadcastAddressViewController ()<RMAFNRequestManagerDelegate> {
    NSMutableArray * logoNameArr;
    NSMutableDictionary * logoDic;
    NSMutableArray * dataArr;
    NSMutableArray * arr;       //保存共有几部第三方片源
    NSInteger videoType;        //video_type ==1 为电影   video_type ==2 电视剧  video_type ==3 综艺
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
    if(videoType==1){
        dataArr = arr;
    }else{
        dataArr = [[arr objectAtIndex:index] objectForKey:@"urls"];   //拿到集数
    }
    if(dataArr.count==0){
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"暂没有播放地址" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alerView show];
        return;
    }
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
        insertModel.video_id = self.publicModel.video_id;
        [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
        //跳转
        [Flurry logEvent:@"Click_JumpWebPlayVideo"];
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
        insertModel.video_id = self.publicModel.video_id;
        [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
        
        //跳转
        [Flurry logEvent:@"Click_JumpCustomPlayVideo"];
        if ([self.publicModel.video_type integerValue] != 1){
            //电视剧 综艺
            NSMutableArray * playArr = [[NSMutableArray alloc] init];
            for (int i=0; i<[dataArr count]; i++){
                RMModel * model = [[RMModel alloc] init];
                model.title = self.publicModel.name;
                model.url = [[dataArr objectAtIndex:i] objectForKey:@"m_down_url"];
                model.EpisodeValue = [NSString stringWithFormat:@"%@",[[dataArr objectAtIndex:i] objectForKey:@"curnum"]];
                [playArr addObject:model];
            }
            [RMPlayer presentVideoPlayerWithPlayArr:playArr withUIViewController:videoPlaybackDetailsCtl withVideoType:2];
        }else{
            //电影
            RMModel * model = [[RMModel alloc] init];
            model.url = [dic objectForKey:@"m_down_url"];
            model.title = self.publicModel.name;
            [RMPlayer presentVideoPlayerWithPlayModel:model withUIViewController:videoPlaybackDetailsCtl withVideoType:1];
        }
    }
    //统计播放次数
    UIDevice *device = [[UIDevice alloc] init];
    RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
    [request getDeviceHitsWithVideo_id:self.publicModel.video_id WithDevice:device.model];
    request.delegate = self;
}

- (void)updateBroadcastAddress:(RMPublicModel *)model {
//    video_type ==1 为电影   video_type ==2 电视剧  video_type ==3 综艺
    if (model == nil){
        [self showUnderEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无播放地址" WithHeight:([UtilityFunc shareInstance].globleHeight-154)/2 - 77-90];
        return;
    }
    self.publicModel = model;
    arr = [[NSMutableArray alloc] init];
    videoType = [model.video_type integerValue];
    if ([model.video_type integerValue] == 1){
        arr = model.playurlArr;//保存电影数据      按第三方来源区分
    }else{
        arr = model.playurlsArr;//保存电视剧及综艺数据
    }

    if (IS_IPHONE_6p_SCREEN){
        int value = 0;
        for (int i=0; i<2; i++){
            for (int j=0; j<5; j++) {
                if (value == [arr count]){
                    if (value == 0){
                        [self showUnderEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无播放地址" WithHeight:([UtilityFunc shareInstance].globleHeight-154)/2 - 77-90];
                    }else{
                        [self isShouldSetHiddenUnderEmptyView:YES];
                    }
                    return;
                }
                UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(8 + j*75, 20 + i*75, 60, 60);
                [button setBackgroundImage:LOADIMAGE([logoDic objectForKey:[[arr objectAtIndex:value] objectForKey:@"source_type"]], kImageTypePNG) forState:UIControlStateNormal];
                button.tag = value + 301;
                [button addTarget:self action:@selector(subButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:button];
                value ++;
            }
        }
    }else if (IS_IPHONE_6_SCREEN){
        int value = 0;
        for (int i=0; i<2; i++){
            for (int j=0; j<5; j++) {
                if (value == [arr count]){
                    if (value == 0){
                        [self showUnderEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无播放地址" WithHeight:([UtilityFunc shareInstance].globleHeight-154)/2 - 77-90];
                    }else{
                        [self isShouldSetHiddenUnderEmptyView:YES];
                    }
                    return;
                }
                UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(8 + j*75, 20 + i*75, 60, 60);
                [button setBackgroundImage:LOADIMAGE([logoDic objectForKey:[[arr objectAtIndex:value] objectForKey:@"source_type"]], kImageTypePNG) forState:UIControlStateNormal];
                button.tag = value + 301;
                [button addTarget:self action:@selector(subButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:button];
                value ++;
            }
        }
    }else{
        int value = 0;
        for (int i=0; i<3; i++){
            for (int j=0; j<4; j++) {
                if (value == [arr count]){
                    if (value == 0){
                        [self showUnderEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无播放地址" WithHeight:([UtilityFunc shareInstance].globleHeight-154)/2 - 77-90];
                    }else{
                        [self isShouldSetHiddenUnderEmptyView:YES];
                    }
                    return;
                }
                UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(16 + j*75, 20 + i*75, 60, 60);
                [button setBackgroundImage:LOADIMAGE([logoDic objectForKey:[[arr objectAtIndex:value] objectForKey:@"source_type"]], kImageTypePNG) forState:UIControlStateNormal];
                button.tag = value + 301;
                [button addTarget:self action:@selector(subButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:button];
                value ++;
            }
        }
    }
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    
}

- (void)requestError:(NSError *)error {
    NSLog(@"error:%@",error);
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

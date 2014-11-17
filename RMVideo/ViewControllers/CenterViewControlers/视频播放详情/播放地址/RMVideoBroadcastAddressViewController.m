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
        CustomVideoPlayerController *playContro = [[CustomVideoPlayerController alloc] init];
        NSMutableArray * downloadArr = [[NSMutableArray alloc] init];
        for (int i=0; i<[dataArr count]; i++){
            RMPublicModel * model = [[RMPublicModel alloc] init];
            model.reurl = [[dataArr objectAtIndex:i] objectForKey:@"m_down_url"];//mp4地址
            model.topNum = [[dataArr objectAtIndex:i] objectForKey:@"curnum"];//所属第几集
            [downloadArr addObject:model];
        }
//        playContro.playStyle = playNetWorVideo;
        playContro.playEpisodeNumber = 0;
        if([self.publicModel.video_type integerValue]!=1){
            //电视剧 综艺
            playContro.videoArray = downloadArr;
            playContro.videoType = videoTypeisTV;
            [playContro createPlayerViewWithURL:[[dataArr objectAtIndex:0] objectForKey:@"m_down_url"] isPlayLocalVideo:NO];//默认播放第一集
        }else{
            //电影
            playContro.videoType = videoTypeIsMovie;
            [playContro createPlayerViewWithURL:[dic objectForKey:@"m_down_url"] isPlayLocalVideo:NO];
        }
        [playContro createTopToolWithTitle:self.publicModel.name];
        [videoPlaybackDetailsCtl presentViewController:playContro animated:YES completion:^{
            
        }];
    }
}


/*
 {
playurl =     (
 );
 playurls =     (
 {
 id = 1;
 order = 99;
 "source_type" = 1;
 urls =             (
 {
 curnum = 1;
 jumpurl = "http://v.youku.com/v_show/id_XNjI2NDQ4OTE2.html";
 "m_down_url" = "";
 },
 {
 curnum = 2;
 jumpurl = "http://v.youku.com/v_show/id_XNjI5MzIyNTQ4.html";
 "m_down_url" = "";
 },
 {
 curnum = 3;
 jumpurl = "http://v.youku.com/v_show/id_XNjMyNDgxNDgw.html";
 "m_down_url" = "";
 },
 {
 curnum = 4;
 jumpurl = "http://v.youku.com/v_show/id_XNjM1Mjg1MDg4.html";
 "m_down_url" = "";
 },
 {
 curnum = 5;
 jumpurl = "http://v.youku.com/v_show/id_XNjQxNzAzMzQw.html";
 "m_down_url" = "";
 },
 {
 curnum = 6;
 jumpurl = "http://v.youku.com/v_show/id_XNjQ0Nzc2NTU2.html";
 "m_down_url" = "";
 },
 {
 curnum = 7;
 jumpurl = "http://v.youku.com/v_show/id_XNjQ3OTY0Nzk2.html";
 "m_down_url" = "";
 },
 {
 curnum = 8;
 jumpurl = "http://v.youku.com/v_show/id_XNjQ3OTc1NTcy.html";
 "m_down_url" = "";
 },
 {
 curnum = 9;
 jumpurl = "http://v.youku.com/v_show/id_XNjU3MTg2MzI0.html";
 "m_down_url" = "";
 },
 {
 curnum = 10;
 jumpurl = "http://v.youku.com/v_show/id_XNjYwMjQ0Mzg4.html";
 "m_down_url" = "";
 },
 {
 curnum = 11;
 jumpurl = "http://v.youku.com/v_show/id_XNjYzMTU3MzQ4.html";
 "m_down_url" = "";
 },
 {
 curnum = 12;
 jumpurl = "http://v.youku.com/v_show/id_XNjY2MDEyMDAw.html";
 "m_down_url" = "";
 },
 {
 curnum = 13;
 jumpurl = "http://v.youku.com/v_show/id_XNjc5Mjc3ODI4.html";
 "m_down_url" = "";
 },
 {
 curnum = 14;
 jumpurl = "http://v.youku.com/v_show/id_XNjgyMzM4MzI0.html";
 "m_down_url" = "";
 },
 {
 curnum = 15;
 jumpurl = "http://v.youku.com/v_show/id_XNjg1NDA4NjQ0.html";
 "m_down_url" = "";
 },
 {
 curnum = 16;
 jumpurl = "http://v.youku.com/v_show/id_XNjg4NTE5MTQw.html";
 "m_down_url" = "";
 },
 {
 curnum = 17;
 jumpurl = "http://v.youku.com/v_show/id_XNjk0NzA4MjIw.html";
 "m_down_url" = "";
 },
 {
 curnum = 18;
 jumpurl = "http://v.youku.com/v_show/id_XNjk3NzI2NDYw.html";
 "m_down_url" = "";
 },
 {
 curnum = 19;
 jumpurl = "http://v.youku.com/v_show/id_XNzAzOTM3NjM2.html";
 "m_down_url" = "";
 },
 {
 curnum = 20;
 jumpurl = "http://v.youku.com/v_show/id_XNzA2OTQ0NTE2.html";
 "m_down_url" = "";
 },
 {
 curnum = 21;
 jumpurl = "http://v.youku.com/v_show/id_XNzEwMDU2MTg0.html";
 "m_down_url" = "";
 }
 );
 }
 );
 "source_type_ids" = 1;
 "video_id" = 11473;
 "video_type" = 2;
 }
 
 
 
 
 
 
 {
   playurl =     (
 {
 jumpurl = "http://www.letv.com/ptv/vplay/2205090.html";
 "m_down_url" = "http://g3.letv.cn/vod/v2/MzkvNC8zMi9sZXR2LXV0cy8xNC92ZXJfMDBfMTQtMTM4OTE1MTQtYXZjLTI1OTk4Mi1hYWMtMzIwMDAtNTI0NjU0MS0xOTgwNjM0MTMtMzgyNTg1OTEwYzdjMTc0N2FjZjYxZTg1MGNlYTNmYTEtMTM5NDY2MzI2NTE2OC5tcDQ=?b=302&mmsid=3559025&tm=1414727598&key=e4e89e8f3d4f37cb9bf0b26ca42ccf16&platid=1&splatid=101&playid=0&tss=no&vtype=21&cvid=1103601971267&platid=100&splatid=10000&tag=gug&gugtype=1&type=pc_liuchang_mp4&ch=letv&playid=0&termid=1&pay=0&ostype=windows&hwtype=un&format=0&expect=1&xxcid=2205090&xxformat=normal";
 order = 1;
 "source_type" = 4;
 },
 {
 jumpurl = "http://www.tudou.com/albumplay/1G5F36V65q4.html";
 "m_down_url" = "";
 order = 99;
 "source_type" = 7;
 },
 {
 jumpurl = "http://v.youku.com/v_show/id_XNjEyMjE2OTI4.html";
 "m_down_url" = "";
 order = 99;
 "source_type" = 1;
 }
 );
 playurls =     (
 );
 "source_type_ids" = "1,1,4,7";
 "video_id" = 1;
 "video_type" = 1;
 }
 */
- (void)updateBroadcastAddress:(RMPublicModel *)model {
//    video_type ==1 为电影   video_type ==2 电视剧  video_type ==3 综艺
    
    self.publicModel = model;
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    if ([model.video_type integerValue] == 1){
        arr = model.playurlArr;//保存电影数据      按第三方来源区分
        dataArr = model.playurlArr;
    }else{
        arr = model.playurlsArr;//保存电视剧及综艺数据
        dataArr = [[model.playurlsArr objectAtIndex:0] objectForKey:@"urls"];   //拿到集数
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

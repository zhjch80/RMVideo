//
//  RMDailyListViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDailyListViewController.h"
#import "RMDailyMovieViewController.h"
#import "RMDailyTVViewController.h"
#import "RMDailyVarietyViewController.h"
#import "SUNSlideSwitchView.h"
#import "RMVideoPlaybackDetailsViewController.h"
#import "RMWebViewPlayViewController.h"
#import "RMModel.h"
#import "RMPlayer.h"
#import "RMCustomPresentNavViewController.h"

@interface RMDailyListViewController ()<SUNSlideSwitchViewDelegate,RMDailyMovieViewControllerDelegate,RMDailyTVViewControllerDelegate,RMDailyVarietyViewControllerDelegate>
@property RMDailyTVViewController * starTeleplayListCtl;
@property RMDailyMovieViewController * starFilmListCtl;
@property RMDailyVarietyViewController * starVarietyListCtl;
@property (nonatomic, copy) SUNSlideSwitchView *slideSwitchView;
@end

@implementation RMDailyListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if([self.topType isEqualToString:@"1"]){
        self.title = @"日榜";
    }else if([self.topType isEqualToString:@"2"]){
        self.title = @"周榜";
    }else{
        self.title = @"月榜";
    }

    rightBarButton.hidden = YES;
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
    
    _slideSwitchView = [[SUNSlideSwitchView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight)];
    _slideSwitchView.slideSwitchViewDelegate = self;
    [self.view addSubview:_slideSwitchView];
    
    _starFilmListCtl = [[RMDailyMovieViewController alloc] init];
    _starFilmListCtl.delegate = self;
    _starFilmListCtl.downLoadTopType = self.topType;
    _starTeleplayListCtl = [[RMDailyTVViewController alloc] init];
    _starTeleplayListCtl.delegate = self;
    _starTeleplayListCtl.downLoadTopType = self.topType;
    _starVarietyListCtl = [[RMDailyVarietyViewController alloc] init];
    _starVarietyListCtl.delegate = self;
    _starVarietyListCtl.downLoadTopType = self.topType;
    
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        _slideSwitchView.btnHeight = 30;
        _slideSwitchView.btnWidth = 93;
    }else if (IS_IPHONE_6_SCREEN){
        _slideSwitchView.btnHeight = 30;
        _slideSwitchView.btnWidth = 93;
    }else if (IS_IPHONE_6p_SCREEN){
        _slideSwitchView.btnHeight = 37;
        _slideSwitchView.btnWidth = 120;
    }
    [_slideSwitchView buildUI];
    
}

#pragma mark - 滑动tab视图代理方法
- (NSUInteger)numberOfTab:(SUNSlideSwitchView *)view {
    return 3;
}

- (UIViewController *)slideSwitchView:(SUNSlideSwitchView *)view viewOfTab:(NSUInteger)number {
    if (number == 0) {
        return _starFilmListCtl;
    } else if (number == 1) {
        return _starTeleplayListCtl;
    } else if (number == 2) {
        return _starVarietyListCtl;
    } else {
        return nil;
    }
}

- (void)slideSwitchView:(SUNSlideSwitchView *)view panLeftEdge:(UIPanGestureRecognizer *)panParam {
    NSLog(@"left");
}

- (void)slideSwitchView:(SUNSlideSwitchView *)view didselectTab:(NSUInteger)number {
    if (number == 0) {
        [self.starFilmListCtl requestData];
        NSLog(@"slie to 第一个");
    } else if (number == 1) {
        [self.starTeleplayListCtl requestData];
        NSLog(@"slie to 第二个");
    } else if (number == 2) {
        [self.starVarietyListCtl requestData];
        NSLog(@"slie to 第三个");
    }
}

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
}
#pragma mark delegate  进入详情页面
//电影
- (void)selectMovieTableViewWithIndex:(NSInteger)index andStringID:(NSString *)stringID{
    
    RMVideoPlaybackDetailsViewController *videoPlay = [[RMVideoPlaybackDetailsViewController alloc] init];
    videoPlay.tabBarIdentifier = kNO;
    videoPlay.currentVideo_id = stringID;
    [self.navigationController pushViewController:videoPlay animated:YES];
}
//电视剧
- (void)selectTVTableViewCellWithIndex:(NSInteger)index andStringID:(NSString *)stringID{
    RMVideoPlaybackDetailsViewController *videoPlay = [[RMVideoPlaybackDetailsViewController alloc] init];
    videoPlay.tabBarIdentifier = kNO;
    videoPlay.currentVideo_id = stringID;
    [self.navigationController pushViewController:videoPlay animated:YES];

}
//综艺
- (void)selectVarietyTableViewCellWithIndex:(NSInteger)index andStringID:(NSString *)stringID{
    RMVideoPlaybackDetailsViewController *videoPlay = [[RMVideoPlaybackDetailsViewController alloc] init];
    videoPlay.tabBarIdentifier = kNO;
    videoPlay.currentVideo_id = stringID;
    [self.navigationController pushViewController:videoPlay animated:YES];

}
#pragma mark delegate  直接播放页面
- (void)playMovieWithModel:(RMPublicModel *)model{
    [self setPlayWith:model WithType:1];
}
- (void)playTVWithModel:(RMPublicModel *)model{
    [self setPlayWith:model WithType:2];
}
- (void)playVarietyWithModel:(RMPublicModel *)model{
    [self setPlayWith:model WithType:3];
}

- (void)setPlayWith:(RMPublicModel *)model WithType:(NSInteger)tag {
    switch (tag) {
        case 1:{
            if([model.downLoadURL isEqualToString:@""]||model.downLoadURL== nil){
                if([model.jumpurl isEqualToString:@""]||model.jumpurl==nil){
                    [SVProgressHUD showErrorWithStatus:@"暂时不能播放该视频"];
                    return;
                }
                //跳转web
                //保存数据sqlit
                RMPublicModel *insertModel = [[RMPublicModel alloc] init];
                insertModel.name = model.name;
                insertModel.pic_url = model.pic;
                insertModel.jumpurl = model.jumpurl;
                insertModel.playTime = @"0";
                insertModel.video_id = model.video_id;
                [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
                RMWebViewPlayViewController *webView = [[RMWebViewPlayViewController alloc] init];
                RMCustomPresentNavViewController * webNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:webView];
                webView.urlString = model.jumpurl;
                [self presentViewController:webNav animated:YES completion:^{
                }];
            }
            else{
                //使用custom play 播放mp4
                //保存数据sqlit
                RMPublicModel *insertModel = [[RMPublicModel alloc] init];
                insertModel.name = model.name;
                insertModel.pic_url = model.pic;
                insertModel.reurl = model.downLoadURL;
                insertModel.playTime = @"0";
                insertModel.video_id = model.video_id;
                [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
                //电影
                RMModel * playmodel = [[RMModel alloc] init];
                playmodel.url = model.downLoadURL;
                playmodel.title = model.name;
                [RMPlayer presentVideoPlayerWithPlayModel:playmodel withUIViewController:self withVideoType:1];
            }
            break;
        }
        case 2:{
            if([[[model.urls objectAtIndex:0] objectForKey:@"m_down_url"] isEqualToString:@""] || [[model.urls objectAtIndex:0] objectForKey:@"m_down_url"] == nil){
                if([[[model.urls objectAtIndex:0] objectForKey:@"jumpurl"] isEqualToString:@""] || [[model.urls objectAtIndex:0] objectForKey:@"jumpurl"] == nil){
                    [SVProgressHUD showErrorWithStatus:@"暂时不能播放该视频"];
                    return;
                }
                //跳转web
                //保存数据sqlit
                RMPublicModel *insertModel = [[RMPublicModel alloc] init];
                insertModel.name = model.name;
                insertModel.pic_url = model.pic;
                insertModel.jumpurl = [[model.urls objectAtIndex:0] objectForKey:@"jumpurl"];
                insertModel.playTime = @"0";
                insertModel.video_id = model.video_id;
                [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
                RMWebViewPlayViewController *webView = [[RMWebViewPlayViewController alloc] init];
                RMCustomPresentNavViewController * webNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:webView];
                webView.urlString = [[model.urls objectAtIndex:0] objectForKey:@"jumpurl"];
                [self presentViewController:webNav animated:YES completion:^{
                }];
            }else{
                //使用custom play 播放mp4
                //保存数据sqlit
                RMPublicModel *insertModel = [[RMPublicModel alloc] init];
                insertModel.name = model.name;
                insertModel.pic_url = model.pic;
                insertModel.reurl = [[model.urls objectAtIndex:0] objectForKey:@"m_down_url"];
                insertModel.playTime = @"0";
                insertModel.video_id = model.video_id;
                [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
                
                NSMutableArray * arr = [[NSMutableArray alloc] init];
                for (int i=0; i<[model.urls count]; i++) {
                    RMModel * playmodel = [[RMModel alloc] init];
                    playmodel.url = [[model.urls objectAtIndex:i] objectForKey:@"m_down_url"];
                    playmodel.title = model.name;
                    playmodel.EpisodeValue = [[model.urls objectAtIndex:i] objectForKey:@"order"];
                    [arr addObject:playmodel];
                }
                [RMPlayer presentVideoPlayerWithPlayArray:arr withUIViewController:self withVideoType:2];
            }
            break;
        }
        case 3:{
            if([[[model.urls objectAtIndex:0] objectForKey:@"m_down_url"] isEqualToString:@""] || [[model.urls objectAtIndex:0] objectForKey:@"m_down_url"] == nil){
                if([[[model.urls objectAtIndex:0] objectForKey:@"jumpurl"] isEqualToString:@""] || [[model.urls objectAtIndex:0] objectForKey:@"jumpurl"] == nil){
                    [SVProgressHUD showErrorWithStatus:@"暂时不能播放该视频"];
                    return;
                }
                //跳转web
                //保存数据sqlit
                RMPublicModel *insertModel = [[RMPublicModel alloc] init];
                insertModel.name = model.name;
                insertModel.pic_url = model.pic;
                insertModel.jumpurl = [[model.urls objectAtIndex:0] objectForKey:@"jumpurl"];
                insertModel.playTime = @"0";
                insertModel.video_id = model.video_id;
                [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
                RMWebViewPlayViewController *webView = [[RMWebViewPlayViewController alloc] init];
                RMCustomPresentNavViewController * webNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:webView];
                webView.urlString = [[model.urls objectAtIndex:0] objectForKey:@"jumpurl"];
                [self presentViewController:webNav animated:YES completion:^{
                }];
            }else{
                //使用custom play 播放mp4
                //保存数据sqlit
                RMPublicModel *insertModel = [[RMPublicModel alloc] init];
                insertModel.name = model.name;
                insertModel.pic_url = model.pic;
                insertModel.reurl = [[model.urls objectAtIndex:0] objectForKey:@"m_down_url"];
                insertModel.playTime = @"0";
                insertModel.video_id = model.video_id;
                [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
                
                NSMutableArray * arr = [[NSMutableArray alloc] init];
                for (int i=0; i<[model.urls count]; i++) {
                    RMModel * playmodel = [[RMModel alloc] init];
                    playmodel.url = [[model.urls objectAtIndex:i] objectForKey:@"m_down_url"];
                    playmodel.title = model.name;
                    playmodel.EpisodeValue = [[model.urls objectAtIndex:i] objectForKey:@"order"];
                    [arr addObject:playmodel];
                }
                [RMPlayer presentVideoPlayerWithPlayArray:arr withUIViewController:self withVideoType:2];
            }
            break;
        }

        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

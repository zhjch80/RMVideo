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
    
    _slideSwitchView.BGImgArr = [NSMutableArray arrayWithObjects:@"movie_unSelected",@"teleplay_unSelected",@"variety_unSelected",nil];
    _slideSwitchView.SelectBtnImageArray = [NSMutableArray arrayWithObjects:@"movie_selected",@"teleplay_selected",@"variety_selected", nil];
    
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
        _slideSwitchView.btnHeight = 40;
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
        NSLog(@"slie to 第一个");
    } else if (number == 1) {
        NSLog(@"slie to 第二个");
    } else if (number == 2) {
        NSLog(@"slie to 第三个");
    }
}

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
}
#pragma mark delegate
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

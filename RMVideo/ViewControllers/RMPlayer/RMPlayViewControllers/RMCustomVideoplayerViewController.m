//
//  RMCustomVideoplayerViewController.m
//  RMCustomPlayer
//
//  Created by runmobile on 14-12-3.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMCustomVideoplayerViewController.h"
#import "UtilityFunc.h"
#import "UIButton+EnlargeEdge.h"
#import "RMTickerView.h"
#import "RMTouchVIew.h"
#import "RMCustomVideoPlayerView.h"
#import "RMLoadingView.h"
#import "RMCustomSVProgressHUD.h"
#import "Reachability.h"
#import "RMEpisodeView.h"

#define FONT(F) [UIFont fontWithName:@"FZHTJW--GB1-0" size:F]

@interface RMCustomVideoplayerViewController ()<TouchViewDelegate,UIAlertViewDelegate,UIScrollViewDelegate>{
    id playbackObserver;
    Reachability *hostReach;

}
@property (nonatomic, strong) UIImageView * topView;                //上工具条
@property (nonatomic, strong) UIView * selectEpisodeView;           //选集视图
@property (nonatomic, strong) UIScrollView * selectEpisodeScr;      //选集视图中的ScrView

@property (nonatomic, strong) RMTouchVIew * touchView;              //添加手势
@property (nonatomic, strong) UIButton * nextBtn;                   //下一个视频
@property (nonatomic, strong) UIButton *selectEpisodeBtn;           //选集按钮
@property (nonatomic, strong) RMTickerView * videoTitleCycle;       //视频滚动标题
@property (nonatomic, strong) UILabel * videoTitle;                 //视频不滚动标题

@property (nonatomic, strong) RMLoadingView * loadingView;          //HUD
@property (nonatomic, strong) RMCustomSVProgressHUD * customHUD;    //HUD

@property (nonatomic, strong) UILabel * goneTime;                   //视频已播放时间
@property (nonatomic, strong) UILabel * totalTime;                  //视频总共时间

@property (nonatomic, assign) BOOL isPop;                           //选集view 是否弹出 YES 弹出  NO 隐藏
@property (nonatomic, assign) BOOL isCycle;                         //标题是否循环滚动
@property (nonatomic, assign) BOOL isHidenToolView;                 //上下工具条是否隐藏 YES 隐藏  NO 显示

@property (nonatomic, assign) CGFloat noOperationSecond;            //用户在播放器界面没有任何操作的持续时间，发生任何操作刷新此时间为0 单位：秒

@property (nonatomic, copy) NSString *positionIdentifier;           //判断当前是否是左右滑动
@property (nonatomic, assign) int fastForwardOrRetreatQuickly;      //视频若快进和快退时，标记当前的位置

@property (nonatomic, strong) RMCustomVideoPlayerView * player;



- (void)reachabilityChanged: (NSNotification *)note;//网络连接改变
- (void)updateInterfaceWithReachability:(Reachability *)curReach;//处理连接改变后的情况

@end

@implementation RMCustomVideoplayerViewController

- (void)dealloc {
    self.player = nil;
    if (playbackObserver) {
        [self.player.moviePlayer removeTimeObserver:playbackObserver];
        playbackObserver = nil;
    }
    self.topView = nil;
    self.belowView = nil;
    self.selectEpisodeView = nil;
    self.playBtn = nil;
    self.nextBtn = nil;
    self.videoTitleCycle = nil;
    self.loadingView = nil;
    self.customHUD = nil;
    self.goneTime = nil;
    self.totalTime = nil;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isPop = NO;
    self.isHidenToolView = NO;
    self.isCycle = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadMediaPlayerView];
    [self loadPlayView];
    [self loadTouchView];
    [self loadSelectEpisodeView];
    [self StartTimerWithAutomaticHidenToolView];
    [self loadHUD];

    //开启网络状况的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name: kReachabilityChangedNotification_One object: nil];
        hostReach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    [hostReach startNotifier];
    [self updateInterfaceWithReachability:hostReach];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

//监听到网络状态改变
- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    [self updateInterfaceWithReachability: curReach];
}

//处理连接改变后的情况
- (void)updateInterfaceWithReachability:(Reachability *)curReach {
    //对连接改变做出响应的处理动作。
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if(status == ReachableViaWWAN) {
        printf("\n3g/2G\n");
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您现在使用的是运营商网络，继续观看可能产生超额流量费" delegate:self cancelButtonTitle:@"取消观看" otherButtonTitles:@"继续观看", nil];
        alert.tag = 201;
        [alert show];
    }else if(status == ReachableViaWiFi) {
        printf("\nwifi\n");
    }else{
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前无网络连接，请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark -

- (void)loadHUD {
    self.loadingView = [[RMLoadingView alloc] init];
    self.loadingView.frame = CGRectMake([UtilityFunc shareInstance].globleAllHeight/2-20, [UtilityFunc shareInstance].globleWidth/2-20, 40, 40);
    [self.view addSubview:self.loadingView];
    [self.loadingView startAnimation];
    
    self.customHUD = [[NSBundle mainBundle] loadNibNamed:@"RMCustomSVProgressHUD" owner:self options:nil].lastObject;
    self.customHUD.hidden = YES;
    self.customHUD.frame = CGRectMake(([UtilityFunc shareInstance].globleAllHeight-193)/2, ([UtilityFunc shareInstance].globleWidth-133)/2, 193, 133);
    [self.view addSubview:self.customHUD];
}

- (void)showHUD {
    self.loadingView.hidden = NO;
    [self.loadingView startAnimation];
}

- (void)hideHUD {
    self.loadingView.hidden = YES;
    [self.loadingView stopAnimation];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self RefreshTimerWithAutomaticHidenToolView];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 201){
        switch (buttonIndex) {
            case 0:{
                [self.player removeFromSuperview];
                [self.player pause];
                if (playbackObserver) {
                    [self.player.moviePlayer removeTimeObserver:playbackObserver];
                    playbackObserver = nil;
                }
                [self.player removeObserver];
                self.player = nil;
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
                break;
            }
            case 1:{
                break;
            }
                
            default:
                break;
        }
    }else if (alertView.tag == 202){
        switch (buttonIndex) {
            case 0:{
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
                break;
            }
                
            default:
                break;
        }
    }
}

#pragma mark - 创建 AVPlayer UI 及 播放url

- (void)loadMediaPlayerView {
    if (!self.player) {
        self.player = [[RMCustomVideoPlayerView alloc] init];
        [self.player cacheProgress:^(float progress) {
            [self.cacheProgress setProgress:progress animated:YES];
        }];
        self.player.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth);
        self.player.RMCustomVideoplayerDeleagte = self;
        self.player.backgroundColor = [UIColor blackColor];
        [self.view addSubview:self.player];
    }
    if (self.videoType == MovieType) {
//TODO:播放电影
        [self playerWithURL:self.videlModel.url];
    }else{
//TODO:播放电视剧
        if (self.currentPlayOrder < self.playModelArr.count){
            RMModel * model = [self.playModelArr objectAtIndex:self.currentPlayOrder];
            [self playerWithURL:model.url];
        }else{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有找到对应集数得播放地址" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (void)playerWithURL:(NSString *)url {
    NSURL * _URL = nil;
    if(self.isLocationVideo){
        _URL = [NSURL fileURLWithPath:url];
    }else{
        _URL = [NSURL URLWithString:url];
    }
    [self.player contentURL:_URL];
    [self.player play];
    [self.playBtn setImage:[UIImage imageNamed:@"rm_play_btn"] forState:UIControlStateNormal];
    
    CMTime interval = CMTimeMake(33, 1000);
    __weak __typeof(self) weakself = self;
    if (playbackObserver) {
        [self.player.moviePlayer removeTimeObserver:playbackObserver];
        playbackObserver = nil;
    }
    playbackObserver = [self.player.moviePlayer addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock: ^(CMTime time) {
        CMTime endTime = CMTimeConvertScale (weakself.player.moviePlayer.currentItem.asset.duration, weakself.player.moviePlayer.currentTime.timescale, kCMTimeRoundingMethod_RoundHalfAwayFromZero);
        if (CMTimeCompare(endTime, kCMTimeZero) != 0) {
            double normalizedTime = (double) weakself.player.moviePlayer.currentTime.value / (double) endTime.value;
            weakself.progressBar.value = normalizedTime;
        }
        weakself.goneTime.text = [weakself getStringFromCMTime:weakself.player.moviePlayer.currentTime];
        [weakself.goneTime sizeToFit];
        weakself.totalTime.text = [weakself getStringFromCMTime:weakself.player.moviePlayer.currentItem.asset.duration];
        [weakself.totalTime sizeToFit];
        weakself.customHUD.totalTimeString = weakself.totalTime.text;
    }];
}

/**
 * 视频播放完成
 */
- (void)playerFinishedPlay {
    if (self.videoType == MovieType){
        if (playbackObserver) {
            [self.player.moviePlayer removeTimeObserver:playbackObserver];
            playbackObserver = nil;
        }
        [self.player removeObserver];
        self.player = nil;
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else if(self.videoType == TeleplayType){
        self.currentPlayOrder ++;
        if (self.currentPlayOrder < self.playModelArr.count){
            RMModel * model = [self.playModelArr objectAtIndex:self.currentPlayOrder];
            [self playerWithURL:model.url];
            NSArray *tickerStrings;
            CGSize  titleSize;

            tickerStrings = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",model.title], nil];
            titleSize = [UtilityFunc boundingRectWithSize:CGSizeMake(100000, 100000) font:[UIFont systemFontOfSize:22.0] text:model.title];
            
            if (titleSize.width > [UtilityFunc shareInstance].globleAllHeight - 60){
                self.videoTitleCycle.frame = CGRectMake(60, 13, titleSize.width, 40);
                [self.videoTitleCycle setDirection:JHTickerDirectionLTR];
                [self.videoTitleCycle setTickerStrings:tickerStrings];
                [self.videoTitleCycle setTickerSpeed:30.0f];
                [self.videoTitleCycle start];
                self.videoTitle.hidden = YES;
                self.videoTitleCycle.hidden = NO;
                self.isCycle = YES;
            }else{
                self.videoTitle.text = model.title;
                self.videoTitle.hidden = NO;
                self.videoTitleCycle.hidden = YES;
                self.isCycle = NO;
            }
        }else{
            if (playbackObserver) {
                [self.player.moviePlayer removeTimeObserver:playbackObserver];
                playbackObserver = nil;
            }
            [self.player removeObserver];
            self.player = nil;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else{
        if ([UtilityFunc isConnectionAvailable] == 0){
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前无网络连接，请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }else{
            UIButton * button = [[UIButton alloc] init];;
            button.tag = 103;
            [self buttonClick:button];
        }
    }
}

#pragma mark -

/**
 *  创建播放器UI
 */
- (void)loadPlayView {
    self.topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleAllHeight, 64)];
    self.topView.alpha = 0.8;
    self.topView.userInteractionEnabled = YES;
    self.topView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.topView];
    
    UIButton * backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(15, 20, 35, 35);
    [backBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.tag = 101;
    [backBtn setEnlargeEdgeWithTop:10 right:15 bottom:10 left:10];
    [backBtn setImage:[UIImage imageNamed:@"rm_backup"] forState:UIControlStateNormal];
    [self.topView addSubview:backBtn];
    
    self.videoTitleCycle = [[RMTickerView alloc] init];
    self.videoTitle = [[UILabel alloc] init];
    [self.topView addSubview:self.videoTitleCycle];
    [self.topView addSubview:self.videoTitle];

    NSArray *tickerStrings;
    CGSize  titleSize;
    if (self.videoType == MovieType) {
        tickerStrings = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",self.videlModel.title], nil];
        titleSize = [UtilityFunc boundingRectWithSize:CGSizeMake(100000, 100000) font:[UIFont systemFontOfSize:22.0] text:self.videlModel.title];
        self.videoTitle.text = self.videlModel.title;
    }else{
        RMModel * model = [self.playModelArr objectAtIndex:self.currentPlayOrder];
        tickerStrings = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",model.title], nil];
        titleSize = [UtilityFunc boundingRectWithSize:CGSizeMake(100000, 100000) font:[UIFont systemFontOfSize:22.0] text:model.title];
        self.videoTitle.text = model.title;
    }
    
    if (titleSize.width > [UtilityFunc shareInstance].globleAllHeight - 60){
        self.videoTitleCycle.frame = CGRectMake(60, 20, titleSize.width, 40);
        [self.videoTitleCycle setDirection:JHTickerDirectionLTR];
        [self.videoTitleCycle setTickerStrings:tickerStrings];
        [self.videoTitleCycle setTickerSpeed:30.0f];
        [self.videoTitleCycle start];
        self.videoTitle.hidden = YES;
        self.videoTitleCycle.hidden = NO;
        self.isCycle = YES;
    }else{
        self.videoTitle.frame = CGRectMake(60, 18, [UtilityFunc shareInstance].globleAllHeight - 60, 40);
        self.videoTitle.font = FONT(22.0);
        self.videoTitle.backgroundColor = [UIColor clearColor];
        self.videoTitle.textColor = [UIColor whiteColor];
        self.videoTitle.hidden = NO;
        self.videoTitleCycle.hidden = YES;
        self.isCycle = NO;
    }
    
    self.belowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, [UtilityFunc shareInstance].globleWidth - 60, [UtilityFunc shareInstance].globleAllHeight, 60)];
    self.belowView.userInteractionEnabled = YES;
    self.belowView.alpha = 0.8;
    self.belowView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.belowView];
    
    self.playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playBtn.frame = CGRectMake(15, 10, 40, 40);
    [self.playBtn setEnlargeEdgeWithTop:10 right:5 bottom:10 left:5];
    [self.playBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.playBtn.tag = 102;
    [self.playBtn setImage:[UIImage imageNamed:@"rm_play_btn"] forState:UIControlStateNormal];
    [self.belowView addSubview:self.playBtn];
    
    self.nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextBtn.frame = CGRectMake(60, 10, 40, 40);
    [self.nextBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.nextBtn setImage:[UIImage imageNamed:@"rm_next_btn"] forState:UIControlStateNormal];
    self.nextBtn.tag = 103;
    [self.belowView addSubview:self.nextBtn];
    
    if (self.videoType == MovieType){
        self.nextBtn.enabled = NO;
    }else{
        self.nextBtn.enabled = YES;
    }

    self.goneTime = [[UILabel alloc] initWithFrame:CGRectMake(120, 22, 70, 30)];
    self.goneTime.textColor = [UIColor colorWithRed:0.96 green:0.95 blue:0.95 alpha:1];
    self.goneTime.text = @"00:00";
    self.goneTime.font = [UIFont systemFontOfSize:13.0];
    [self.goneTime sizeToFit];
    self.goneTime.backgroundColor = [UIColor clearColor];
    [self.belowView addSubview:self.goneTime];
    
    self.totalTime = [[UILabel alloc] initWithFrame:CGRectMake([UtilityFunc shareInstance].globleAllHeight - 120, 22, 70, 30)];
    self.totalTime.textColor = [UIColor colorWithRed:0.96 green:0.95 blue:0.95 alpha:1];
    self.totalTime.font = [UIFont systemFontOfSize:13.0];
    self.totalTime.text = @"00:00";
    [self.totalTime sizeToFit];
    self.totalTime.backgroundColor = [UIColor clearColor];
    [self.belowView addSubview:self.totalTime];
    
    self.cacheProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(182, 29, [UtilityFunc shareInstance].globleAllHeight - 324, 30)];
    self.cacheProgress.progressTintColor = [UIColor colorWithRed:0.89 green:0.11 blue:0.04 alpha:1];
    self.cacheProgress.trackTintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    [self.belowView addSubview:self.cacheProgress];
    
    self.progressBar = [[UISlider alloc] init];
    self.progressBar.frame = CGRectMake(180, 15, [UtilityFunc shareInstance].globleAllHeight - 320, 30);
    //滑条
    self.progressBar.minimumTrackTintColor = [UIColor redColor];
    self.progressBar.maximumTrackTintColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    //滑块图片
    UIImage * thumbImage = [UIImage imageNamed:@"rm_sliderdot"];
    [self.progressBar setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.progressBar setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [self.progressBar addTarget:self action:@selector(progressBarChanged:) forControlEvents:UIControlEventValueChanged];
    [self.belowView addSubview:self.progressBar];
    
    self.selectEpisodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectEpisodeBtn.frame = CGRectMake([UtilityFunc shareInstance].globleAllHeight - 60, 22, 67/2, 33/2);
    [self.selectEpisodeBtn setImage:[UIImage imageNamed:@"rm_choose_btn"] forState:UIControlStateNormal];
    [self.selectEpisodeBtn setEnlargeEdgeWithTop:10 right:10 bottom:20 left:10];
    [self.selectEpisodeBtn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.selectEpisodeBtn.tag = 104;
    [self.belowView addSubview:self.selectEpisodeBtn];
    
    if (self.videoType == MovieType){
        self.selectEpisodeBtn.hidden = YES;
    }else{
        self.selectEpisodeBtn.hidden = NO;
    }
}

/**
 *  创建选集UI
 */
- (void)loadSelectEpisodeView {
    self.selectEpisodeView = [[UIView alloc] init];
    self.selectEpisodeView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    self.selectEpisodeView.hidden = YES;
    [self.view addSubview:self.selectEpisodeView];
    
    self.selectEpisodeScr = [[UIScrollView alloc] init];
    self.selectEpisodeScr.delegate = self;
    self.selectEpisodeScr.backgroundColor = [UIColor clearColor];
    [self.selectEpisodeView addSubview:self.selectEpisodeScr];
    
    int value = (int)self.playModelArr.count;
    
    int Horizontal = 3;             //横排
    int Vertical = value/3;         //竖排
    BOOL isRemainder = NO;          //是否有余数
    
    if (value%3 != 0){
        isRemainder = YES;
        Vertical ++;
    }
    
    self.selectEpisodeView.frame = CGRectMake([UtilityFunc shareInstance].globleAllHeight, 64, 240, [UtilityFunc shareInstance].globleWidth - 104);
    self.selectEpisodeScr.frame = CGRectMake(0, 0, 240, [UtilityFunc shareInstance].globleWidth - 104);
    self.selectEpisodeScr.contentSize = CGSizeMake(240, 20 + 50*Vertical);
    
    int cycleValue=0;
    for (int i=0; i<Vertical; i++) {
        for (int j=0;j<Horizontal; j++){
            if (cycleValue == self.playModelArr.count){
                return;
            }
            RMModel * model = [self.playModelArr objectAtIndex:cycleValue];
            RMEpisodeView * spisodeView = [[RMEpisodeView alloc] initWithFrame:CGRectMake(15 + 75*j, 20 + 50*i, 60, 30)];
            spisodeView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
            spisodeView.tag = cycleValue;
            [spisodeView.layer setCornerRadius:15.0];
            [spisodeView loadEpisodeViewWithNumber:[NSString stringWithFormat:@"%@",model.EpisodeValue]];
            [spisodeView addTarget:self WithSelector:@selector(ChooseSpisode:)];
            [self.selectEpisodeScr addSubview:spisodeView];
            cycleValue++;
        }
    }
}

- (void)ChooseSpisode:(RMEpisodeView *)spisodeView {
    RMModel * model = [self.playModelArr objectAtIndex:spisodeView.tag];
    [self.player replaceCurrentItem];
    if (playbackObserver) {
        [self.player.moviePlayer removeTimeObserver:playbackObserver];
        playbackObserver = nil;
    }
    [self.player removeObserver];
    [self showHUD];
    if (self.videoType == MovieType) {
    }else{
        self.currentPlayOrder = spisodeView.tag;
        [self playerWithURL:model.url];
        NSArray *tickerStrings;
        CGSize  titleSize;
        
        tickerStrings = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",model.title], nil];
        titleSize = [UtilityFunc boundingRectWithSize:CGSizeMake(100000, 100000) font:[UIFont systemFontOfSize:22.0] text:model.title];
        
        if (titleSize.width > [UtilityFunc shareInstance].globleAllHeight - 60){
            self.videoTitleCycle.frame = CGRectMake(60, 13, titleSize.width, 40);
            [self.videoTitleCycle setDirection:JHTickerDirectionLTR];
            [self.videoTitleCycle setTickerStrings:tickerStrings];
            [self.videoTitleCycle setTickerSpeed:30.0f];
            [self.videoTitleCycle start];
            self.videoTitle.hidden = YES;
            self.videoTitleCycle.hidden = NO;
            self.isCycle = YES;
        }else{
            self.videoTitle.text = model.title;
            self.videoTitle.hidden = NO;
            self.videoTitleCycle.hidden = YES;
            self.isCycle = NO;
        }
    }
    [self gestureRecognizerOneTapMetohd];
}

/**
 *  添加手势
 */
- (void)loadTouchView {
    self.touchView = [[RMTouchVIew alloc] initWithFrame:CGRectMake(0, 64, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth-64-49)];
    self.touchView.delegate = self;
    [self.view addSubview:self.touchView];
}

#pragma mark - 自动隐藏工具条操作

/**
 *  开始记时
 */
- (void)StartTimerWithAutomaticHidenToolView {
    [self performSelector:@selector(automaticHidenToolView) withObject:nil afterDelay:3.0];
}

/**
 *  刷新时间
 */
- (void)RefreshTimerWithAutomaticHidenToolView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(automaticHidenToolView) object:nil];
    [self performSelector:@selector(automaticHidenToolView) withObject:nil afterDelay:3.0];
}

#pragma mark - TouchViewDelegate 

- (void)touchInViewOfLocation:(float)space andDirection:(NSString *)direction slidingPosition:(NSString *)position {
    if([direction isEqualToString:@"right"]){
        [self showHUD];
        self.positionIdentifier = direction;
        if(self.player.isPlaying){
            [self.player pause];
            [self.playBtn setImage:[UIImage imageNamed:@"rm_pause_btn"] forState:UIControlStateNormal];
        }
        BOOL isfastForward = NO;
        if(space>0){
            isfastForward = YES;
        }
        [self.customHUD showWithState:isfastForward andNowTime:self.fastForwardOrRetreatQuickly];
        self.fastForwardOrRetreatQuickly = self.fastForwardOrRetreatQuickly - space;
    }else if([direction isEqualToString:@"left"]){
        [self showHUD];
        self.positionIdentifier = direction;
        if(self.player.isPlaying){
            [self.player pause];
            [self.playBtn setImage:[UIImage imageNamed:@"rm_pause_btn"] forState:UIControlStateNormal];
        }
        BOOL isfastForward = NO;
        if(space>0){
            isfastForward = YES;
        }
        [self.customHUD showWithState:isfastForward andNowTime:self.fastForwardOrRetreatQuickly];
        self.fastForwardOrRetreatQuickly = self.fastForwardOrRetreatQuickly -  space;
    }
    else if ([direction isEqualToString:@"down"]){
        if([position isEqualToString:@"left"]){//控制声音
            MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
            float num = mpc.volume;
            num += space/100;
            mpc.volume = num;  //0.0~1.0
        }else if([position isEqualToString:@"right"]){//控制屏幕亮度
            float num =[UIScreen mainScreen].brightness;
            num += space/100;
            [UIScreen mainScreen].brightness = num;
        }
    }
    else if ([direction isEqualToString:@"up"]){
        if([position isEqualToString:@"left"]){//控制声音
            MPMusicPlayerController *mpc = [MPMusicPlayerController applicationMusicPlayer];
            float num  = mpc.volume;
            num += space/100;
            mpc.volume = num;  //0.0~1.0
        }else if([position isEqualToString:@"right"]){//控制屏幕亮度
            float num =[UIScreen mainScreen].brightness;
            num += space/100;
            [UIScreen mainScreen].brightness = num;
        }
    }
    [self RefreshTimerWithAutomaticHidenToolView];
}

- (void)gestureRecognizerStateEnded {
    if([self.positionIdentifier isEqualToString:@"right"]||[self.positionIdentifier isEqualToString:@"left"]){
        CMTime seekTime = CMTimeMakeWithSeconds(self.fastForwardOrRetreatQuickly, self.player.moviePlayer.currentTime.timescale);
        [self.player.moviePlayer seekToTime:seekTime];
        [self.player play];
        [self.playBtn setImage:[UIImage imageNamed:@"rm_play_btn"] forState:UIControlStateNormal];
    }
    [self RefreshTimerWithAutomaticHidenToolView];
}

- (void)gestureRecognizerStateBegan {
    self.positionIdentifier = @"none";
    self.fastForwardOrRetreatQuickly = self.progressBar.value * (double)self.player.moviePlayer.currentItem.asset.duration.value/(double)self.player.moviePlayer.currentItem.asset.duration.timescale;
    [self RefreshTimerWithAutomaticHidenToolView];
}

/**
 *  隐藏工具条
 */
- (void)gestureRecognizerOneTapMetohd {
    if (self.isHidenToolView){
        [UIView animateWithDuration:0.3 animations:^{
            self.topView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleAllHeight, 64);
            self.belowView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleWidth - 60, [UtilityFunc shareInstance].globleAllHeight, 60);
        } completion:^(BOOL finished) {
            self.isHidenToolView = NO;
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.topView.frame = CGRectMake(0, -64, [UtilityFunc shareInstance].globleAllHeight, 64);
            self.belowView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight, 60);
        } completion:^(BOOL finished) {
            self.isHidenToolView = YES;
        }];
    }
    if (self.isPop){
        [UIView animateWithDuration:0.3 animations:^{
            self.selectEpisodeView.frame = CGRectMake([UtilityFunc shareInstance].globleAllHeight, 64, 240, [UtilityFunc shareInstance].globleWidth - 104);
        } completion:^(BOOL finished) {
            self.isPop = NO;
            self.selectEpisodeView.hidden = YES;
        }];
    }
    [self RefreshTimerWithAutomaticHidenToolView];
}

/**
 * 双击暂停播放 或者 开始播放
 */
- (void)gestureRecognizerTwoTapMetohd {
    if (self.player.isPlaying) {
        [self.player pause];
        [self.playBtn setImage:[UIImage imageNamed:@"rm_pause_btn"] forState:UIControlStateNormal];
    } else {
        [self.player play];
        [self.playBtn setImage:[UIImage imageNamed:@"rm_play_btn"] forState:UIControlStateNormal];
    }
    [self RefreshTimerWithAutomaticHidenToolView];
}

#pragma mark -

- (void)buttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 101:{//返回
            [self.player pause];
            if (playbackObserver) {
                [self.player.moviePlayer removeTimeObserver:playbackObserver];
                playbackObserver = nil;
            }
            [self.player removeObserver];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
            break;
        }
        case 102:{//播放 或者 暂停
            if (self.player.isPlaying) {
                [self.player pause];
                [self.playBtn setImage:[UIImage imageNamed:@"rm_pause_btn"] forState:UIControlStateNormal];
            } else {
                [self.player play];
                [self.playBtn setImage:[UIImage imageNamed:@"rm_play_btn"] forState:UIControlStateNormal];
            }
            [self RefreshTimerWithAutomaticHidenToolView];
            break;
        }
        case 103:{//下一集
            [self.player replaceCurrentItem];
            if (playbackObserver) {
                [self.player.moviePlayer removeTimeObserver:playbackObserver];
                playbackObserver = nil;
            }
            [self.player removeObserver];
            [self showHUD];
            if (self.videoType == MovieType) {
            }else{
//TODO:播放下一集电视剧
                self.currentPlayOrder ++;
                if (self.currentPlayOrder < self.playModelArr.count){
                    RMModel * model = [self.playModelArr objectAtIndex:self.currentPlayOrder];
                    [self playerWithURL:model.url];
                    NSArray *tickerStrings;
                    CGSize  titleSize;

                    tickerStrings = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",model.title], nil];
                    titleSize = [UtilityFunc boundingRectWithSize:CGSizeMake(100000, 100000) font:[UIFont systemFontOfSize:22.0] text:model.title];

                    if (titleSize.width > [UtilityFunc shareInstance].globleAllHeight - 60){
                        self.videoTitleCycle.frame = CGRectMake(60, 13, titleSize.width, 40);
                        [self.videoTitleCycle setDirection:JHTickerDirectionLTR];
                        [self.videoTitleCycle setTickerStrings:tickerStrings];
                        [self.videoTitleCycle setTickerSpeed:30.0f];
                        [self.videoTitleCycle start];
                        self.videoTitle.hidden = YES;
                        self.videoTitleCycle.hidden = NO;
                        self.isCycle = YES;
                    }else{
                        self.videoTitle.text = model.title;
                        self.videoTitle.hidden = NO;
                        self.videoTitleCycle.hidden = YES;
                        self.isCycle = NO;
                    }
                }else{
                    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"已经播放完所有视频" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    alert.tag = 202;
                    [alert show];
                }
            }
            [self RefreshTimerWithAutomaticHidenToolView];
            break;
        }
        case 104:{//弹出选集 或者 隐藏选集
            if (self.isPop){
                [UIView animateWithDuration:0.3 animations:^{
                    self.selectEpisodeView.frame = CGRectMake([UtilityFunc shareInstance].globleAllHeight, 64, 240, [UtilityFunc shareInstance].globleWidth - 104);
                } completion:^(BOOL finished) {
                    self.isPop = NO;
                    self.selectEpisodeView.hidden = YES;
                }];
            }else{
                self.selectEpisodeView.hidden = NO;
                [UIView animateWithDuration:0.3 animations:^{
                    self.selectEpisodeView.frame = CGRectMake([UtilityFunc shareInstance].globleAllHeight - 240, 64, 240, [UtilityFunc shareInstance].globleWidth - 104);
                } completion:^(BOOL finished) {
                    self.isPop = YES;
                }];
            }
            [self RefreshTimerWithAutomaticHidenToolView];
            break;
        }
            
        default:
            break;
    }
}

-(void)progressBarChanged:(UISlider*)sender {
    [self showHUD];
    if (self.player.isPlaying) {
        [self.player.moviePlayer pause];
        [self.playBtn setImage:[UIImage imageNamed:@"rm_pause_btn"] forState:UIControlStateNormal];
    }
    CMTime seekTime = CMTimeMakeWithSeconds(sender.value * (double)self.player.moviePlayer.currentItem.asset.duration.value/(double)self.player.moviePlayer.currentItem.asset.duration.timescale, self.player.moviePlayer.currentTime.timescale);
    [self.player.moviePlayer seekToTime:seekTime];
    [self.player play];
    [self.playBtn setImage:[UIImage imageNamed:@"rm_play_btn"] forState:UIControlStateNormal];
    [self RefreshTimerWithAutomaticHidenToolView];
}

#pragma mark - 工具

-(NSString*)getStringFromCMTime:(CMTime)time {
    Float64 currentSeconds = CMTimeGetSeconds(time);
    int mins = currentSeconds/60.0;
    int secs = fmodf(currentSeconds, 60.0);
    NSString *minsString = mins < 10 ? [NSString stringWithFormat:@"0%d", mins] : [NSString stringWithFormat:@"%d", mins];
    NSString *secsString = secs < 10 ? [NSString stringWithFormat:@"0%d", secs] : [NSString stringWithFormat:@"%d", secs];
    return [NSString stringWithFormat:@"%@:%@", minsString, secsString];
}

/**
 *  自动隐藏工具条
 */
- (void)automaticHidenToolView {
    if (!self.isHidenToolView){
        [UIView animateWithDuration:0.3 animations:^{
            self.topView.frame = CGRectMake(0, -64, [UtilityFunc shareInstance].globleAllHeight, 64);
            self.belowView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight, 60);
        } completion:^(BOOL finished) {
            self.isHidenToolView = YES;
        }];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.selectEpisodeView.frame = CGRectMake([UtilityFunc shareInstance].globleAllHeight, 64, 240, [UtilityFunc shareInstance].globleWidth - 104);
    } completion:^(BOOL finished) {
        self.isPop = NO;
        self.selectEpisodeView.hidden = YES;
    }];
}

#pragma mark - 设备方向

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return UIDeviceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;//只支持这一个方向(正常的方向)
}

@end

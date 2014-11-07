//
//  CustomVideoPlayerController.m
//  LawtvApp
//
//  Created by Mac on 14-6-10.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import "CustomVideoPlayerController.h"
#import "CustomVideoPlayerView.h"
#import "UtilityFunc.h"

#define kTopToolHeight 49
#define kTopToolTitleHeight 35

#define kVideoTitleX 50
#define kVideoTitleY 21

@interface CustomVideoPlayerController ()<playerViewDelegate>
@property (nonatomic, strong) CustomVideoPlayerView *player;
@property (nonatomic, strong) UIView *topTool;
@property (nonatomic, strong) UILabel *videoTitle;
@property (nonatomic, strong) NSMutableArray *playList;
@end

@implementation CustomVideoPlayerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    self.player    = nil;
    self.title     = nil;
    self.playList  = nil;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPlayerView];
    [self createTopTool];
}

/**
 *
 * 顶部工具栏
 *
 ***/
- (void)createTopTool {
    self.topTool = [[UIView alloc] init];
    [self.topTool setFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleAllHeight, kTopToolHeight)];
    [self.topTool setBackgroundColor:[UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:0.4]];
    self.topTool.userInteractionEnabled = YES;
    [self.view addSubview:self.topTool];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(10, 18, 25, 25)];
    [button setImage:[UIImage imageNamed:@"backup_img"]
                  forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"backup_img"]
                  forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(buttonClick:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.topTool addSubview:button];
    
    self.videoTitle = [[UILabel alloc] init];
    [self.videoTitle setFrame:CGRectMake(kVideoTitleX, 15, [UtilityFunc shareInstance].globleWidth - kVideoTitleX - 10, kTopToolTitleHeight)];
    self.videoTitle.font = [UIFont systemFontOfSize:16.0];
    self.videoTitle.backgroundColor = [UIColor clearColor];
    self.videoTitle.userInteractionEnabled = YES;
    [self.videoTitle setText:@"视频"];
    [self.videoTitle setTextAlignment:NSTextAlignmentLeft];
    [self.videoTitle setTextColor:[UIColor whiteColor]];
    [self.topTool addSubview:self.videoTitle];

    
}

- (void)buttonClick:(UIButton *)sender {
    [self.player CustomViewWillDisappear];
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self.player pause];
    }];
}

/**
 *
 * 播放器
 *
 ***/
- (void)createPlayerView
{
    [self.view setBackgroundColor:[UIColor blackColor]];
    if (self.player == nil) {
        self.player = [[CustomVideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleAllHeight)];
        self.player.delegate = self;
        self.player.tintColor = [UIColor redColor];
        [self.view addSubview:self.player];
    }
    NSLog(@"self.playURL:%@",self.playURL);
    [self playerWithURL:nil];
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
    [self.player setSelectionEpisodeScrollViewWithArray:array];
}

- (void)playerWithURL:(NSString *)url {
    if ([url hasPrefix:@"\n"]) {
        url = [url stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    NSString * str = [NSString stringWithFormat:@"http://106.38.249.114/youku/656E038DFE447BC536B83461/03002001005439CC9580451A5769AC4BF48DC8-145C-4B0A-359C-FD5DD83F2B8D.mp4"];
    
#if 1
    NSURL * URL = [NSURL URLWithString:str];

//    NSURL * URL=[[NSURL alloc] initWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSURL * URL = [NSURL URLWithString:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
#else
    NSString * str = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    NSURL * URL = [NSURL fileURLWithPath:str];
#endif

    [self.player contentURL:URL];
    [self.player play];
    self.player.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth);
    self.videoTitle.frame = CGRectMake(kVideoTitleX, kVideoTitleY, [UtilityFunc shareInstance].globleAllHeight - kVideoTitleX - 10, kTopToolTitleHeight);
    self.topTool.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleAllHeight, kTopToolHeight);
    [self.player setIsFullScreenMode:YES];
    [self.player zoomButtonPressed];
    //跳转到2分10秒处播放
    //[self.player setAVPlayerWithTime:130];
}
-(void)playerFinishedPlayback:(CustomVideoPlayerView*)view{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"播放完成");
}
-(void)playViewTouchesEnded{
    if(self.topTool.frame.origin.y==0){
        [UIView animateWithDuration:0.44 animations:^{
            self.topTool.frame = CGRectMake(0, -kTopToolHeight-44, [UtilityFunc shareInstance].globleAllHeight, kTopToolHeight);
            [UIApplication sharedApplication].statusBarHidden = YES;
        } completion:^(BOOL finished) {
        }];
    }else{
        [UIView animateWithDuration:0.44 animations:^{
            self.topTool.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleAllHeight, kTopToolHeight);
        } completion:^(BOOL finished) {
            [UIApplication sharedApplication].statusBarHidden = NO;
        }];
    }
}
//TODO:播放下一集
-(void)selectTVEpisodeWithIndex:(NSInteger)index{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

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

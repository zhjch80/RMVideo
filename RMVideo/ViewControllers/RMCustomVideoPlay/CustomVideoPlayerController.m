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

#define kTopToolHeight 44
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

/**
 播放界面隐藏 statusbar
 */
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
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
    [button setImage:[UIImage imageNamed:@"fanhui"]
                  forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"fanhui"]
                  forState:UIControlStateHighlighted];
    [button setFrame:CGRectMake(10, 8, 25, 25)];
    [button addTarget:self action:@selector(buttonClick:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.topTool addSubview:button];
    
    self.videoTitle = [[UILabel alloc] init];
    [self.videoTitle setFrame:CGRectMake(kVideoTitleX, 5, [UtilityFunc shareInstance].globleWidth - kVideoTitleX - 10, kTopToolTitleHeight)];
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
    [self dismissViewControllerAnimated:YES completion:nil];
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
    [self playerWithURL:nil];
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"",@"", nil];
    [self.player setSelectionEpisodeScrollViewWithArray:array];
}

- (void)playerWithURL:(NSString *)url {
    NSLog(@"start play video!!!");
    
    NSString * str = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp4"];
    NSURL * _URL = [NSURL fileURLWithPath:str];

    [self.player contentURL:_URL];
    [self.player play];
    self.player.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth);
    self.videoTitle.frame = CGRectMake(kVideoTitleX, kVideoTitleY, [UtilityFunc shareInstance].globleAllHeight - kVideoTitleX - 10, kTopToolTitleHeight);
    self.topTool.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleAllHeight, kTopToolHeight);
    [self.player setIsFullScreenMode:YES];
    [self.player zoomButtonPressed];
    //跳转到2分10秒处播放
    [self.player setAVPlayerWithTime:130];
}
-(void)playerFinishedPlayback:(CustomVideoPlayerView*)view{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"播放完成");
}
-(void)playViewTouchesEnded{
    if(self.topTool.frame.origin.y==0){
        [UIView animateWithDuration:0.3 animations:^{
            self.topTool.frame = CGRectMake(0, -kTopToolHeight, [UtilityFunc shareInstance].globleAllHeight, kTopToolHeight);
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            self.topTool.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleAllHeight, kTopToolHeight);
        }];
    }
}
//TODO:播放下一集
-(void)selectTVEpisodeWithIndex:(NSInteger)index{
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

@end

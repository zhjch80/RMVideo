//
//  CustomVideoPlayerView.h
//  LawtvApp
//
//  Created by Mac on 14-6-10.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "TouchVIew.h"

@class CustomVideoPlayerView;

@protocol playerViewDelegate <NSObject>
@optional

-(void)playerFinishedPlayback:(CustomVideoPlayerView*)view;

-(void)playViewTouchesEnded;

-(void)selectTVEpisodeWithIndex:(NSInteger)index;

@end

@interface CustomVideoPlayerView : UIView

@property (assign, nonatomic) id <playerViewDelegate> delegate;
@property (assign, nonatomic) BOOL isFullScreenMode;
@property (strong, nonatomic) NSURL *contentURL;
@property (strong, nonatomic) AVPlayer *moviePlayer;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (assign, nonatomic) BOOL isPlaying;

@property (strong, nonatomic) UIButton *playPauseButton; //播放/暂停按钮
@property (strong, nonatomic) UIButton *nextButton; //下一集

@property (strong, nonatomic) UISlider *progressBar; //影片播放进度
@property (strong, nonatomic) UIProgressView *videoProgress;

@property (strong, nonatomic) UILabel *playBackTime; //播放时间
@property (strong, nonatomic) UILabel *playBackTotalTime; //影片总时间

@property (strong,nonatomic) UIView *playerHudCenter;
@property (strong,nonatomic) UIView *playerHudBottom;
@property (strong,nonatomic) TouchVIew *touchView; //添有手势的视图，只要是实现滑动快进和快退的功能
@property (nonatomic, strong) AVPlayerItem *playerItem;

//显示未播放的电视剧
@property (strong,nonatomic) UIScrollView *TVSelectEpisodeScrollView;

- (id)initWithFrame:(CGRect)frame;
//设置相关影片的集数
- (void)setSelectionEpisodeScrollViewWithArray:(NSMutableArray *)tvArray;
- (void)play;
- (void)pause;
- (void)contentURL:(NSURL*)contentURL;
- (void)replaceCurrentItem;
//全屏
- (void)zoomButtonPressed;
//主视图点击导航返回的时候，需要需要通知该视图进行一些处理，譬如通知，和延时处理的函数
- (void)CustomViewWillDisappear;

-(void)playerFinishedPlaying;

//设置播放器播放制定时间
- (void)setAVPlayerWithTime:(int)time;

@end

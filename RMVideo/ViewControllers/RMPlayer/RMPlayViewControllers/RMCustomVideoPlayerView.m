//
//  RMCustomVideoPlayerView.m
//  RMCustomPlayer
//
//  Created by runmobile on 14-12-3.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMCustomVideoPlayerView.h"
#import "UtilityFunc.h"
#import "RMCustomVideoplayerViewController.h"

@interface RMCustomVideoPlayerView (){
    id playbackObserver;
}
@property (nonatomic, strong) RMCustomVideoplayerViewController * customVideoplayerCtl;

- (void)playerFinishedPlaying;
- (void)observeValueForKeyPath:(NSString*) path
                      ofObject:(id)object
                        change:(NSDictionary*)change
                       context:(void*)context;
@end

static void *CustomVideoPlayerViewStatusObservationContext = &CustomVideoPlayerViewStatusObservationContext;

@implementation RMCustomVideoPlayerView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.playerLayer setFrame:frame];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView * bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth)];
        bgImg.userInteractionEnabled = YES;
        bgImg.backgroundColor = [UIColor clearColor];
        bgImg.image = [UIImage imageNamed:@"rm_backgroud.jpg"];
        [self addSubview:bgImg];
    }
    return self;
}

- (void)contentURL:(NSURL *)contentURL {
    self.customVideoplayerCtl = self.RMCustomVideoplayerDeleagte;

    self.playerItem = [AVPlayerItem playerItemWithURL:contentURL];
    self.moviePlayer = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.moviePlayer];
    [self.playerLayer setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.moviePlayer seekToTime:kCMTimeZero];
    [self.layer addSublayer:self.playerLayer];
    self.contentURL = contentURL;
    
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];// 监听status属性
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFinishedPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

#pragma mark - 移除监听

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

#pragma mark -

/**
 *  释放播放资源
 */
- (void)replaceCurrentItem {
    [self pause];
    [self.moviePlayer replaceCurrentItemWithPlayerItem:nil];
}

/**
 *  开始播放
 */
-(void)play {
    [self.moviePlayer play];
    self.isPlaying = YES;
}

/**
 *  暂停播放
 */
-(void)pause {
    [self.moviePlayer pause];
    self.isPlaying = NO;
}

/**
 *  播放完成
 */
-(void)playerFinishedPlaying {
    [self replaceCurrentItem];
    [self.moviePlayer seekToTime:kCMTimeZero];
    self.isPlaying = NO;
    [self.customVideoplayerCtl playerFinishedPlay];
}

/**
 *  从特定时间开始播放
 */
- (void)setAVPlayerWithTime:(int)time{
    if (self.isPlaying) {
        [self.moviePlayer pause];
        [self.customVideoplayerCtl.playBtn setImage:[UIImage imageNamed:@"rm_pause_btn"] forState:UIControlStateNormal];
    }
    
    CMTime seekTime = CMTimeMakeWithSeconds(time, self.moviePlayer.currentTime.timescale);
    [self.moviePlayer seekToTime:seekTime];
    [self play];
    [self.customVideoplayerCtl.playBtn setImage:[UIImage imageNamed:@"rm_play_btn"] forState:UIControlStateNormal];
}

/**
 *  监听播放状态
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            NSLog(@"AVPlayerStatusReadyToPlay");
            [self.customVideoplayerCtl hideHUD];
            
//            CMTime duration = self.playerItem.duration;// 获取视频总长度
//            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
//            _totalTime = [self convertTime:totalSecond];// 转换成播放时间
//            [self customVideoSlider:duration];// 自定义UISlider外观
//            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
//            [self monitoringPlayback:self.playerItem];// 监听播放状态
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"playFail_KEY" object:nil];
            NSLog(@"AVPlayerStatusFailed");
            [self.customVideoplayerCtl hideHUD];
            [self.customVideoplayerCtl playerFinishedPlay];
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        [self.customVideoplayerCtl hideHUD];
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self customVideoSlider:duration];

        [self.customVideoplayerCtl.cacheProgress setProgress:timeInterval / totalDuration animated:YES];
    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.moviePlayer currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)customVideoSlider:(CMTime)duration {
//    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
//    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.customVideoplayerCtl.progressBar setMinimumTrackImage:[UIImage imageNamed:@"rm_leftTrack"] forState:UIControlStateNormal];
    [self.customVideoplayerCtl.progressBar setMaximumTrackImage:[UIImage imageNamed:@"rm_rightTrack"] forState:UIControlStateNormal];
}

//- (NSString *)convertTime:(CGFloat)second{
//    NSDate *d = [NSDate dateWithTimeIntervalSince1970:second];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    if (second/3600 >= 1) {
//        [formatter setDateFormat:@"HH:mm:ss"];
//    } else {
//        [formatter setDateFormat:@"mm:ss"];
//    }
//    NSString *showtimeNew = [formatter stringFromDate:d];
//    return showtimeNew;
//}

//- (void)monitoringPlayback:(AVPlayerItem *)playerItem {
//    self.playbackTimeObserver = [self.playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
//        CGFloat currentSecond = playerItem.currentTime.value/playerItem.currentTime.timescale;// 计算当前在第几秒
//        [self updateVideoSlider:currentSecond];
//        NSString *timeString = [self convertTime:currentSecond];
//        self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeString,_totalTime];
//    }];
//}



@end

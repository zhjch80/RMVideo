//
//  CustomVideoPlayerController.h
//  LawtvApp
//
//  Created by Mac on 14-6-10.
//  Copyright (c) 2014年 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    playNetWorVideo = 1,
    playLocalVideo
}PlayStyle;

typedef enum{
    videoTypeIsMovie = 1,
    videoTypeisTV,
    videotypeIsVariety
}VideoType;

@interface CustomVideoPlayerController : UIViewController
@property (nonatomic,copy) NSString *playURL;
@property (nonatomic,strong) NSMutableArray *videoArray;
@property (nonatomic)PlayStyle playStyle; //播放类型----本地还是网络
@property (nonatomic)VideoType videoType; //视频类型---电影，电视剧，综艺
@property (nonatomic,assign)NSInteger playEpisodeNumber;//当前播放的集数

- (void)createPlayerViewWithURL:(NSString *)url isPlayLocalVideo:(BOOL)isLocal;
- (void)createTopToolWithTitle:(NSString *)titel;

@end

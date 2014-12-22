//
//  RMPlayer.h
//  RMCustomPlayer
//
//  Created by runmobile on 14-12-5.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMModel.h"

@interface RMPlayer : NSObject

 /*
 NSString* pathExtention = [url pathExtension];
 if([pathExtention isEqualToString:@"mp4"]) {
 
 }else{
 
 }
 */


/**
 *  播放一部电影
 *  @param model        视频播放内容
 *  @param sender       当前控制器
 *  @param type         视频类型 (0:未知类型,1:电影,2:电视剧)
 */
+ (void)presentVideoPlayerWithPlayModel:(RMModel *)model
                 withUIViewController:(id)sender
                        withVideoType:(NSInteger)type;

/**
 *  播放一部电视剧,从第一集开始播放
 *  @param playArr      视频播放内容
 *  @param sender       当前控制器
 *  @param type         视频类型 (0:未知类型,1:电影,2:电视剧)
 */
+ (void)presentVideoPlayerWithPlayArr:(NSArray *)playArr
                 withUIViewController:(id)sender
                           withVideoType:(NSInteger)type;

/**
 *  播放一部电视剧,从某集开始播放
 *  @param current      当前要播放的某集
 *  @param playArr      视频播放内容
 *  @param sender       当前控制器
 *  @param type         视频类型 (0:未知类型,1:电影,2:电视剧)
 */
+ (void)presentVideoPlayerCurrentOrder:(NSInteger)current
                        withPlayArr:(NSArray *)playArr
                  withUIViewController:(id)sender
                         withVideoType:(NSInteger)type;
/**
 *  播放本地电影
 *  @param model 播放电影model
 *  @param viewController   需要加载播放器的视图控制器
 */
+ (void)presemtVideoPlayerWithLocationVieoModel:(RMModel *)model withUIViewController:(id)viewController;

/**
 *  播放本地电视剧视频
 *
 *  @param array          model array
 *  @param viewController 需要加载播放器的视图控制器
 */
+ (void)presemtVideoPlayerWithLocationTVArry:(NSMutableArray *)array withUIViewController:(id)viewController;

@end

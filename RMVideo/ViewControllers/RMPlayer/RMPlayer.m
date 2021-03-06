//
//  RMPlayer.m
//  RMCustomPlayer
//
//  Created by runmobile on 14-12-5.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMPlayer.h"
#import "RMCustomVideoplayerViewController.h"
#import "UtilityFunc.h"

@implementation RMPlayer

+ (RMCustomVideoplayerViewController *)initVideoPlay:(id)sender
                                      withIsLocation:(BOOL)isLocation {
    if (!isLocation){
        if ([UtilityFunc isConnectionAvailable] == 0){
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前无网络连接，请检查网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return nil;
        }
    }

    [self getUIScreenBounds];
    RMCustomVideoplayerViewController * customVideoplayerCtl = [[RMCustomVideoplayerViewController alloc] init];
    [sender presentViewController:customVideoplayerCtl animated:YES completion:^{
    }];
    return customVideoplayerCtl;
}

+ (void)presentVideoPlayerWithPlayModel:(RMModel *)model
                   withUIViewController:(id)sender
                          withVideoType:(NSInteger)type {
    RMCustomVideoplayerViewController * customVideoplayerCtl = [self initVideoPlay:sender withIsLocation:NO];
    customVideoplayerCtl.videlModel = model;
    customVideoplayerCtl.videoType = type;
    customVideoplayerCtl.isLocationVideo = NO;
}

+ (void)presentVideoPlayerWithPlayArray:(NSMutableArray *)playArr
                   withUIViewController:(id)sender
                          withVideoType:(NSInteger)type {
    RMCustomVideoplayerViewController * customVideoplayerCtl = [self initVideoPlay:sender withIsLocation:NO];
    customVideoplayerCtl.currentPlayOrder = 0;
    customVideoplayerCtl.playModelArr = playArr;
    customVideoplayerCtl.videoType = type;
    customVideoplayerCtl.isLocationVideo = NO;
}

+ (void)presentVideoPlayerCurrentOrder:(NSInteger)current
                         withPlayArray:(NSMutableArray *)playArr
                  withUIViewController:(id)sender
                         withVideoType:(NSInteger)type {
    RMCustomVideoplayerViewController * customVideoplayerCtl = [self initVideoPlay:sender withIsLocation:NO];
    customVideoplayerCtl.currentPlayOrder = current;
    customVideoplayerCtl.playModelArr = playArr;
    customVideoplayerCtl.videoType = type;
    customVideoplayerCtl.isLocationVideo = NO;
}

+ (void)presentVideoPlayerWithLocationVieoModel:(RMModel *)model
                           withUIViewController:(id)sender
                                 withIsLocation:(BOOL)isLocation {
    RMCustomVideoplayerViewController * customVideoplayerCtl = [self initVideoPlay:sender withIsLocation:isLocation];
    customVideoplayerCtl.videoType = MovieType;
    customVideoplayerCtl.videlModel = model;
    customVideoplayerCtl.isLocationVideo = isLocation;
}

+ (void)presentVideoPlayerWithLocationCurrentOrder:(NSInteger)current
                                     withPlayArray:(NSMutableArray *)array
                              withUIViewController:(id)sender
                                    withIsLocation:(BOOL)isLocation {
    RMCustomVideoplayerViewController * customVideoplayerCtl = [self initVideoPlay:sender withIsLocation:isLocation];
    customVideoplayerCtl.videoType = TeleplayType;
    customVideoplayerCtl.currentPlayOrder = current;
    customVideoplayerCtl.playModelArr = array;
    customVideoplayerCtl.isLocationVideo = isLocation;
}

+ (void)persentVideoPlayerWithFromAPointInTime:(int)time
                                 withPlayModel:(RMModel *)model
                          withUIViewController:(id)sender {
    RMCustomVideoplayerViewController * customVideoplayerCtl = [self initVideoPlay:sender withIsLocation:NO];
    customVideoplayerCtl.videoType = MovieType;
    customVideoplayerCtl.pointInTime = time;
    customVideoplayerCtl.videlModel = model;
    customVideoplayerCtl.isLocationVideo = NO;
    customVideoplayerCtl.isFromAPointInTime = YES;
}

+ (void)getUIScreenBounds{
    //屏幕宽 高
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [UtilityFunc shareInstance].globleWidth = screenRect.size.width;
    [UtilityFunc shareInstance].globleHeight = screenRect.size.height-20;
    [UtilityFunc shareInstance].globleAllHeight = screenRect.size.height;
}

/**
 *  获取当前显示的UIViewController
 */
+ (UIViewController *)getCurrentRootViewController {
    UIViewController *result;
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (topWindow.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows){
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [topWindow subviews].firstObject;
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isMemberOfClass:[UIViewController class]]){
        result = nextResponder;
    }else if([nextResponder isMemberOfClass:[UITabBarController class]] | [nextResponder isMemberOfClass:[UINavigationController class]]){
        result = [self findViewController:nextResponder];
    }else if([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil){
        result = topWindow.rootViewController;
    }else{
        NSAssert(NO, @"找不到顶端VC");
    }
    return result;
}

+ (UIViewController *)findViewController:(id)controller{
    if ([controller isMemberOfClass:[UINavigationController class]]) {
        return [self findViewController:[(UINavigationController *)controller visibleViewController]];
    }else if([controller isMemberOfClass:[UITabBarController class]]){
        return [self findViewController:[(UITabBarController *)controller selectedViewController]];
    }else if([controller isKindOfClass:[UIViewController class]]){
        return controller;
    }else{
        NSAssert(NO, @"找不到顶端VC");
        return nil;
    }
}

@end

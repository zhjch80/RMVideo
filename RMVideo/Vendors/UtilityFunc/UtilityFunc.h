//
//  UtilityFunc.h
//  RMVideo
//
//  Created by runmobile on 14-9-29.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum {
    UIDevice_iPhoneStandardRes      = 1,    // iPhone 1,3,3GS Standard Resolution   (320x960px)
    UIDevice_iPhoneHiRes            = 2,    // iPhone 4,4S High Resolution          (640x960px)
    UIDevice_iPhoneTallerHiRes      = 3,    // iPhone 5 High Resolution             (640x1136px)
    UIDevice_iPadStandardRes        = 4,    // iPad 1,2 Standard Resolution         (1024x768px)
    UIDevice_iPadHiRes              = 5     // iPad 3 High Resolution               (2048x1536px)
}; typedef NSUInteger UIDeviceResolution;

@interface UtilityFunc : NSObject{
    
}
@property (nonatomic, assign) float globleWidth;
@property (nonatomic, assign) float globleHeight;
@property (nonatomic, assign) float globleAllHeight;
@property (nonatomic, strong) NSDictionary * dic;
@property (nonatomic, assign) BOOL isAudio;

+ (UtilityFunc *)shareInstance;

// 是否4英寸屏幕
+ (BOOL)is4InchScreen;

//检查网络链接是否可用
+ (NSInteger)isConnectionAvailable;

//UIColor
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

+ (UIColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue;
+ (UIColor *)colorWith8BitRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(CGFloat)alpha;

+ (CGSize)boundingRectWithSize:(CGSize)size font:(UIFont*)font text:(NSString*)text;

+ (UIView *)rotatingView:(UIView *)view;                //View向左旋转90度


/**
 *
 *  返回缓存图片的本地路径
 *
 */
+ (NSString *)localImageCachesPath;

/**
 *
 * 计算该路径下文件大小 返回单位为M
 *
 */
+ (CGFloat)fileSizeAtPath:(NSString*)filePath;

/**
 *
 *  返回总共硬盘大小 返回单位是bt
 *
 */
+ (NSNumber *) totalDiskSpace;

/**
 *
 *  返回硬盘剩余大小 返回单位是bt
 *
 */
+ (NSNumber *) freeDiskSpace;

//+ (UIDeviceResolution)currentResolution;

@end

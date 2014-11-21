//
//  CONST.h
//  RMVideo
//
//  Created by runmobile on 14-9-28.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//


//系统框架
/*
 
 HUD 选项
 
 1.Reachability
 需要  SystemConfiguration框架
 
 2.UIImage-Helpers
 需要  Accelerate框架
 
 3.AFNetworking
 需要  MobileCoreServices框架 Security框架 SystemConfiguration框架 CoreLocation框架
 
 4.FMDB
 需要  libsqlite3框架
 
 5.EGOTableViewPullRefresh
 需要  QuartzCore框架
 
 6.HMSegmentedControl
 需要  QuartzCore框架
 
 7.UMeng需要的框架
 Security.framework,libiconv.dylib,SystemConfiguration.framework,CoreGraphics.framework，libsqlite3.dylib，CoreTelephony.framework,libstdc++.dylib,libz.dylib。
 8.Flurry 需要的框架
 Security.framework
 SystemConfiguration.framework
 
 
 
 svn://172.16.2.204/rmdom //文档
 svn://172.16.2.204/rmandroid //Android源码
 svn://172.16.2.204/rmios  //ios源码
 svn://172.16.2.204/rmweb  //api，pc，后台源码
 
 账号目前都是自己姓名全称 如：刘涛 密码 为rm+名字首字母+123 如：rmlt123
 
 */
#import "CONSTURL.h"

#define kHideTabbar                             @"hideTabBar"
#define kAppearTabbar                           @"appearTabBar"
#define kYES                                    @"YES"
#define kNO                                     @"NO"

#define kOpenOrCloseDefaultLeftMenu             @"openOrCloseDefaultLeftMenu"
#define kOpenOrCloseDefaultRightMenu            @"openOrCloseDefaultRightMenu"
#define kCloseMenu                              @"closeMenu"
#define kOpenMenu                               @"openMenu"

//已下载 cell开始编辑
#define kFinishViewControStartEditing           @"finishcellbeginAnimation"
//已下载 cell结束编辑
#define kFinishViewControEndEditing             @"finishcellendAnimation"
//下载中 cell开始编辑
#define kDownLoadingControStartEditing          @"downLoadingCellBeginAimation"
//下载中 cell结束编辑
#define kDownLoadingControEndEditing            @"downLoadingCellEndAimation"
//电视剧下载详情删除结束
#define kTVSeriesDetailDeleteFinish             @"TVSeriesDetailDeleteFinish"

#define IS_IPHONE_4_SCREEN ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_IPHONE_5_SCREEN ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_IPHONE_6_SCREEN ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define IS_IPHONE_6p_SCREEN ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO) //1242, 2208   1080, 1920


#define LANTING_FONT(_size) [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:(_size)]
#define IS_IOS7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0

#define kImageTypePNG @"png"
#define LOADIMAGE(file,ext)   [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

#define APPID_VALUE             @"54228f50"
#define URL_VALUE               @""                 // url
#define TIMEOUT_VALUE           @"20000"            // timeout      连接超时的时间，以ms为单位

//Storage
#define CURRENTENCRYPTFILE                          @"PersonalInformationFile"
#define PASSWORD                                    @"password"

#define LoginStatus_KEY                             @"loginstatus_KEY"
#define UserLoginInformation_KEY                    @"userLoginInformation_KEY"
#define UserSearchRecordData_KEY                    @"userSearchRecordData_KEY"
#define UserSearchStarRecordData_KEY                @"userSearchSatrRecordData_KEY"
#define DownLoadDataArray_KEY                       @"downLoadDataArray_KEY"
#define Downloadstatus_KEY                          @"downloadstatus"
#define DownLoadSuccess_KEY                         @"downLoadSuccess_KEY"

/*
 loginStatus  value为:islogin  表示登录    value为:notlogin  表示未登录
*/

#define kShowConnectionAvailableError               @"没有网络，请检查网络连接"



//APP 相关信息
#define kAppName                            @"小花儿视频"
#define kAppleId                            @"944155902"
#define kAppAddress                         @"https://itunes.apple.com/cn/app/r-evolve/id944155902?mt=8"

#define AboutAppUrl                 @"http://xiubo.runmobile.cn/about/index.php?versionNumber=%@&os=iPhone1.1.0"



//https://itunes.apple.com/cn/app/r-evolve/id877939351?mt=8

//http://xiubo.runmobile.cn/about/index.php?versionNumber=%@&os=iPhone1.1.0




#if __has_feature(objc_arc)
// ARC
#else
// MRC
#endif



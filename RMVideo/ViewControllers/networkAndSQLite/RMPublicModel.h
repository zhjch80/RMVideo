//
//  RMPublicModel.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-30.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMPublicModel : NSObject

@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *DailyRecommendPic;
@property (nonatomic, strong) NSString *DailyRecommendVideo_id;
@property (nonatomic, strong) NSString *DailyRecommendVideo_type;
@property (nonatomic, strong) NSString *DailyRecommendDescription;
@property (nonatomic, strong) NSString *video_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *pic;
@property (nonatomic, strong) NSString *sum_i_hits;
@property (nonatomic, strong) NSString *video_type;
@property (nonatomic, strong) NSString *topNum;
@property (nonatomic, strong) NSString * tag_list;
@property (nonatomic, strong) NSString * tag_id;
@property (nonatomic, strong) NSString * gold;
@property (nonatomic, strong) NSMutableArray * video_list;
@property (nonatomic, strong) NSString * detail;
@property (nonatomic, strong) NSString * pic_url;
@property (nonatomic, strong) NSMutableArray * playurlArr;      //电影
@property (nonatomic, strong) NSMutableArray * playurlsArr;     //电视剧，综艺
@property (nonatomic, strong) NSMutableArray * creatorArr;
@property (nonatomic, strong) NSString * hits;
@property (nonatomic, strong) NSString * jumpurl;           //web
@property (nonatomic, strong) NSString * reurl;             //mp4地址
@property (nonatomic, strong) NSString * source_type;
@property (nonatomic, strong) NSString * content;
@property (nonatomic, strong) NSString * android;
@property (nonatomic, strong) NSString * appName;
@property (nonatomic, strong) NSString * appPic;
@property (nonatomic, strong) NSString * ios;
@property (nonatomic, strong) NSString * is_follow;
@property (nonatomic, strong) NSString * is_favorite;
@property (nonatomic, strong) NSString * keyword;
@property (nonatomic, strong) NSMutableArray * list;
@property (nonatomic, strong) NSString *playTime;       //表示播放的时间，方便下次进来可以继续播放，用在数据库中
@property (nonatomic)BOOL isTVModel;




@property (nonatomic, copy) NSString *downLoadURL; //下载链接
@property (nonatomic, copy) NSString *downLoadState; //当前下载状态（等待下载，暂停）
@property (nonatomic ,copy) NSString *cacheProgress; //缓存进度，用在下载过程中
@property (nonatomic ,copy) NSString *totalMemory;
@property (nonatomic, copy) NSString *alreadyCasheMemory;

@end

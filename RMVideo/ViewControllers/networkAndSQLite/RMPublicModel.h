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
@property (nonatomic, strong) NSMutableArray * playurlArr;
@property (nonatomic, strong) NSMutableArray * creatorArr;
@property (nonatomic, strong) NSString * hits;
@property (nonatomic, strong) NSString * jumpurl;
@property (nonatomic, strong) NSString * reurl;
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
@end

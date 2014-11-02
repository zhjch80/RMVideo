//
//  RMPublicModel.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-30.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMPublicModel : NSObject

@property (nonatomic,strong) NSString *code;

//今日推荐
@property(nonatomic,strong) NSString *DailyRecommendPic;
@property(nonatomic,strong) NSString *DailyRecommendVideo_id;
@property(nonatomic,strong) NSString *DailyRecommendVideo_type;
@property(nonatomic,strong) NSString *DailyRecommendDescription;

//日榜
@property(nonatomic,strong) NSString *video_id;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *pic;
@property(nonatomic,strong) NSString *sum_i_hits; //点击增长数
@property(nonatomic,strong) NSString *video_type; //类型（1：电影 2：电视剧 3：综艺 99：广告）


//我的频道
@property (nonatomic, strong) NSString * tag_list;
@property (nonatomic, strong) NSString * tag_id;
//@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * gold;
//@property (nonatomic, strong) NSString * pic;
//@property (nonatomic, strong) NSString * video_id;
//@property (nonatomic, strong) NSString * video_type;
@property (nonatomic, strong) NSMutableArray * video_list;


//明星
@property (nonatomic, strong) NSString * detail;
//@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * pic_url;
//@property (nonatomic, strong) NSString * tag_id;


//视频详情
@property (nonatomic, strong) NSMutableArray * playurlArr;
@property (nonatomic, strong) NSMutableArray * creatorArr;
@property (nonatomic, strong) NSString * hits;
@property (nonatomic, strong) NSString * jumpurl;
@property (nonatomic, strong) NSString * reurl;
@property (nonatomic, strong) NSString * source_type;
//@property (nonatomic, strong) NSString * source_type_ids;
@property (nonatomic, strong) NSString * content;



@end

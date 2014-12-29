//
//  RMAFNRequestManager.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-29.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    requestReturnStatusNormalType = 4001,                           //正常
    requestReturnStatusNoVideosFoundType,                           //没有找到该视频
    requestReturnStatusUserIdentityExpiredType,                     //未找到该用户，请重新登录
    requestReturnStatusSystemErrorType,                             //系统错误，稍后再试
    requestReturnStatusNoStarFoundType,                             //没有找到该明星
    requestReturnStatusHasBeenAddedToMyChannelType,                 //明星已经添加到我的频道
    requestReturnStatusInputDoesNotMeetSpecificationsType,          //输入不符合规范
    requestReturnStatusDataEnteredIsIncompleteType,                 //输入的数据不完整
    requestReturnStatusContentsOfTheInputCanNotBeEmptyType,         //输入的内容不能为空
    requestReturnStatusUnKnownDevice = 4011                         //未知设备
}kCodeReturnStatusType;

@protocol RMAFNRequestManagerDelegate <NSObject>

@optional
- (void)requestFinishiDownLoadWith:(NSMutableArray *)data;

- (void)requestError:(NSError *)error;

@end

@interface RMAFNRequestManager : NSObject

@property(assign,nonatomic)id<RMAFNRequestManagerDelegate> delegate;
/**
 *  今日推荐下载
 *
 *  @param type      视屏类型 电影，电视剧，综艺
 *  @param PageNumber 页数
 *  @param count     条数
 */
- (void)getDailyRecommend;
/**
 *  榜单
 *
 *  @param videoType 视频类型（1：电影 2：电视剧 3：综艺）
 *  @param topType   排行类型（1：日榜 2：周榜 3：月榜）
 *  @param PageNumber 页数
 *  @param count     条数
 */
- (void)getTopListWithVideoTpye:(NSString *)videoType andTopType:(NSString *)topType searchPageNumber:(NSString *)page andCount:(NSString *)count;
/**
 *  视频详情
 *
 *  @param id    视频ID
 *  @param token 用户令牌（可选，若未登录则不传）
 */
- (void)getVideoDetailWithID:(NSString *)ID andToken:(NSString *)token;

/**
 *  选择要下载的分集
 *
 *  @param ID    视频ID
 */
- (void)getDownloadDiversityWithID:(NSString *)ID;

/**
 *  电影详情：添加收藏
 *
 *  @param ID    视频ID
 *  @param token 用户令牌
 */
- (void)getAddFavoriteWithID:(NSString *)ID andToken:(NSString *)token;

/**
 *  我的频道
 *
 *  @param token     用户令牌
 *  @param page      页码
 *  @param count     条数
 *  @param cellPage  cell上显示的页码  nil
 *  @param cellCount cell上显示的条数  nil
 */
- (void)getMyChannelVideoListWithToken:(NSString *)token pageNumber:(NSString *)page count:(NSString *)count;

/**
 *  我的频道：更多精彩
 *
 *  @param page  页码
 *  @param count 条数
 */
- (void)getMoreWonderfulVideoListWithPage:(NSString *)page count:(NSString *)count;

/**
 *  我的频道：换一批
 *
 *  @param page  页码
 *  @param count 条数
 */
- (void)getReplaceChannelWithPage:(NSString *)page count:(NSString *)count;

/**
 *  我的频道：自定义tag
 *
 *  @param token 用户令牌
 *  @param name   用户自定义tag名称
 */
- (void)getCustomTagWithToken:(NSString *)token tagName:(NSString *)name;

/**
 *  我的频道：单个tag下的影片列表
 *
 *  @param ID   tag的id
 *  @param type 视频类型（1：电影 2：电视剧 3：综艺）
 */
- (void)getTagOfVideoListWithID:(NSString *)ID andVideoType:(NSString *)type WithPage:(NSString *)page count:(NSString *)count;

/**
 *  明星：明星列表
 *
 *  @param page  页码
 *  @param count 条数
 *  @param token 用户标示
 */
- (void)getStarListWithPage:(NSString *)page count:(NSString *)count WithToken:(NSString *)token;

/**
 *  明星：明星详情
 *
 *  @param ID 明星id
 */
- (void)getStartDetailWithID:(NSString *)ID WithToken:(NSString *)token;
/**
 *  明星：加入我的频道
 *
 *  @param token 用户令牌
 *  @param ID    明星的id
 */
- (void)getJoinMyChannelWithToken:(NSString *)token andID:(NSString *)ID;
/**
 *  设置：我收藏的视频列表
 *
 *  @param token 用户令牌
 *  @param page  页码
 *  @param count 条数
 */
- (void)getFavoriteVideoListWithToken:(NSString *)token Page:(NSString *)page count:(NSString *)count;

/**
 *  设置：我收藏的：取消收藏
 *
 *  @param token 用户令牌
 *  @param ID    视频ids(多个id以英文逗号隔开)
 */
- (void)getDeleteFavoriteVideoWithToken:(NSString *)token videoID:(NSString *)ID;

/**
 *  设置：用户反馈
 *
 *  @param token  用户令牌(可选，如果未登陆则不传此参数)
 *  @param string 内容
 */
- (void)postUserFeedbackWithToken:(NSString *)token andFeedBackString:(NSString *)string;

/**
 *  联想动态搜索
 */
- (void)getDynamicAssociativeSearchWithKeyWord:(NSString *)string;

/**
 *  搜索
 *
 *  @param string 输入的关键字
 *  @param Page   页码
 *  @param count  条数
 *
 */
- (void)getSearchVideoWithKeyword:(NSString *)string Page:(NSString *)page count:(NSString *)count;

/**
 *  登录
 *
 *  @param type 用户来源（2：腾讯微博 3：腾讯QQ 4:新浪微博 99：其他）
 *  @param ID   用户id
 *  @param name 用户名
 *  @param url  用户头像
 */
- (void)postLoginWithSourceType:(NSString *)type sourceId:(NSString *)ID username:(NSString *)name headImageURL:(NSString *)imageUrl;

/**
 *  更多应用推广
 *
 */
- (void)getMoreAppSpread;

/**
 *  我的频道  删除标签
 *  @param tag      标签tag_id
 *  @param token    token
 */
- (void)getDeleteMyChannelWithTag:(NSString *)tag WithToken:(NSString *)token;

/**
 * 行为统计 统计影片的播放次数
 * @param video_id      影片的video_id
 * @param device        设备 （iPhone android）
 */
- (void)getDeviceHitsWithVideo_id:(NSString *)video_id WithDevice:(NSString *)device;

/**
 * 关于
 */
- (void)getAboutAppWithOS:(NSString *)os withVersionNumber:(NSString *)versionNumber;

/**
 *  判断明星标签下 电影 电视剧 综艺 是否有数据
 */
- (void)getCheckStarPropertyWithStar_id:(NSString *)star_id;

/**
 *  搜索 推荐标签
 */
- (void)getSearchRecommend;

@end

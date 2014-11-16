//
//  RMAFNRequestManager.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-29.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMAFNRequestManager.h"
#import "CONSTURL.h"
#import "AFNetworking.h"
#import "RMPublicModel.h"
#import "SVProgressHUD.h"

#if 0
//雪峰
#define baseUrl @"http://172.16.2.66/index.php/vod/"
#else
//测试服务器
#define baseUrl @"http://172.16.2.204/rmapi/index.php/vod/"
//线上
//#define baseUrl     @"172.16.2.213/rmapi/index.php/vod/"

#endif



@implementation RMAFNRequestManager

- (AFHTTPRequestOperationManager *)creatAFNNetworkRequestManager{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;//超时
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
    return manager;
}

- (NSString *)urlPathadress:(NSInteger)tag{
    NSString *strUrl;
    switch (tag) {
        case Http_getDailyRecommend:{
            strUrl = [NSString stringWithFormat:@"%@getDailyRecommend",baseUrl];
            break;
        }
        case Http_getTopList:{
            strUrl = [NSString stringWithFormat:@"%@getTopList?",baseUrl];
            break;
        }
        case Http_getVideoDetail:{
             strUrl = [NSString stringWithFormat:@"%@getVideoDetailById?",baseUrl];
            break;
        }case Http_getDownloadDiversity:{
            strUrl = [NSString stringWithFormat:@"%@getDownloadUrlById?",baseUrl];
            break;
        }case Http_getAddFavorite:{
            strUrl = [NSString stringWithFormat:@"%@addFavorite?",baseUrl];
            break;
        }
        case Http_getMyChannelVideoList:{
            strUrl = [NSString stringWithFormat:@"%@getTagAndVideoListByToken?",baseUrl];
            break;
        }
        case Http_getMoreWonderfulVideoList:{
            strUrl = [NSString stringWithFormat:@"%@getTagList?",baseUrl];
            break;
        }
        case Http_getReplaceChannel:{
            strUrl = [NSString stringWithFormat:@"%@getRandTagList?",baseUrl];
            break;
        }
        case Http_getCustomTag:{
            strUrl = [NSString stringWithFormat:@"%@setTag?",baseUrl];
            break;
        }
        case Http_getTagOfVideoList:{
            strUrl = [NSString stringWithFormat:@"%@getVideoListByTagId?",baseUrl];
            break;
        }
        case Http_getStarList:{
            strUrl = [NSString stringWithFormat:@"%@getStarList?",baseUrl];
            break;
        }
        case Http_getStartSearch:{
            strUrl = [NSString stringWithFormat:@"%@searchStarByName?",baseUrl];
            break;
        }
        case Http_getStartDetail:{
            strUrl = [NSString stringWithFormat:@"%@getStarDetailById?",baseUrl];
            break;
        }
        case Http_getJoinMyChannel:{
            strUrl = [NSString stringWithFormat:@"%@addStarToTag?",baseUrl];
            break;
        }
        case Http_getFavoriteVideoList:{
            strUrl = [NSString stringWithFormat:@"%@getFavoriteVideoList?",baseUrl];
            break;
        }
        case Http_getDeleteFavoriteVideo:{
            strUrl = [NSString stringWithFormat:@"%@deleteFavoriteVideo?",baseUrl];
            break;
        }
        case Http_postUserFeedback:{
            strUrl = [NSString stringWithFormat:@"%@userFeedback?",baseUrl];
            break;
        }
        case Http_getSearchVidieo:{
            strUrl = [NSString stringWithFormat:@"%@searchByVideoName?",baseUrl];
            break;
        }
        case Http_postLogin:{
            strUrl = [NSString stringWithFormat:@"%@login?",baseUrl];
            break;
        }
        case Http_getMoreAppSpread:{
            strUrl = [NSString stringWithFormat:@"%@getMoreApp",baseUrl];
            break;
        }
        case Http_getDeleteMyChannelTag:{
            strUrl = [NSString stringWithFormat:@"%@delMyTag?",baseUrl];
            break;
        }
            
        default:{
            strUrl = nil;
        }
            break;
    }
    return strUrl;
}

- (NSString *)setOffsetWith:(NSString *)page andCount:(NSString *)count{
    return [NSString stringWithFormat:@"%d",([page intValue] -1)*[count intValue]];
}

#pragma mark - 今日推荐

- (void)getDailyRecommend{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getDailyRecommend];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] intValue] == 4001){
            NSMutableArray *dataArray = [NSMutableArray array];
            NSMutableArray *tvArray = [NSMutableArray array];
            for(NSDictionary *dict in [responseObject objectForKey:@"list_tv"]){
                RMPublicModel *model = [[RMPublicModel alloc] init];
                model.DailyRecommendPic = [dict objectForKey:@"pic"];
                model.DailyRecommendDescription = [dict objectForKey:@"description"];
                model.DailyRecommendVideo_id = [dict objectForKey:@"video_id"];
                model.DailyRecommendVideo_type = [dict objectForKey:@"video_type"];
                [tvArray addObject:model];
            }
            NSMutableDictionary *tv = [[NSMutableDictionary alloc] init];
            [tv setObject:tvArray forKey:@"电视剧"];
            NSMutableArray *movieArray = [NSMutableArray array];
            for(NSDictionary *dict in [responseObject objectForKey:@"list_vod"]){
                RMPublicModel *model = [[RMPublicModel alloc] init];
                model.DailyRecommendPic = [dict objectForKey:@"pic"];
                model.DailyRecommendDescription = [dict objectForKey:@"description"];
                model.DailyRecommendVideo_id = [dict objectForKey:@"video_id"];
                model.DailyRecommendVideo_type = [dict objectForKey:@"video_type"];
                [movieArray addObject:model];
            }
            NSMutableDictionary *movie = [[NSMutableDictionary alloc] init];
            [movie setObject:movieArray forKey:@"电影"];
            
            NSMutableArray *varietyArray = [NSMutableArray array];
            for(NSDictionary *dict in [responseObject objectForKey:@"list_variety"]){
                RMPublicModel *model = [[RMPublicModel alloc] init];
                model.DailyRecommendPic = [dict objectForKey:@"pic"];
                model.DailyRecommendDescription = [dict objectForKey:@"description"];
                model.DailyRecommendVideo_id = [dict objectForKey:@"video_id"];
                model.DailyRecommendVideo_type = [dict objectForKey:@"video_type"];
                [varietyArray addObject:model];
            }
            NSMutableDictionary *variety = [[NSMutableDictionary alloc] init];
            [variety setObject:varietyArray forKey:@"综艺"];
            
            [dataArray addObject:movie];
            [dataArray addObject:tv];
            [dataArray addObject:variety];
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:dataArray];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
        
    }];
}

#pragma mark - 日榜

- (void)getTopListWithVideoTpye:(NSString *)videoType andTopType:(NSString *)topType searchPageNumber:(NSString *)page andCount:(NSString *)count{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getTopList];
    url = [NSString stringWithFormat:@"%@video_type=%@&top_type=%@&limit=%@&offset=%@",url,videoType,topType,count,[self setOffsetWith:page andCount:count]];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] intValue] == 4001){
            NSMutableArray *dataArray = [NSMutableArray array];
            for(NSDictionary *dict in [responseObject objectForKey:@"list"]){
                RMPublicModel *model = [[RMPublicModel alloc] init];
                model.pic = [dict objectForKey:@"pic"];
                model.name = [dict objectForKey:@"name"];
                model.video_id = [dict objectForKey:@"video_id"];
                model.video_type = [dict objectForKey:@"video_type"];
                model.sum_i_hits = [dict objectForKey:@"sum_i_hits"];
                model.topNum = [dict objectForKey:@"order"];
                [dataArray addObject:model];
            }
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:dataArray];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 视频详情

- (void)getVideoDetailWithID:(NSString *)ID andToken:(NSString *)token{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getVideoDetail];
    url = [NSString stringWithFormat:@"%@video_id=%@&token=%@",url,ID,token];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *dataArray = [NSMutableArray array];
        RMPublicModel *model = [[RMPublicModel alloc] init];
        model.code = [responseObject objectForKey:@"code"];
        model.content = [responseObject objectForKey:@"content"];
        model.is_favorite = [responseObject objectForKey:@"is_favorite"];
        model.creatorArr = [responseObject objectForKey:@"creator"];
        model.gold = [responseObject objectForKey:@"gold"];
        model.hits = [responseObject objectForKey:@"hits"];
        model.name = [responseObject objectForKey:@"name"];
        model.pic = [responseObject objectForKey:@"pic"];
        model.playurlArr = [responseObject objectForKey:@"playurl"];/*jumpurl m_down_url source_type */
        model.playurlsArr = [responseObject objectForKey:@"playurls"];/*id(没用) source_type urls(arr)｛jumpurl m_down_url curnum｝ */
        model.video_id = [responseObject objectForKey:@"video_id"];
        model.video_type = [responseObject objectForKey:@"video_type"];
        [dataArray addObject:model];
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 选择要下载的分集

- (void)getDownloadDiversityWithID:(NSString *)ID{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getDownloadDiversity];
    url = [NSString stringWithFormat:@"%@video_id=%@",url,ID];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] intValue] == 4001){
            NSMutableArray *dataArray = [NSMutableArray array];
            for(NSDictionary *dict in [responseObject objectForKey:@"list"]){
                RMPublicModel *model = [[RMPublicModel alloc] init];
                model.topNum = [NSString stringWithFormat:@"%@",[dict objectForKey:@"curnum"]];
                model.downLoadURL = [dict objectForKey:@"down_url"];
                [dataArray addObject:model];
            }
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:dataArray];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 电影详情：添加收藏

- (void)getAddFavoriteWithID:(NSString *)ID andToken:(NSString *)token{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getAddFavorite];
    url = [NSString stringWithFormat:@"%@token=%@&video_id=%@",url,token,ID];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"code"] integerValue] == 4001){
            [SVProgressHUD showSuccessWithStatus:@"收藏成功"];
        }else {
            [SVProgressHUD showErrorWithStatus:@"收藏失败"];
        }
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(requestError:)]) {
            [SVProgressHUD showErrorWithStatus:@"收藏失败"];
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 我的频道

- (void)getMyChannelVideoListWithToken:(NSString *)token pageNumber:(NSString *)page count:(NSString *)count {
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getMyChannelVideoList];
    url = [NSString stringWithFormat:@"%@token=%@&limit_tag=%@&offset_tag=%@",url,token,count,[self setOffsetWith:page andCount:count]];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *dataArray = [NSMutableArray array];
        for(NSDictionary *dict in [responseObject objectForKey:@"tag_list"]){
            RMPublicModel *model = [[RMPublicModel alloc] init];
            model.tag_id = [dict objectForKey:@"tag_id"];
            model.name = [dict objectForKey:@"name"];
            model.video_list = [dict objectForKey:@"video_list"];
            model.rows = [responseObject objectForKey:@"rows"];
            [dataArray addObject:model];
        }
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 我的频道：更多精彩

- (void)getMoreWonderfulVideoListWithPage:(NSString *)page count:(NSString *)count{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getMoreWonderfulVideoList];
    url = [NSString stringWithFormat:@"%@limit=%@&offset=%@",url,count,[self setOffsetWith:page andCount:count]];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *dataArray = [NSMutableArray array];
        for(NSDictionary *dict in [responseObject objectForKey:@"list"]){
            RMPublicModel *model = [[RMPublicModel alloc] init];
            model.tag_id = [dict objectForKey:@"tag_id"];
            model.name = [dict objectForKey:@"name"];
            model.rows = [responseObject objectForKey:@"rows"];
            [dataArray addObject:model];
        }
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 我的频道：换一批

- (void)getReplaceChannelWithPage:(NSString *)page count:(NSString *)count{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getReplaceChannel];
    url = [NSString stringWithFormat:@"%@limit=%@&offset=%@",url,count,[self setOffsetWith:page andCount:count]];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *dataArray = [NSMutableArray array];
        for(NSDictionary *dict in [responseObject objectForKey:@"list"]){
            RMPublicModel *model = [[RMPublicModel alloc] init];
            model.tag_id = [dict objectForKey:@"tag_id"];
            model.name = [dict objectForKey:@"name"];
            model.rows = [responseObject objectForKey:@"rows"];
            [dataArray addObject:model];
        }
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 我的频道：自定义tag

- (void)getCustomTagWithToken:(NSString *)token tagName:(NSString *)name{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getCustomTag];
    url = [NSString stringWithFormat:@"%@token=%@&tag=%@",url,token,[name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *dataArray = [NSMutableArray array];
        RMPublicModel *model = [[RMPublicModel alloc] init];
        model.code = [responseObject objectForKey:@"code"];
        [dataArray addObject:model];
        if ([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]) {
            [self.delegate requestFinishiDownLoadWith:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 我的频道：单个tag下的影片列表

- (void)getTagOfVideoListWithID:(NSString *)ID andVideoType:(NSString *)type WithPage:(NSString *)page count:(NSString *)count{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getTagOfVideoList];
    url = [NSString stringWithFormat:@"%@tag_id=%@&video_type=%@&limit=%@&offset=%@",url,ID,type,count,page];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([[responseObject objectForKey:@"code"] intValue]==4001){
            NSMutableArray *array = [NSMutableArray array];
            for(NSDictionary *dict in [responseObject objectForKey:@"list"]){
                RMPublicModel *model = [[RMPublicModel alloc] init];
                model.pic = [dict objectForKey:@"pic"];
                model.name = [dict objectForKey:@"name"];
                model.gold = [dict objectForKey:@"gold"];
                model.video_type = [dict objectForKey:@"video_type"];
                model.video_id = [dict objectForKey:@"video_id"];
                model.rows = [responseObject objectForKey:@"rows"];
                [array addObject:model];
            }
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:array];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:@"提交失败"];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
        [SVProgressHUD showErrorWithStatus:@"下载失败"];
    }];
}

#pragma mark - 明星列表

- (void)getStarListWithPage:(NSString *)page count:(NSString *)count WithToken:(NSString *)token{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getStarList];
    url = [NSString stringWithFormat:@"%@limit=%@&offset=%@&token=%@",url,count,[self setOffsetWith:page andCount:count],token];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *dataArray = [NSMutableArray array];
        for(NSDictionary *dict in [responseObject objectForKey:@"list"]){
            RMPublicModel *model = [[RMPublicModel alloc] init];
            model.tag_id = [dict objectForKey:@"tag_id"];
            model.is_follow = [dict objectForKey:@"is_follow"];
            model.detail = [dict objectForKey:@"detail"];
            model.name = [dict objectForKey:@"name"];
            model.pic_url = [dict objectForKey:@"pic_url"];
            model.rows = [responseObject objectForKey:@"rows"];
            [dataArray addObject:model];
        }
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 明星：明星搜索

- (void)getSearchStartWithName:(NSString *)name page:(NSString *)page count:(NSString *)count{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getStartSearch];
    url = [NSString stringWithFormat:@"%@name=%@&limit=%@&offset=%@",url,name,count,[self setOffsetWith:page andCount:count]];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *dataArray = [NSMutableArray array];
        RMPublicModel *model = [[RMPublicModel alloc] init];
        model.code = [responseObject objectForKey:@"code"];
        model.name = [responseObject objectForKey:@"name"];
        model.list = [responseObject objectForKey:@"list"];
        model.rows = [responseObject objectForKey:@"rows"];
        [dataArray addObject:model];
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 明星：明星详情

- (void)getStartDetailWithID:(NSString *)ID WithToken:(NSString *)token {
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getStartDetail];
    url = [NSString stringWithFormat:@"%@id=%@&token=%@",url,ID,token];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray * dataArray = [NSMutableArray array];
        RMPublicModel *model = [[RMPublicModel alloc] init];
        model.tag_id = [responseObject objectForKey:@"tag_id"];
        model.detail = [responseObject objectForKey:@"detail"];
        model.name = [responseObject objectForKey:@"name"];
        model.pic_url = [responseObject objectForKey:@"pic_url"];
        model.is_follow = [responseObject objectForKey:@"is_follow"];
        [dataArray addObject:model];
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 明星：加入我的频道   或者  主创人员 明星添加

- (void)getJoinMyChannelWithToken:(NSString *)token andID:(NSString *)ID{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getJoinMyChannel];
    url = [NSString stringWithFormat:@"%@token=%@&id=%@",url,token,ID];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([[responseObject objectForKey:@"code"] intValue] == 4001){
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                [self.delegate requestFinishiDownLoadWith:nil];
            }
        }else if([[responseObject objectForKey:@"code"] integerValue] == 4006) {
            [SVProgressHUD showSuccessWithStatus:@"已经在我的频道"];
        }else{
            [SVProgressHUD showErrorWithStatus:@"添加失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
        [SVProgressHUD showErrorWithStatus:@"添加失败"];
    }];
}

#pragma mark - 设置：我的收藏视频列表

- (void)getFavoriteVideoListWithToken:(NSString *)token Page:(NSString *)page count:(NSString *)count{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getFavoriteVideoList];
    url = [NSString stringWithFormat:@"%@token=%@&limit=%@&offset=%@",url,token,count,[self setOffsetWith:page andCount:count]];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] integerValue] == 4001){
            NSMutableArray *array = [NSMutableArray array];
            for(NSDictionary *dict in [responseObject objectForKey:@"list"]){
                RMPublicModel *model = [[RMPublicModel alloc] init];
                model.pic = [dict objectForKey:@"pic"];
                model.name = [dict objectForKey:@"name"];
                model.video_id =[dict objectForKey:@"video_id"];
                model.video_type = [dict objectForKey:@"video_type"];
                model.rows = [responseObject objectForKey:@"rows"];
                [array addObject:model];
            }
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:array];
            }
        }
        else{
            [SVProgressHUD showErrorWithStatus:@"下载失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
        [SVProgressHUD showErrorWithStatus:@"下载失败"];
    }];
}

#pragma mark - 设置：我的收藏：取消收藏

- (void)getDeleteFavoriteVideoWithToken:(NSString *)token videoID:(NSString *)ID{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getDeleteFavoriteVideo];
    url = [NSString stringWithFormat:@"%@token=%@&video_ids=%@",url,token,ID];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] intValue] == 4001){
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [SVProgressHUD showSuccessWithStatus:@"取消收藏成功"];
                [self.delegate requestFinishiDownLoadWith:nil];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:@"取消收藏失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
        [SVProgressHUD showErrorWithStatus:@"取消收藏失败"];
    }];
}

#pragma mark - 设置：用户反馈

- (void)postUserFeedbackWithToken:(NSString *)token andFeedBackString:(NSString *)string{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_postUserFeedback];
    url = [NSString stringWithFormat:@"%@token=%@&text=%@",url,token,string];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] intValue]==4001){
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:nil];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:@"提交失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
        [SVProgressHUD showErrorWithStatus:@"提交失败"];
    }];
}

#pragma mark - 搜索

- (void)getSearchVideoWithKeyword:(NSString *)string Page:(NSString *)page count:(NSString *)count{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getSearchVidieo];
    url = [NSString stringWithFormat:@"%@keyword=%@&limit=%@&offset=%@",url,string,count,[self setOffsetWith:page andCount:count]];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *dataArray = [NSMutableArray array];
        RMPublicModel *model = [[RMPublicModel alloc] init];
        model.code = [responseObject objectForKey:@"code"];
        model.keyword = [responseObject objectForKey:@"keyword"];
        model.list = [responseObject objectForKey:@"list"];
        model.rows = [responseObject objectForKey:@"rows"];
        [dataArray addObject:model];
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 登录

- (void)postLoginWithSourceType:(NSString *)type sourceId:(NSString *)ID username:(NSString *)name headImageURL:(NSString *)imageUrl{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_postLogin];
    url = [NSString stringWithFormat:@"%@source_type=%@&source_id=%@&username=%@&face=%@",url,type,ID,name,imageUrl];
    [manager POST:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] intValue] == 4001){
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:[NSMutableArray arrayWithObjects:[ responseObject objectForKey:@"token"], nil]];
            }
        }
        else{
            [SVProgressHUD showErrorWithStatus:@"登录失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
        [SVProgressHUD showErrorWithStatus:@"登录失败"];
    }];
}

#pragma mark - 设置：更多应用

- (void)getMoreAppSpread {
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getMoreAppSpread];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        NSMutableArray *dataArray = [NSMutableArray array];
        for(NSDictionary *dict in [responseObject objectForKey:@"list"]){
            RMPublicModel *model = [[RMPublicModel alloc] init];
            model.android = [dict objectForKey:@"android"];
            model.appName = [dict objectForKey:@"appName"];
            model.appPic = [dict objectForKey:@"appPic"];
            model.ios = [dict objectForKey:@"ios"];
            [dataArray addObject:model];
        }
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 我的频道 删除标签

- (void)getDeleteMyChannelWithTag:(NSString *)tag_id WithToken:(NSString *)token {
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getDeleteMyChannelTag];
    url = [NSString stringWithFormat:@"%@tag_id=%@&token=%@",url,tag_id,token];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] intValue] == 4001){
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:nil];
                [SVProgressHUD showSuccessWithStatus:@"删除成功"];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:@"删除失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
            [SVProgressHUD showErrorWithStatus:@"删除失败"];
        }
    }];
}

@end

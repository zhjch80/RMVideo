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
#import "AESCrypt.h"
#import "CommonFunc.h"
#import "Reachability.h"

#if 0
//测试
#define baseUrl         @"http://vodapi.runmobile.cn/debug/index.php/vod/"
#else
//线上
//#define baseUrl         @"http://vodapi.runmobile.cn/index.php/vod/"

#define baseUrl         @"http://vodapi.runmobile.cn/version1_02/api.php/vod/"

#endif

#define kPassWord       @"yu32uzy4"

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
            strUrl = [NSString stringWithFormat:@"%@userFeedback",baseUrl];
            break;
        }
        case Http_getSearchVidieo:{
            strUrl = [NSString stringWithFormat:@"%@search?",baseUrl];
            break;
        }
        case Http_postLogin:{
            strUrl = [NSString stringWithFormat:@"%@login",baseUrl];
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
        case Http_getDeviceHits:{
            strUrl = [NSString stringWithFormat:@"%@getDeviceHits?",baseUrl];
            break;
        }
        case Http_getAboutApp:{
            strUrl = [NSString stringWithFormat:@"%@about?",baseUrl];
            break;
        }
        case Http_getSearchTips:{
            strUrl = [NSString stringWithFormat:@"%@getSearchTips?",baseUrl];
            break;
        }
        case Http_getCheckStarProperty:{
            strUrl = [NSString stringWithFormat:@"%@getVideoNumByTagId?",baseUrl];
            break;
        }
        case Http_getSearchRecommend:{
            strUrl = [NSString stringWithFormat:@"%@getSearchRecommend",baseUrl];
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

#pragma mark - 接口 加密

- (NSString *)encryptUrl:(NSString *)url {
    NSRange range = [url rangeOfString:@"php/vod/"];
    NSString * newUrl = [url substringFromIndex:range.location + 8];
    newUrl = [AESCrypt encrypt:newUrl password:kPassWord];
    /*
     转义
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes
    (NULL, (CFStringRef)newUrl, NULL,
    (CFStringRef)@"!*’();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    */
    newUrl = [NSString stringWithFormat:@"%@decode?data=%@",baseUrl,[CommonFunc base64StringFromText:newUrl]];
    return newUrl;
}

void checkTheNetworkConnection(NSString *title){
    Reachability *r = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:{
            [SVProgressHUD showErrorWithStatus:@"网络连接失败，请检查网络连接"];
            break;
        }
        default:{
            [SVProgressHUD showErrorWithStatus:title];
            break;
        }
    }
}

#pragma mark - 今日推荐

- (void)getDailyRecommend{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getDailyRecommend];
    url = [self encryptUrl:url];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] intValue] == 4001){
            NSMutableArray *dataArray = [NSMutableArray array];
            NSMutableArray *tvArray = [NSMutableArray array];
            for(NSDictionary *dict in [responseObject objectForKey:@"list_tv"]){
                RMPublicModel *model = [[RMPublicModel alloc] init];
                model.name = [dict objectForKey:@"title"];
                model.DailyRecommendPic = [dict objectForKey:@"pic"];
                model.DailyRecommendDescription = [dict objectForKey:@"description"];
                model.DailyRecommendVideo_id = [dict objectForKey:@"video_id"];
                model.DailyRecommendVideo_type = [dict objectForKey:@"video_type"];
                model.jumpurl = [dict objectForKey:@"jumpurl"];
                model.downLoadURL = [dict objectForKey:@"m_down_url"];
                [tvArray addObject:model];
            }
            NSMutableDictionary *tv = [[NSMutableDictionary alloc] init];
            [tv setObject:tvArray forKey:@"电视剧"];
            NSMutableArray *movieArray = [NSMutableArray array];
            for(NSDictionary *dict in [responseObject objectForKey:@"list_vod"]){
                RMPublicModel *model = [[RMPublicModel alloc] init];
                model.name = [dict objectForKey:@"title"];
                model.DailyRecommendPic = [dict objectForKey:@"pic"];
                model.DailyRecommendDescription = [dict objectForKey:@"description"];
                model.DailyRecommendVideo_id = [dict objectForKey:@"video_id"];
                model.DailyRecommendVideo_type = [dict objectForKey:@"video_type"];
                model.jumpurl = [dict objectForKey:@"jumpurl"];
                model.downLoadURL = [dict objectForKey:@"m_down_url"];
                [movieArray addObject:model];
            }
            NSMutableDictionary *movie = [[NSMutableDictionary alloc] init];
            [movie setObject:movieArray forKey:@"电影"];
            
            NSMutableArray *varietyArray = [NSMutableArray array];
            for(NSDictionary *dict in [responseObject objectForKey:@"list_variety"]){
                RMPublicModel *model = [[RMPublicModel alloc] init];
                model.name = [dict objectForKey:@"title"];
                model.DailyRecommendPic = [dict objectForKey:@"pic"];
                model.DailyRecommendDescription = [dict objectForKey:@"description"];
                model.DailyRecommendVideo_id = [dict objectForKey:@"video_id"];
                model.DailyRecommendVideo_type = [dict objectForKey:@"video_type"];
                model.jumpurl = [dict objectForKey:@"jumpurl"];
                model.downLoadURL = [dict objectForKey:@"m_down_url"];
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
        checkTheNetworkConnection(@"下载失败");
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
    url = [self encryptUrl:url];
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
                model.jumpurl = [dict objectForKey:@"jumpurl"];
                model.downLoadURL = [dict objectForKey:@"m_down_url"];
                [dataArray addObject:model];
            }
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:dataArray];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        checkTheNetworkConnection(@"下载失败");
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
    url = [self encryptUrl:url];
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
        checkTheNetworkConnection(@"下载失败");
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
    url = [self encryptUrl:url];
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
        checkTheNetworkConnection(@"下载失败");
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
    url = [self encryptUrl:url];
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
            checkTheNetworkConnection(@"收藏失败");
        if ([self.delegate respondsToSelector:@selector(requestError:)]) {
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 我的频道

- (void)getMyChannelVideoListWithToken:(NSString *)token pageNumber:(NSString *)page count:(NSString *)count {
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getMyChannelVideoList];
    url = [NSString stringWithFormat:@"%@token=%@&limit_tag=%@&offset_tag=%@",url,token,count,[self setOffsetWith:page andCount:count]];
    url = [self encryptUrl:url];
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
        checkTheNetworkConnection(@"下载失败");
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
    url = [self encryptUrl:url];
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
        checkTheNetworkConnection(@"下载失败");
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
    url = [self encryptUrl:url];
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
        checkTheNetworkConnection(@"获取失败");
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
    url = [self encryptUrl:url];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *dataArray = [NSMutableArray array];
        RMPublicModel *model = [[RMPublicModel alloc] init];
        model.code = [responseObject objectForKey:@"code"];
        [dataArray addObject:model];
        if ([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]) {
            [self.delegate requestFinishiDownLoadWith:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        checkTheNetworkConnection(@"下载失败");
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
    url = [self encryptUrl:url];
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
                model.jumpurl = [dict objectForKey:@"jumpurl"];
                model.downLoadURL = [dict objectForKey:@"m_down_url"];
                [array addObject:model];
            }
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:array];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:@"服务器忙，请稍后再试"];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        checkTheNetworkConnection(@"下载失败");
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 明星列表

- (void)getStarListWithPage:(NSString *)page count:(NSString *)count WithToken:(NSString *)token{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getStarList];
    url = [NSString stringWithFormat:@"%@limit=%@&offset=%@&token=%@",url,count,[self setOffsetWith:page andCount:count],token];
    url = [self encryptUrl:url];
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
        checkTheNetworkConnection(@"下载失败");
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
    url = [self encryptUrl:url];
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
        checkTheNetworkConnection(@"下载失败");
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
    url = [self encryptUrl:url];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([[responseObject objectForKey:@"code"] intValue] == 4001){
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self performSelector:@selector(showAddSuccess) withObject:nil afterDelay:0.2];
                [self.delegate requestFinishiDownLoadWith:nil];
            }
        }else if([[responseObject objectForKey:@"code"] integerValue] == 4006) {
            [SVProgressHUD showSuccessWithStatus:@"已经在我的频道"];
        }else{
            [SVProgressHUD showErrorWithStatus:@"添加失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        checkTheNetworkConnection(@"添加失败");
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

- (void)showAddSuccess {
    [SVProgressHUD showSuccessWithStatus:@"已添加到我到的频道" duration:1.0];
}

#pragma mark - 设置：我的收藏视频列表

- (void)getFavoriteVideoListWithToken:(NSString *)token Page:(NSString *)page count:(NSString *)count{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getFavoriteVideoList];
    url = [NSString stringWithFormat:@"%@token=%@&limit=%@&offset=%@",url,token,count,[self setOffsetWith:page andCount:count]];
    url = [self encryptUrl:url];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] integerValue] == 4001){
            NSMutableArray *array = [NSMutableArray array];
            for(NSDictionary *dict in [responseObject objectForKey:@"list"]){
                RMPublicModel *model = [[RMPublicModel alloc] init];
                model.pic = [dict objectForKey:@"pic"];
                model.name = [dict objectForKey:@"name"];
                model.video_id =[dict objectForKey:@"video_id"];
                model.video_type = [dict objectForKey:@"video_type"];
                model.jumpurl = [dict objectForKey:@"jumpurl"];
                model.downLoadURL= [dict objectForKey:@"m_down_url"];
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
        checkTheNetworkConnection(@"下载失败");
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 设置：我的收藏：取消收藏

- (void)getDeleteFavoriteVideoWithToken:(NSString *)token videoID:(NSString *)ID{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getDeleteFavoriteVideo];
    url = [NSString stringWithFormat:@"%@token=%@&video_ids=%@",url,token,ID];
    url = [self encryptUrl:url];
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
        checkTheNetworkConnection(@"取消收藏失败");
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 设置：用户反馈

- (void)postUserFeedbackWithToken:(NSString *)token andFeedBackString:(NSString *)string{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_postUserFeedback];
    NSDictionary * parameter = @{
                                 @"token": [NSString stringWithFormat:@"%@",token],
                                 @"text": [NSString stringWithFormat:@"%@",string]
                                 };
    [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] intValue]==4001){
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:nil];
            }
        }else{
            [SVProgressHUD showErrorWithStatus:@"提交失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        checkTheNetworkConnection(@"提交失败");
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 联想动态搜索

- (void)getDynamicAssociativeSearchWithKeyWord:(NSString *)string {
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getSearchTips];
    url = [NSString stringWithFormat:@"%@word=%@",url,string];
    url = [self encryptUrl:url];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *dataArray = [NSMutableArray array];
        RMPublicModel * model = [[RMPublicModel alloc] init];
        model.DynamicAssociativeArr = [responseObject objectForKey:@"data"];
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

#pragma mark - 搜索

- (void)getSearchVideoWithKeyword:(NSString *)string Page:(NSString *)page count:(NSString *)count{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getSearchVidieo];
    url = [NSString stringWithFormat:@"%@keyword=%@&limit=%@&offset=%@",url,string,count,[self setOffsetWith:page andCount:count]];
    url = [self encryptUrl:url];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *dataArray = [NSMutableArray array];
        RMPublicModel * model = [[RMPublicModel alloc] init];
        model.keyword = [[responseObject objectForKey:@"data"] objectForKey:@"keyword"];
        model.rows = [[responseObject objectForKey:@"data"] objectForKey:@"rows"];
        model.star_list = [[responseObject objectForKey:@"data"] objectForKey:@"star_list"];
        model.video_list = [[responseObject objectForKey:@"data"] objectForKey:@"video_list"];
        model.message = [responseObject objectForKey:@"message"];
        [dataArray addObject:model];
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:dataArray];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        checkTheNetworkConnection(@"搜索失败");
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 登录

- (void)postLoginWithSourceType:(NSString *)type sourceId:(NSString *)ID username:(NSString *)name headImageURL:(NSString *)imageUrl{
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_postLogin];
    NSDictionary * parameter = @{
                                 @"source_type": [NSString stringWithFormat:@"%@",type],
                                 @"source_id": [NSString stringWithFormat:@"%@",ID],
                                 @"username": [NSString stringWithFormat:@"%@",name],
                                 @"face": [NSString stringWithFormat:@"%@",imageUrl]
                                 };
    [manager POST:url parameters:parameter success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] intValue] == 4001){
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:[NSMutableArray arrayWithObjects:[ responseObject objectForKey:@"token"], nil]];
            }
        }
        else{
            [SVProgressHUD showErrorWithStatus:@"登录失败"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        checkTheNetworkConnection(@"登录失败");
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 设置：更多应用

- (void)getMoreAppSpread {
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getMoreAppSpread];
    url = [self encryptUrl:url];
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
        checkTheNetworkConnection(@"获取失败");
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
    url = [self encryptUrl:url];
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
        checkTheNetworkConnection(@"删除失败");
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 行为统计 统计影片播放次数

- (void)getDeviceHitsWithVideo_id:(NSString *)video_id WithDevice:(NSString *)device {
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getDeviceHits];
    url = [NSString stringWithFormat:@"%@video_id=%@&device=%@",url,video_id,device];
    url = [self encryptUrl:url];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] intValue] == 4001){
            NSLog(@"success");
        }else{
            NSLog(@"fail");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 关于

- (void)getAboutAppWithOS:(NSString *)os withVersionNumber:(NSString *)versionNumber {
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getAboutApp];
    url = [NSString stringWithFormat:@"%@os=%@&versionNumber=%@",url,os,versionNumber];
    url = [self encryptUrl:url];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        if([[responseObject objectForKey:@"code"] intValue] == 4001){
            RMPublicModel * model = [[RMPublicModel alloc] init];
            model.AppVersionUrl = [responseObject objectForKey:@"url"];
            NSMutableArray *dataArray = [NSMutableArray arrayWithObjects:model, nil];
            if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
                [self.delegate requestFinishiDownLoadWith:dataArray];
            }
        }else{
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        checkTheNetworkConnection(@"获取失败");
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 判断明星标签下的属性

- (void)getCheckStarPropertyWithStar_id:(NSString *)star_id {
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getCheckStarProperty];
    url = [NSString stringWithFormat:@"%@tag_id=%@",url,star_id];
    url = [self encryptUrl:url];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        NSMutableArray *arr = [NSMutableArray arrayWithObjects:[responseObject objectForKey:@"data"], nil];
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:arr];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

#pragma mark - 搜索 标签推荐

- (void)getSearchRecommend {
    AFHTTPRequestOperationManager *manager = [self creatAFNNetworkRequestManager];
    NSString *url = [self urlPathadress:Http_getSearchRecommend];
    url = [NSString stringWithFormat:@"%@",url];
    url = [self encryptUrl:url];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
        NSMutableArray *arr = [NSMutableArray array];
        for (int i=0; i<[[responseObject objectForKey:@"data"] count]; i++){
            [arr addObject:[[responseObject objectForKey:@"data"] objectAtIndex:i]];
        }
        if([self.delegate respondsToSelector:@selector(requestFinishiDownLoadWith:)]){
            [self.delegate requestFinishiDownLoadWith:arr];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if([self.delegate respondsToSelector:@selector(requestError:)]){
            [self.delegate requestError:error];
        }
    }];
}

@end

//
//  RMShouldSeeVarietViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-31.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMShouldSeeVarietViewController.h"
#import "RMVideoPlaybackDetailsViewController.h"
#import "RMMyChannelShouldSeeViewController.h"
#import "RMWebViewPlayViewController.h"
#import "RMPlayer.h"
#import "RMModel.h"
#import "RMCustomPresentNavViewController.h"

@interface RMShouldSeeVarietViewController ()<RefreshControlDelegate>{
    BOOL isDownLoad;
    NSInteger pageNum;//请求的页码
    BOOL isRefresh;
    NSInteger allPageCount;
}

@end

@implementation RMShouldSeeVarietViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_MyChannel_Variety" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_MyChannel_Variety" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [[NSMutableArray alloc] init];
     self.mainTableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth,[UtilityFunc shareInstance].globleAllHeight-44-64);
    self.mainTableView.backgroundColor = [UIColor clearColor];
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _refreshControl=[[RefreshControl alloc] initWithScrollView:self.mainTableView delegate:self];
    _refreshControl.topEnabled=YES;
    _refreshControl.bottomEnabled=YES;
    
    pageNum = 0;
    isRefresh = YES;
}
- (void)requestData{
    if(!isDownLoad){
        [SVProgressHUD showWithStatus:@"下载中..." maskType:SVProgressHUDMaskTypeClear];
        RMAFNRequestManager *manager = [[RMAFNRequestManager alloc] init];
        manager.delegate = self;
        //视频类型（1：电影 2：电视剧 3：综艺）
        //排行类型（1：日榜 2：周榜 3：月榜）
        [manager getTagOfVideoListWithID:self.downLoadID andVideoType:@"3" WithPage:[NSString stringWithFormat:@"%d",pageNum] count:@"12"];
        isDownLoad = YES;
    }
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataArray.count == 0){
        [self showEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无数据"];
    }else{
        [self isShouldSetHiddenEmptyView:YES];
    }
    if ([self.dataArray count]%3 == 0){
        return [self.dataArray count] / 3;
    }else if ([self.dataArray count]%3 == 1){
        return ([self.dataArray count] + 2) / 3;
    }else {
        return ([self.dataArray count] + 1) / 3;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        return 185;
    }else if (IS_IPHONE_6_SCREEN){
        return 190;
    }else{
        return 225;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellName = @"RMStarDetailsCellIdentifier";
    RMStarDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell ==nil){
        if (IS_IPHONE_6_SCREEN){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"RMStarDetailsCell_6" owner:self options:nil] lastObject];
        }else if (IS_IPHONE_6p_SCREEN){
            cell = [[[NSBundle mainBundle] loadNibNamed:@"RMStarDetailsCell_6p" owner:self options:nil] lastObject];
        }else{
            cell = [[[NSBundle mainBundle] loadNibNamed:@"RMStarDetailsCell" owner:self options:nil] lastObject];
        }
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.delegate = self;
    
    RMPublicModel *model_left = [self.dataArray objectAtIndex:indexPath.row*3];
    [cell.fristImage sd_setImageWithURL:[NSURL URLWithString:model_left.pic] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
    cell.fristImage.identifierString = model_left.video_id;
    [cell.fristLable loadTextViewWithString:model_left.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:0];
    [cell.fristLable startScrolling];
    [cell.firstStarRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
    [cell.fristDirectlyPlayBtn setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
    cell.fristDirectlyPlayBtn.tag = indexPath.row;
    cell.secondDirectlyPlayBtn.hidden = YES;
    cell.thirdDirectlyPlayBtn.hidden = YES;
    [cell.firstStarRateView displayRating:[model_left.gold integerValue]];
    
    if (indexPath.row * 3 + 1 < [self.dataArray count]){
        
        RMPublicModel *model_center = [self.dataArray objectAtIndex:indexPath.row*3 + 1];
        [cell.secondImage sd_setImageWithURL:[NSURL URLWithString:model_center.pic] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
        cell.secondImage.identifierString = model_center.video_id;
        [cell.secondLable loadTextViewWithString:model_center.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:0];
        [cell.secondLable startScrolling];
        [cell.secondStarRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.secondDirectlyPlayBtn setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
        cell.secondDirectlyPlayBtn.tag = indexPath.row;
        cell.secondDirectlyPlayBtn.hidden = NO;
        [cell.secondStarRateView displayRating:[model_center.gold integerValue]];
    }
    
    if (indexPath.row * 3 + 2 < [self.dataArray count]){
        
        RMPublicModel *model_right = [self.dataArray objectAtIndex:indexPath.row*3 + 2];
        [cell.threeImage sd_setImageWithURL:[NSURL URLWithString:model_right.pic] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
        cell.threeImage.identifierString = model_right.video_id;
        [cell.threeLable loadTextViewWithString:model_right.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:0];
        [cell.threeLable startScrolling];
        [cell.thirdStarRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.thirdDirectlyPlayBtn setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
        cell.thirdDirectlyPlayBtn.tag = indexPath.row;
        cell.thirdDirectlyPlayBtn.hidden = NO;
        [cell.thirdStarRateView displayRating:[model_right.gold integerValue]];
    }
    return cell;
}

- (void)reloadTableViewWithDataArray:(NSMutableArray *)array{
    self.dataArray = array;
    [self.mainTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    
    if (data.count==0) {
        [SVProgressHUD showErrorWithStatus:@"综艺暂无数据"];
    }else{
        [SVProgressHUD dismiss];
        RMPublicModel * model_row = [data objectAtIndex:0];
        allPageCount = [model_row.rows integerValue];
        if (isRefresh){
            self.dataArray = data;
        }else{
            for (int i=0; i<data.count; i++) {
                RMPublicModel * model = [data objectAtIndex:i];
                [self.dataArray addObject:model];
            }
        }
        [self.mainTableView reloadData];
        if (self.refreshControl.refreshingDirection==RefreshingDirectionTop)
        {
            [self.refreshControl finishRefreshingDirection:RefreshDirectionTop];
        }
        else if (self.refreshControl.refreshingDirection==RefreshingDirectionBottom)
        {
            [self.refreshControl finishRefreshingDirection:RefreshDirectionBottom];
        }
    }

}

- (void)requestError:(NSError *)error{
    
}
- (void)startDetailsCellDidSelectWithImage:(RMImageView *)imageView{
    RMVideoPlaybackDetailsViewController * videoPlaybackDetailsCtl = [[RMVideoPlaybackDetailsViewController alloc] init];
    RMMyChannelShouldSeeViewController * myChannelShouldDelegate = self.myChannelShouldDelegate;
    videoPlaybackDetailsCtl.currentVideo_id = imageView.identifierString;
    [myChannelShouldDelegate.navigationController pushViewController:videoPlaybackDetailsCtl animated:YES];
    [videoPlaybackDetailsCtl setAppearTabBarNextPopViewController:kNO];
}
/**
 *  直接播放
 *
 *  @param index    对应cell的位置
 *  @param location 相应cell上button的位置
 */
- (void)playBtnWithIndex:(NSInteger)index andLocation:(NSInteger)location{
    NSInteger number = index*3+location;
    RMPublicModel *model =[self.dataArray objectAtIndex:number];
    if ([model.urls count] == 0){
        [SVProgressHUD showErrorWithStatus:@"暂时不能播放该视频"];
        return ;
    }
    RMMyChannelShouldSeeViewController * myChannelShouldDelegate = self.myChannelShouldDelegate;
    if([[[model.urls objectAtIndex:0] objectForKey:@"m_down_url"] isEqualToString:@""] || [[model.urls objectAtIndex:0] objectForKey:@"m_down_url"] == nil){
        if([[[model.urls objectAtIndex:0] objectForKey:@"jumpurl"] isEqualToString:@""] || [[model.urls objectAtIndex:0] objectForKey:@"jumpurl"] == nil){
            [SVProgressHUD showErrorWithStatus:@"暂时不能播放该视频"];
            return;
        }
        //跳转web
        //保存数据sqlit
        RMPublicModel *insertModel = [[RMPublicModel alloc] init];
        insertModel.name = model.name;
        insertModel.pic_url = model.pic;
        insertModel.jumpurl = [[model.urls objectAtIndex:0] objectForKey:@"jumpurl"];
        insertModel.playTime = @"0";
        insertModel.video_id = model.video_id;
        [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
        RMWebViewPlayViewController *webView = [[RMWebViewPlayViewController alloc] init];
        RMCustomPresentNavViewController * webNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:webView];
        webView.urlString = [[model.urls objectAtIndex:0] objectForKey:@"jumpurl"];
        [myChannelShouldDelegate presentViewController:webNav animated:YES completion:^{
        }];
    }else{
        //使用custom play 播放mp4
        //保存数据sqlit
        RMPublicModel *insertModel = [[RMPublicModel alloc] init];
        insertModel.name = model.name;
        insertModel.pic_url = model.pic;
        insertModel.reurl = [[model.urls objectAtIndex:0] objectForKey:@"m_down_url"];
        insertModel.playTime = @"0";
        insertModel.video_id = model.video_id;
        [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
        
        NSMutableArray * arr = [[NSMutableArray alloc] init];
        for (int i=0; i<[model.urls count]; i++) {
            RMModel * playmodel = [[RMModel alloc] init];
            playmodel.url = [[model.urls objectAtIndex:i] objectForKey:@"m_down_url"];
            playmodel.title = model.name;
            playmodel.EpisodeValue = [[model.urls objectAtIndex:i] objectForKey:@"order"];
            [arr addObject:playmodel];
        }
        [RMPlayer presentVideoPlayerWithPlayArray:arr withUIViewController:myChannelShouldDelegate withVideoType:2];
    }
}

- (void)refreshControl:(RefreshControl *)refreshControl didEngageRefreshDirection:(RefreshDirection)direction
{
    if (direction==RefreshDirectionTop)
    {
        isRefresh = YES;
        pageNum = 0;
        isDownLoad = NO;
        [self requestData];
    }
    else if (direction==RefreshDirectionBottom)
    {
        if (pageNum * 12 + 12 > allPageCount){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD showErrorWithStatus:@"没有更多的数据加载了"];
                [self.refreshControl finishRefreshingDirection:RefreshDirectionBottom];
            });
            
        }else{
            isDownLoad = NO;
            pageNum ++;
            isRefresh = NO;
            [self requestData];
        }
        
    }
}
@end

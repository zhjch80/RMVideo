//
//  RMStarFilmListViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-14.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMStarFilmListViewController.h"
#import "RMStarDetailsCell.h"
#import "RMVideoPlaybackDetailsViewController.h"
#import "RMStarDetailsViewController.h"
#import "RefreshControl.h"
#import "CustomRefreshView.h"

@interface RMStarFilmListViewController ()<UITableViewDataSource,UITableViewDelegate,StarDetailsCellDelegate,RMAFNRequestManagerDelegate,RefreshControlDelegate>{
    NSMutableArray * dataArr;
    NSInteger AltogetherRows;               //总共有多少条数据
    NSInteger pageCount;
    BOOL isRefresh;
}
@property (nonatomic, strong) UITableView * mTableView;
@property (nonatomic, strong) RefreshControl * refreshControl;

@end

@implementation RMStarFilmListViewController
@synthesize starDetailsDelegate = _starDetailsDelegate;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_StarDetail_Film" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_StarDetail_Film" withParameters:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startRequest];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dataArr = [[NSMutableArray alloc] init];

    self.mTableView = [[UITableView alloc] init];
    self.mTableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 190 - 44 - 10);
    self.mTableView.delegate = self;
    self.mTableView.dataSource = self;
    self.mTableView.backgroundColor = [UIColor clearColor];
    self.mTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.mTableView];
    
    self.refreshControl=[[RefreshControl alloc] initWithScrollView:self.mTableView delegate:self];
    self.refreshControl.topEnabled=YES;
    self.refreshControl.bottomEnabled=YES;
    [self.refreshControl registerClassForTopView:[CustomRefreshView class]];

    pageCount = 0;
    isRefresh = YES;
}

#pragma mark 刷新代理

- (void)refreshControl:(RefreshControl *)refreshControl didEngageRefreshDirection:(RefreshDirection)direction {
    if (direction == RefreshDirectionTop) { //下拉刷新
        isRefresh = YES;
        pageCount = 0;
        [self startRequest];
    }else if(direction == RefreshDirectionBottom) { //上拉加载
        if (pageCount * 12 + 12 > AltogetherRows){
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.44 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [SVProgressHUD showSuccessWithStatus:@"没有更多内容了" duration:1.0];
                [self.refreshControl finishRefreshingDirection:RefreshDirectionBottom];
            });
        }else{
            pageCount ++;
            isRefresh = NO;
            [self startRequest];
        }
    }
}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([dataArr count] == 0){
        [self showUnderEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无内容" WithHeight:([UtilityFunc shareInstance].globleHeight-154)/2 - 77-90];
    }else{
        [self isShouldSetHiddenUnderEmptyView:YES];
    }
    if ([dataArr count]%3 == 0){
        return [dataArr count] / 3;
    }else if ([dataArr count]%3 == 1){
        return ([dataArr count] + 2) / 3;
    }else {
        return ([dataArr count] + 1) / 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"RMStarDetailsCellIdentifier";
    RMStarDetailsCell * cell = (RMStarDetailsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        NSArray *array;
        if (IS_IPHONE_6_SCREEN){
            array = [[NSBundle mainBundle] loadNibNamed:@"RMStarDetailsCell_6" owner:self options:nil];
        }else if (IS_IPHONE_6p_SCREEN){
            array = [[NSBundle mainBundle] loadNibNamed:@"RMStarDetailsCell_6p" owner:self options:nil];
        }else{
            array = [[NSBundle mainBundle] loadNibNamed:@"RMStarDetailsCell" owner:self options:nil];
        }
            
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    RMPublicModel *model_left = [dataArr objectAtIndex:indexPath.row*3];
    [cell.fristLable loadTextViewWithString:model_left.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:0];
    [cell.fristLable startScrolling];
    
    [cell.fristImage sd_setImageWithURL:[NSURL URLWithString:model_left.pic] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
    cell.fristImage.identifierString = model_left.video_id;
    [cell.firstStarRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
    [cell.fristDirectlyPlayBtn setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
    cell.fristDirectlyPlayBtn.tag = indexPath.row;
    cell.thirdDirectlyPlayBtn.hidden = YES;
    cell.secondDirectlyPlayBtn.hidden = YES;
    [cell.firstStarRateView displayRating:[model_left.gold integerValue]];

    
    if (indexPath.row * 3 + 1 < [dataArr count]){
        RMPublicModel *model_center = [dataArr objectAtIndex:indexPath.row*3 + 1];
        [cell.secondLable loadTextViewWithString:model_center.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:0];
        [cell.secondLable startScrolling];
        [cell.secondImage sd_setImageWithURL:[NSURL URLWithString:model_center.pic] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
        cell.secondImage.identifierString = model_center.video_id;
        [cell.secondStarRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.secondDirectlyPlayBtn setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
        cell.secondDirectlyPlayBtn.tag = indexPath.row;
        cell.secondDirectlyPlayBtn.hidden = NO;
        [cell.secondStarRateView displayRating:[model_center.gold integerValue]];
    }

    
    if (indexPath.row * 3 + 2 < [dataArr count]){
        RMPublicModel *model_right = [dataArr objectAtIndex:indexPath.row*3 + 2];
        [cell.threeLable loadTextViewWithString:model_right.name WithTextFont:[UIFont systemFontOfSize:14.0] WithTextColor:[UIColor blackColor] WithTextAlignment:NSTextAlignmentCenter WithSetupLabelCenterPoint:YES WithTextOffset:0];
        [cell.threeLable startScrolling];
        [cell.threeImage sd_setImageWithURL:[NSURL URLWithString:model_right.pic] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
        cell.threeImage.identifierString = model_right.video_id;
        [cell.thirdStarRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
        [cell.thirdDirectlyPlayBtn setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
        cell.thirdDirectlyPlayBtn.tag = indexPath.row;
        cell.thirdDirectlyPlayBtn.hidden = NO;
        [cell.thirdStarRateView displayRating:[model_right.gold integerValue]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        return 185;
    }else if (IS_IPHONE_6_SCREEN){
        return 190;
    }else{
        return 225;
    }
    return 155;
}

#pragma mark - StarDetailsCellDelegate

- (void)startDetailsCellDidSelectWithImage:(RMImageView *)imageView {
    RMVideoPlaybackDetailsViewController * videoPlaybackDetailsCtl = [[RMVideoPlaybackDetailsViewController alloc] init];
    RMStarDetailsViewController * starDetailsDelegate = _starDetailsDelegate;
    videoPlaybackDetailsCtl.currentVideo_id = imageView.identifierString;
    [starDetailsDelegate.navigationController pushViewController:videoPlaybackDetailsCtl animated:YES];
    [videoPlaybackDetailsCtl setAppearTabBarNextPopViewController:kNO];
}

/**
 *  直接播放
 *
 *  @param index    对应cell的位置
 *  @param location 相应cell上button的位置
 */
- (void)playBtnWithIndex:(NSInteger)index andLocation:(NSInteger)location{
    
}

#pragma mark - request RMAFNRequestManagerDelegate

- (void)startRequest{
    RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
    [request getTagOfVideoListWithID:self.star_id andVideoType:@"1" WithPage:[NSString stringWithFormat:@"%d",pageCount] count:@"12"];
    request.delegate = self;
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    if (self.refreshControl.refreshingDirection==RefreshingDirectionTop) {
        RMPublicModel * model = [data objectAtIndex:0];
        AltogetherRows = [model.rows integerValue];
        dataArr = data;
        [self.mTableView reloadData];
        [self.refreshControl finishRefreshingDirection:RefreshDirectionTop];
    }else if(self.refreshControl.refreshingDirection==RefreshingDirectionBottom) {
        if (data.count == 0){
            [SVProgressHUD showSuccessWithStatus:@"没有更多内容了" duration:1.0];
            [self.refreshControl finishRefreshingDirection:RefreshDirectionBottom];
            return;
        }
        RMPublicModel * model = [data objectAtIndex:0];
        AltogetherRows = [model.rows integerValue];
        for (int i=0; i<data.count; i++) {
            RMPublicModel * model = [data objectAtIndex:i];
            [dataArr addObject:model];
        }
        [self.mTableView reloadData];
        [self.refreshControl finishRefreshingDirection:RefreshDirectionBottom];
    }
    
    if (isRefresh){
        RMPublicModel * model = [data objectAtIndex:0];
        AltogetherRows = [model.rows integerValue];
        dataArr = data;
        [self.mTableView reloadData];
    }
}

-(void)requestError:(NSError *)error {
    NSLog(@"star 电影 error:%@",error);
}

@end

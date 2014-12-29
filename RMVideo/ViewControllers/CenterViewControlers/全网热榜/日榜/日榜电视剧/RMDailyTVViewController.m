//
//  RMDailyTVViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDailyTVViewController.h"
#import "RMDailyListTableViewCell.h"
#import "RMImageView.h"

@interface RMDailyTVViewController ()<RMDailyListTableViewCellDelegate>{
     BOOL isAlreadyDownLoad;
}

@end

@implementation RMDailyTVViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_ToDayRecommended_TVseries" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_ToDayRecommended_TVseries" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN){
        self.mainTableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth,[UtilityFunc shareInstance].globleAllHeight-44-64);
    }else if (IS_IPHONE_6_SCREEN){
        self.mainTableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth,[UtilityFunc shareInstance].globleAllHeight-44-64);
    }else{
        self.mainTableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth,[UtilityFunc shareInstance].globleAllHeight-54-64);
    }
    _refreshControl=[[RefreshControl alloc] initWithScrollView:self.mainTableView delegate:self];
    _refreshControl.topEnabled=YES;
    _refreshControl.bottomEnabled=NO;
    
    [self setExtraCellLineHidden:self.mainTableView];
}

- (void)requestData{
    if(!isAlreadyDownLoad){
        [SVProgressHUD showWithStatus:@"下载中..." maskType:SVProgressHUDMaskTypeBlack];
        RMAFNRequestManager *manager = [[RMAFNRequestManager alloc] init];
        manager.delegate = self;
        //视频类型（1：电影 2：电视剧 3：综艺）
        //排行类型（1：日榜 2：周榜 3：月榜）
        [manager getTopListWithVideoTpye:@"2" andTopType:self.downLoadTopType searchPageNumber:@"1" andCount:@"10"];
        isAlreadyDownLoad = YES;
    }
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.dataArray.count == 0){
        [self showEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无数据"];
    }else{
        [self isShouldSetHiddenEmptyView:YES];
    }
    return self.dataArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellName = @"DailyListCellIndex";
    RMDailyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell ==nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMDailyListTableViewCell" owner:self options:nil] lastObject];
    }
    RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:LOADIMAGE(@"Default90_135", kImageTypePNG)];
    cell.movieName.text = model.name;
    cell.playCount.text = model.sum_i_hits;
    cell.playBtn.tag = indexPath.row;
    cell.delegate = self;
    cell.movieKind.text = [NSString stringWithFormat:@"分类:%@",model.video_type];
    [(RMImageView *)cell.TopImage addTopNumber:[model.topNum intValue]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if([self.delegate respondsToSelector:@selector(selectTVTableViewCellWithIndex: andStringID:)])
    {
        [self.delegate selectTVTableViewCellWithIndex:indexPath.row andStringID:model.video_id];
    }
}

- (void)refreshControl:(RefreshControl *)refreshControl didEngageRefreshDirection:(RefreshDirection)direction
{
    if (direction==RefreshDirectionTop)
    {
        [SVProgressHUD showWithStatus:@"加载中..."];
        RMAFNRequestManager *manager = [[RMAFNRequestManager alloc] init];
        manager.delegate = self;
        [manager getTopListWithVideoTpye:@"2" andTopType:self.downLoadTopType searchPageNumber:@"1" andCount:@"10"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    [self.refreshControl finishRefreshingDirection:RefreshDirectionTop];
    if (data.count==0) {
        [SVProgressHUD showErrorWithStatus:@"电视剧暂无数据"];
        return;
    }
    [SVProgressHUD dismiss];
    [self.dataArray removeAllObjects];
    self.dataArray = data;
    [self.mainTableView reloadData];
}

- (void)requestError:(NSError *)error{
}
- (void)palyMovieWithIndex:(NSInteger)index{
    if([self.delegate respondsToSelector:@selector(playTVWithModel:)]){
        RMPublicModel *model = [self.dataArray objectAtIndex:index];
        [self.delegate playTVWithModel:model];
    }
}

@end

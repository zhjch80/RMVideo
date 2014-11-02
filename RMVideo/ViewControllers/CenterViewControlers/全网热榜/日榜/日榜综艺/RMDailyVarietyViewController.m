//
//  RMDailyVarietyViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDailyVarietyViewController.h"
#import "RMDailyListTableViewCell.h"
#import "RMImageView.h"

@interface RMDailyVarietyViewController ()

@end

@implementation RMDailyVarietyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.mainTableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth,[UtilityFunc shareInstance].globleAllHeight-44-64);
    [SVProgressHUD showWithStatus:@"下载中..." maskType:SVProgressHUDMaskTypeBlack];
    RMAFNRequestManager *manager = [[RMAFNRequestManager alloc] init];
    manager.delegate = self;
    //视频类型（1：电影 2：电视剧 3：综艺）
    //排行类型（1：日榜 2：周榜 3：月榜）
    [manager getTopListWithVideoTpye:@"3" andTopType:@"1" searchPageNumber:@"1" andCount:@"10"];
    [self setExtraCellLineHidden:self.mainTableView];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 101;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellName = @"DailyListCell";
    RMDailyListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell ==nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMDailyListTableViewCell" owner:self options:nil] lastObject];
    }
    RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.pic]];
    cell.movieName.text = model.name;
    cell.playCount.text = model.sum_i_hits;
    [(RMImageView *)cell.TopImage addTopNumber:indexPath.row+1];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if([self.delegate respondsToSelector:@selector(selectVarietyTableViewCellWithIndex: andStringID:)]){
        [self.delegate selectVarietyTableViewCellWithIndex:indexPath.row andStringID:model.video_id];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    
    if (data.count==0) {
        [SVProgressHUD showErrorWithStatus:@"综艺暂无数据"];
        return;
    }
    [SVProgressHUD dismiss];
    NSLog(@"综艺data:%@",data);
}

- (void)requestError:(NSError *)error{
    [SVProgressHUD showErrorWithStatus:@"下载失败"];
}

@end

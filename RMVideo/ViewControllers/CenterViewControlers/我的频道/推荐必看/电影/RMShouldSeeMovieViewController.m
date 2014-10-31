//
//  RMShouldSeeMovieViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-31.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMShouldSeeMovieViewController.h"
#import "UIImageView+AFNetworking.h"
#import "RMVideoPlaybackDetailsViewController.h"
#import "RMMyChannelShouldSeeViewController.h"

@interface RMShouldSeeMovieViewController ()

@end

@implementation RMShouldSeeMovieViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [[NSMutableArray alloc] init];
    self.mainTableView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth,[UtilityFunc shareInstance].globleAllHeight-44-64);
    [SVProgressHUD showWithStatus:@"下载中..." maskType:SVProgressHUDMaskTypeBlack];
    RMAFNRequestManager *manager = [[RMAFNRequestManager alloc] init];
    manager.delegate = self;
    //视频类型（1：电影 2：电视剧 3：综艺）
    //排行类型（1：日榜 2：周榜 3：月榜）
    NSLog(@"------11self.downLoadID:%@",self.downLoadID);
    //TODO:  换成动态的id
    [manager getTagOfVideoListWithID:@"25155" andVideoType:@"1"];
    [self setExtraCellLineHidden:self.mainTableView];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
//    if(self.dataArray.count%3==0)
        return self.dataArray.count/3;
//    else
//        return self.dataArray.count/3+1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 155;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellName = @"RMStarDetailsCellIdentifier";
    RMStarDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell ==nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMStarDetailsCell" owner:self options:nil] lastObject];
    }
    cell.delegate = self;
//    if(indexPath.row*3 + 1<self.dataArray.count && indexPath.row*3 + 2<self.dataArray.count){
        RMPublicModel *model_left = [self.dataArray objectAtIndex:indexPath.row*3];
        RMPublicModel *model_center = [self.dataArray objectAtIndex:indexPath.row*3 + 1];
        RMPublicModel *model_right = [self.dataArray objectAtIndex:indexPath.row*3 + 2];
        [cell.fristImage setImageWithURL:[NSURL URLWithString:model_left.pic]];
        [cell.secondImage setImageWithURL:[NSURL URLWithString:model_center.pic]];
        [cell.threeImage setImageWithURL:[NSURL URLWithString:model_right.pic]];
        cell.fristImage.identifierString = model_left.video_id;
        cell.secondImage.identifierString = model_center.video_id;
        cell.threeImage.identifierString = model_right.video_id;
        cell.fristLable.text = model_left.name;
        cell.secondLable.text = model_center.name;
        cell.threeLable.text = model_right.name;
//    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if([self.delegate respondsToSelector:@selector(selectMovieTableViewWithIndex:)]){
//        [self.delegate selectMovieTableViewWithIndex:indexPath.row];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    if (data.count==0) {
        [SVProgressHUD showErrorWithStatus:@"电影暂无数据"];
        return;
    }
    [SVProgressHUD dismiss];
    NSLog(@"电影self.dataArray:%@",data);
    self.dataArray = data;
    [self.mainTableView reloadData];
}

- (void)requestError:(NSError *)error{
    [SVProgressHUD showErrorWithStatus:@"下载失败"];
}

- (void)startDetailsCellDidSelectWithImage:(RMImageView *)imageView{
    //TODO:push到下一个界面
    NSLog(@"identifer:%@",imageView.identifierString);
    RMVideoPlaybackDetailsViewController * videoPlaybackDetailsCtl = [[RMVideoPlaybackDetailsViewController alloc] init];
    RMMyChannelShouldSeeViewController * myChannelShouldDelegate = self.myChannelShouldDelegate;
    [myChannelShouldDelegate.navigationController pushViewController:videoPlaybackDetailsCtl animated:YES];
    [videoPlaybackDetailsCtl setAppearTabBarNextPopViewController:kNO];
}

@end

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

#import "RMAFNRequestManager.h"
#import "RMPublicModel.h"
#import "UIImageView+AFNetworking.h"

@interface RMStarFilmListViewController ()<UITableViewDataSource,UITableViewDelegate,StarDetailsCellDelegate,RMAFNRequestManagerDelegate>{
    NSMutableArray * dataArr;
}

@end

@implementation RMStarFilmListViewController
@synthesize starDetailsDelegate = _starDetailsDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dataArr = [[NSMutableArray alloc] init];
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 42 - 180) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tag = 201;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    
    //TODO: 上拉刷新  下拉加载
    
    NSLog(@"这是第一个");
    //TODO:记得换tag_id
    RMAFNRequestManager * request = [[RMAFNRequestManager alloc] init];
    [request getTagOfVideoListWithID:@"25151" andVideoType:@"1"];
    request.delegate = self;

}

#pragma mark - UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([dataArr count]/3 == 0){
        return [dataArr count]/3;
    }else if ([dataArr count]/3 == 1){
        return ([dataArr count] + 2) / 3;
    }else {
        return ([dataArr count] + 1) / 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"RMStarDetailsCellIdentifier";
    RMStarDetailsCell * cell = (RMStarDetailsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (! cell) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"RMStarDetailsCell" owner:self options:nil];
        cell = [array objectAtIndex:0];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
    }
    
    RMPublicModel *model_left = [dataArr objectAtIndex:indexPath.row*3];
    RMPublicModel *model_center = [dataArr objectAtIndex:indexPath.row*3 + 1];
    RMPublicModel *model_right = [dataArr objectAtIndex:indexPath.row*3 + 2];
    
    cell.fristLable.text = model_left.name;
    cell.secondLable.text = model_center.name;
    cell.threeLable.text = model_right.name;
    
    [cell.fristImage setImageWithURL:[NSURL URLWithString:model_left.pic] placeholderImage:nil];
    cell.fristImage.identifierString = model_left.video_id;
    [cell.secondImage setImageWithURL:[NSURL URLWithString:model_center.pic] placeholderImage:nil];
    cell.secondImage.identifierString = model_center.video_id;
    [cell.threeImage setImageWithURL:[NSURL URLWithString:model_right.pic] placeholderImage:nil];
    cell.threeImage.identifierString = model_right.video_id;
    
    [cell.firstStarRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
    [cell.firstStarRateView displayRating:[model_left.gold integerValue]];
    
    [cell.secondStarRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
    [cell.secondStarRateView displayRating:[model_center.gold integerValue]];
    
    [cell.thirdStarRateView setImagesDeselected:@"mx_rateEmpty_img" partlySelected:@"mx_rateEmpty_img" fullSelected:@"mx_rateFull_img" andDelegate:nil];
    [cell.thirdStarRateView displayRating:[model_right.gold integerValue]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 155;
}

#pragma mark - StarDetailsCellDelegate

- (void)startDetailsCellDidSelectWithImage:(RMImageView *)imageView {
    NSLog(@"电影");
    RMVideoPlaybackDetailsViewController * videoPlaybackDetailsCtl = [[RMVideoPlaybackDetailsViewController alloc] init];
    RMStarDetailsViewController * starDetailsDelegate = _starDetailsDelegate;
    [starDetailsDelegate.navigationController pushViewController:videoPlaybackDetailsCtl animated:YES];
    [videoPlaybackDetailsCtl setAppearTabBarNextPopViewController:kNO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - request RMAFNRequestManagerDelegate

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data {
    dataArr = data;
    NSLog(@"%d",data.count);
    [(UITableView *)[self.view viewWithTag:201] reloadData];
}

-(void)requestError:(NSError *)error {
    NSLog(@"star 电影 error:%@",error);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

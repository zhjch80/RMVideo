//
//  RMRecommendedDailyViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMRecommendedDailyViewController.h"
#import "RMSetupViewController.h"
#import "RMSearchViewController.h"
#import "RMVideoPlaybackDetailsViewController.h"

#import "SDiPhoneVersion.h"


@interface RMRecommendedDailyViewController ()

@end

@implementation RMRecommendedDailyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    
    [leftBarButton setImage:[UIImage imageNamed:@"setup"] forState:UIControlStateNormal];
    [rightBarButton setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
    CellScrollimageArray = [NSMutableArray arrayWithObjects:@"001.png",@"002.png",@"003.png",@"001.png",@"002.png",@"003.png",@"001.png",@"002.png",@"003.png", nil];
    cellHeadImageArray = [NSArray arrayWithObjects:@"jr_movie",@"jr_teleplay",@"jr_Variety", nil];
    self.title = @"今日推荐";
    cellHeadStringArray = [NSArray arrayWithObjects:@"电影",@"电视剧",@"综艺", nil];
    dataArray = [NSMutableArray arrayWithObjects:@"电视",@"电影",@"综艺", nil];
    
    mainTableVeiew = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight-49-44) style:UITableViewStylePlain];
    mainTableVeiew.backgroundColor = [UIColor clearColor];
    mainTableVeiew.delegate = self;
    mainTableVeiew.dataSource = self;
    mainTableVeiew.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:mainTableVeiew];
}

#pragma mark main tableVeiw dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellName = @"RecommendedDaily";
    RMRecommendedDailyTableViewCell *cell = [mainTableVeiew dequeueReusableCellWithIdentifier:cellName];
    if(cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMRecommendedDailyTableViewCell" owner:self options:nil] lastObject];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.headImageView.image = NULL;
    cell.headImageView.image = [UIImage imageNamed:[cellHeadImageArray objectAtIndex:indexPath.row]];
    [cell cellAddMovieCountFromDataArray:CellScrollimageArray andCellIdentifiersName:[cellHeadStringArray objectAtIndex:indexPath.row]];
    cell.delegate = self;

    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(IS_IPHONE_4_SCREEN){
        return 332;
    }else if (IS_IPHONE_5_SCREEN){
        return 375;
    }else if (IS_IPHONE_6_SCREEN){
        return 460;
    }else if (IS_IPHONE_6p_SCREEN){
        return 502;
    }
    return 0;
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewDidEndDecelerating" object:nil];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tableViewWillBeginDragging" object:nil];
}
#pragma mark cell Image点击事件 tag标识每个cell的位置 identifier标识cell
- (void)didSelectCellImageWithTag:(NSInteger)tag andImageViewIdentifier:(NSString *)identifier{
    NSLog(@"tag:%d identifier:%@",tag,identifier);
    if ([identifier isEqualToString:@"电影"]) {
            }
    else if ([identifier isEqualToString:@"电视剧"]) {

    }else{
        
    }
    RMVideoPlaybackDetailsViewController *videoPlay = [[RMVideoPlaybackDetailsViewController alloc] init];
    videoPlay.tabBarIdentifier = kYES;
    [self.navigationController pushViewController:videoPlay animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender{
    switch (sender.tag) {
        case 1:{
            RMSetupViewController * setupCtl = [[RMSetupViewController alloc] init];
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:setupCtl] animated:YES completion:^{
                NSLog(@"setup view appear finished");
                
            }];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
            break;
        }
        case 2:{
            RMSearchViewController * searchCtl = [[RMSearchViewController shared] init];
            
            [self presentViewController:[[UINavigationController alloc] initWithRootViewController:searchCtl] animated:YES completion:^{
                NSLog(@"search view appear finished");
                
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kHideTabbar object:nil];
            break;
        }

        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

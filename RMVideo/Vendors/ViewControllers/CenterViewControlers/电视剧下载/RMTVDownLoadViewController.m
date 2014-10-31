//
//  RMTVDownLoadViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-15.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMTVDownLoadViewController.h"
#import "RMTVDownView.h"

@interface RMTVDownLoadViewController ()

@end

@implementation RMTVDownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择要下载的分集";
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
    rightBarButton.hidden = YES;
    
    NSArray *headBtnArray = [NSArray arrayWithObjects:@"tv_download-test",@"tv_download-test",@"tv_download-test",@"tv_download-test",@"tv_download-test", nil];

    TVDetailArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15"];
    [self headScrollviewAddBtnFromArray:headBtnArray andBtnWidth:60];
    int count = 5,width = 50;
    if(IS_IPHONE_6_SCREEN||IS_IPHONE_6p_SCREEN){
        count = 6; width = 50;
    }
    [self addTVDetailEveryEpisodeViewFromArray:TVDetailArray andEveryTVViewWidth:width andEveryRowHaveTVViewCount:count];
}

//添加集数的按钮
- (void)headScrollviewAddBtnFromArray:(NSArray *)btnArray andBtnWidth:(CGFloat)width{

    if ((btnArray.count*width+(btnArray.count+1)*17)>[UtilityFunc shareInstance].globleWidth) {
        self.headScrollView.contentSize = CGSizeMake((btnArray.count*width+(btnArray.count+1)*17), self.headScrollView.frame.size.height);
    }
    for (int i=0;i<btnArray.count;i++){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundImage:[UIImage imageNamed:[btnArray objectAtIndex:i]] forState:UIControlStateNormal];
        button.tag = i+1;
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitle:@"1-15集" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(headSCrollViewBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(i*width+17*(i+1), (self.headScrollView.frame.size.height-30)/2, width, 30);
        [self.headScrollView addSubview:button];
    }
}

- (void)headSCrollViewBtnClick:(UIButton *)sender{
    NSLog(@"sender.tag:%d",sender.tag);
}

- (void)addTVDetailEveryEpisodeViewFromArray:(NSArray *)dataArray andEveryTVViewWidth:(CGFloat)width andEveryRowHaveTVViewCount:(int)count{
    
    float column = 0;
    if(dataArray.count%count==0)
        column = dataArray.count/count;
    else
        column = dataArray.count/count+1;
    float spacing = ([UtilityFunc shareInstance].globleWidth-count*width)/(count+1);
    
    if ((column*width+(column+1)*spacing)>self.contentScrollView.frame.size.height) {
        self.contentScrollView.contentSize = CGSizeMake([UtilityFunc shareInstance].globleWidth, (column*width+(column+1)*spacing));
    }
    for(int i=0;i<dataArray.count;i++){
        RMTVDownView *downView = [[[NSBundle mainBundle] loadNibNamed:@"RMTVDownView" owner:self options:nil] lastObject];
        downView.frame = CGRectMake((i%count+1)*spacing+i%count*width, (i/count+1)*spacing+i/count*width, width, width);
        downView.TVEpisodeButton.tag = i+1;
        downView.tag = i+1000;
        [downView.TVEpisodeButton setTitle:[NSString stringWithFormat:@"%d",i+1] forState:UIControlStateNormal];
//        downView.TVStateImageView.image = [UIImage imageNamed:@"tv_downing"];
        [downView.TVEpisodeButton addTarget:self action:@selector(TVEpisodeButtonCLick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentScrollView addSubview:downView];
    }
}

//点击下载某一个集
- (void)TVEpisodeButtonCLick:(UIButton*)sender{
    NSLog(@"sender.tag:%d",sender.tag);
    RMTVDownView *downView = (RMTVDownView *)[self.contentScrollView viewWithTag:sender.tag-1+1000];
    downView.TVStateImageView.image = [UIImage imageNamed:@"tv_downing"];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//下载多有的电视剧
- (IBAction)downAllTVEpisode:(UIButton *)sender {
    for (int i=0;i<TVDetailArray.count;i++){
        RMTVDownView *downView = (RMTVDownView *)[self.contentScrollView viewWithTag:i+1000];
        downView.TVStateImageView.image = [UIImage imageNamed:@"tv_downing"];
    }
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
}

@end

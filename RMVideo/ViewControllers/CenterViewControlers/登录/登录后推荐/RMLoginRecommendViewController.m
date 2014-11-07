//
//  RMLoginRecommendViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-20.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMLoginRecommendViewController.h"
#import "RMAddRecommendView.h"

@interface RMLoginRecommendViewController ()<UIScrollViewDelegate>

@end

@implementation RMLoginRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"你可能喜欢的内容"];
    
    leftBarButton.hidden = YES;
    [rightBarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBarButton.frame = CGRectMake(0, 0, 60, 30);
    rightBarButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [rightBarButton setTitle:@"完成" forState:UIControlStateNormal];
    
    UIScrollView * bgScrView = [[UIScrollView alloc] init];
    bgScrView.backgroundColor = [UIColor clearColor];
    bgScrView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 44);
    bgScrView.userInteractionEnabled = YES;
    bgScrView.showsVerticalScrollIndicator = YES;
    bgScrView.showsHorizontalScrollIndicator = YES;
    bgScrView.delegate = self;
    bgScrView.backgroundColor = [UIColor clearColor];
    [bgScrView setContentSize:CGSizeMake([UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 43)];
    [self.view addSubview:bgScrView];
    
//    for (int i=0; i<3; i++) {
//        for (int j=0; j<3; j++) {
//            RMAddRecommendView * addRecommendView = [[RMAddRecommendView alloc] initWithFrame:CGRectMake(15 + i*100, 15 + j*60, 90, 30)];
//            addRecommendView.delegate = self;
//            addRecommendView.userInteractionEnabled = YES;
//            [bgScrView addSubview:addRecommendView];
//        }
//    }
    
//TODO:未完成
    
    UILabel * changeTitle = [[UILabel alloc] init];
    changeTitle.frame = CGRectMake(15, 235, 90, 30);
    changeTitle.userInteractionEnabled = YES;
    changeTitle.text = @"换一批";
    changeTitle.font = [UIFont systemFontOfSize:12.0];
    changeTitle.textColor = [UIColor colorWithRed:0.8 green:0.08 blue:0.13 alpha:1];
    changeTitle.textAlignment = NSTextAlignmentCenter;
    changeTitle.backgroundColor = [UIColor clearColor];
    [bgScrView addSubview:changeTitle];
    
    UIButton * changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    changeBtn.tag = 101;
    changeBtn.frame = CGRectMake(15, 235, 90, 30);
    [changeBtn setBackgroundImage:LOADIMAGE(@"re_redFrame", kImageTypePNG) forState:UIControlStateNormal];
    [changeBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgScrView addSubview:changeBtn];
    
    UIButton * customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    customBtn.frame = CGRectMake(120, 235, 90, 30);
    [customBtn setBackgroundImage:LOADIMAGE(@"re_redFrame", kImageTypePNG) forState:UIControlStateNormal];
    [customBtn addTarget:self action:@selector(mbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    customBtn.tag = 102;
    [bgScrView addSubview:customBtn];
}

- (void)mbuttonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 101:{
            NSLog(@"换一批");
            break;
        }
        case 102:{
            NSLog(@"自定义");
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - AddRecommendDelegate

- (void)startAddDidSelectWithIndex:(NSInteger)index {
    NSLog(@"登录后 添加");
}

#pragma mark - Base Method

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender {
    switch (sender.tag) {
        case 1:{
            
            break;
        }
        case 2:{
            [self dismissViewControllerAnimated:YES completion:^{
                
                
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kAppearTabbar object:nil];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

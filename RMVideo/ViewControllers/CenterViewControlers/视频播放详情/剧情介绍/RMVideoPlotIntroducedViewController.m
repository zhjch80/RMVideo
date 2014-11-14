//
//  RMVideoPlotIntroducedViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMVideoPlotIntroducedViewController.h"

@interface RMVideoPlotIntroducedViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView * bgScrView;
@property (nonatomic, strong) UILabel * introduce;

@end

@implementation RMVideoPlotIntroducedViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_StarDetail_PlotIntroduce" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_StarDetail_PlotIntroduce" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.bgScrView = [[UIScrollView alloc] init];
    self.bgScrView.backgroundColor = [UIColor clearColor];
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN) {
        self.bgScrView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 205 - 84);
    }else if (IS_IPHONE_6_SCREEN){
        self.bgScrView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 295);
    }else if (IS_IPHONE_6p_SCREEN){
        self.bgScrView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 267 - 84);
    }
    self.bgScrView.showsVerticalScrollIndicator = YES;
    self.bgScrView.showsHorizontalScrollIndicator = YES;
    self.bgScrView.delegate = self;
    [self.view addSubview:self.bgScrView];
    
    self.introduce = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, [UtilityFunc shareInstance].globleWidth -20, 0)];
    self.introduce.numberOfLines = 0;
    self.introduce.font = [UIFont systemFontOfSize:14.0];
    self.introduce.backgroundColor = [UIColor clearColor];
    [self.bgScrView addSubview:self.introduce];
}

#pragma mark - 刷新界面

- (void)updatePlotIntroduced:(RMPublicModel *)model {
    if (model.content.length == 0){
        [self showUnderEmptyViewWithImage:LOADIMAGE(@"no_cashe_video", kImageTypePNG) WithTitle:@"暂无剧情介绍" WithHeight:([UtilityFunc shareInstance].globleHeight-154)/2 - 77-90];
        return;
    }else{
        [self isShouldSetHiddenUnderEmptyView:YES];
    }
    // 设置字体间每行的间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineHeightMultiple = 15.0f;
//    paragraphStyle.maximumLineHeight = 15.0f;
//    paragraphStyle.minimumLineHeight = 15.0f;
    paragraphStyle.lineSpacing = 10.0f;// 行间距
    NSDictionary *ats = @{
                          NSParagraphStyleAttributeName : paragraphStyle,
                          };
    self.introduce.attributedText = [[NSAttributedString alloc] initWithString:model.content attributes:ats];
    
    [self.introduce sizeToFit];
    
    CGRect introFrame =self.introduce.frame;
    introFrame.size.width = [UtilityFunc shareInstance].globleWidth - 20;
    self.introduce.frame = introFrame;
    [self.bgScrView setContentSize:CGSizeMake([UtilityFunc shareInstance].globleWidth, self.introduce.frame.size.height + 20)];
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

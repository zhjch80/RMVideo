//
//  RMVideoPlotIntroducedViewController.m
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMVideoPlotIntroducedViewController.h"

@interface RMVideoPlotIntroducedViewController ()<UIScrollViewDelegate>

@end

@implementation RMVideoPlotIntroducedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSString * str = @"杨桃是一家四星级酒店的大堂经理，由于在感情中受过伤，三十岁的她依然单身一人。三十三岁的果然在婚姻登记处做离婚登记办事员，父母婚姻的阴影使他成为典型恐婚族。在朋友的撮合下，桃子和果然很不情愿地见了面。没想到，俩人竟然都对彼此留下好感。关闭已久的心门刚刚打开，桃子却发现果然是恐婚男，她愤然撤离。桃子面对现实，毅然投入到相亲大军中。桃子的相亲举动刺激了果然，他使出浑身解数，成功地将桃子的相亲一次次搅黄，自己却还是下不了结婚的决心。果然的父母知道了儿子恐婚的原因，开始反省他们的婚姻，果然也对婚姻有了新的认识。而桃子经过跟果然的几番交道后对果然有了全面的了解，重新树立起对婚姻的信心。最后有情人终成眷属。杨桃是一家四星级酒店的大堂经理，由于在感情中受过伤，三十岁的她依然单身一人。三十三岁的果然在婚姻登记处做离婚登记办事员，父母婚姻的阴影使他成为典型恐婚族。在朋友的撮合下，桃子和果然很不情愿地见了面。没想到，俩人竟然都对彼此留下好感。关闭已久的心门刚刚打开，桃子却发现果然是恐婚男，她愤然撤离。桃子面对现实，毅然投入到相亲大军中。桃子的相亲举动刺激了果然，他使出浑身解数，成功地将桃子的相亲一次次搅黄，自己却还是下不了结婚的决心。果然的父母知道了儿子恐婚的原因，开始反省他们的婚姻，果然也对婚姻有了新的认识。而桃子经过跟果然的几番交道后对果然有了全面的了解，重新树立起对婚姻的信心。最后有情人终成眷属。";

    CGFloat height = [UtilityFunc boundingRectWithSize:CGSizeMake([UtilityFunc shareInstance].globleWidth - 20, 0) font:[UIFont systemFontOfSize:14.0] text:str].height;

    UIScrollView * bgScrView = [[UIScrollView alloc] init];
    bgScrView.backgroundColor = [UIColor clearColor];
    if (IS_IPHONE_4_SCREEN | IS_IPHONE_5_SCREEN) {
        bgScrView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 205 - 84);
    }else if (IS_IPHONE_6_SCREEN){
        
    }else if (IS_IPHONE_6p_SCREEN){
        bgScrView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, [UtilityFunc shareInstance].globleHeight - 267 - 84);
    }
    bgScrView.showsVerticalScrollIndicator = YES;
    bgScrView.showsHorizontalScrollIndicator = YES;
    bgScrView.delegate = self;
    [bgScrView setContentSize:CGSizeMake([UtilityFunc shareInstance].globleWidth, height + 260)];
    [self.view addSubview:bgScrView];
    
    UILabel * introduce = [[UILabel alloc] init];
    introduce.frame = CGRectMake(10, 10, [UtilityFunc shareInstance].globleWidth - 20, height + 240);
    introduce.numberOfLines = 0;
    introduce.font = [UIFont systemFontOfSize:14.0];
    introduce.backgroundColor = [UIColor clearColor];
    [bgScrView addSubview:introduce];
    
    // 设置字体间每行的间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 15.0f;
    paragraphStyle.maximumLineHeight = 15.0f;
    paragraphStyle.minimumLineHeight = 15.0f;
    paragraphStyle.lineSpacing = 10.0f;// 行间距
    NSDictionary *ats = @{
                          NSParagraphStyleAttributeName : paragraphStyle,
                          };
    introduce.attributedText = [[NSAttributedString alloc] initWithString:str attributes:ats];

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

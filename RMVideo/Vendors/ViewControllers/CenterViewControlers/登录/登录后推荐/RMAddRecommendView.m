//
//  RMAddRecommendView.m
//  RMVideo
//
//  Created by runmobile on 14-10-20.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMAddRecommendView.h"
#import "UIButton+EnlargeEdge.h"

@implementation RMAddRecommendView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    UIImageView * imgageView = [[UIImageView alloc] init];
    imgageView.frame = CGRectMake(0, 0, 90, 30);
    imgageView.image = LOADIMAGE(@"re_blackFrame", kImageTypePNG);
    imgageView.backgroundColor = [UIColor clearColor];
    imgageView.userInteractionEnabled = YES;
    [self addSubview:imgageView];
    
    UILabel * title = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 90, 30)];
    title.textAlignment = NSTextAlignmentLeft;
    title.backgroundColor = [UIColor clearColor];
    title.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    title.font = [UIFont systemFontOfSize:12.0];
    title.text = @"射手座必看";
    [self addSubview:title];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(68, 7.5, 15, 15);
    [button setBackgroundImage:LOADIMAGE(@"mx_add_img", kImageTypePNG) forState:UIControlStateNormal];
    [button setEnlargeEdgeWithTop:15 right:15 bottom:15 left:15];
    [button addTarget:self action:@selector(addbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}

- (void)addbuttonClick:(UIButton *)sender {
    [self.delegate startAddDidSelectWithIndex:1];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

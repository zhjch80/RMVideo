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
    
    self.tagTitle = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 90, 30)];
    self.tagTitle.textAlignment = NSTextAlignmentLeft;
    self.tagTitle.backgroundColor = [UIColor clearColor];
    self.tagTitle.textColor = [UIColor colorWithRed:0.42 green:0.42 blue:0.42 alpha:1];
    self.tagTitle.numberOfLines = 1;
    self.tagTitle.backgroundColor = [UIColor redColor];
    self.tagTitle.font = [UIFont systemFontOfSize:12.0];
    self.tagTitle.text = @"";
    [self addSubview:self.tagTitle];
    
    self.tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.tagBtn.frame = CGRectMake(68, 7.5, 15, 15);
    [self.tagBtn setBackgroundImage:LOADIMAGE(@"mx_add_img", kImageTypePNG) forState:UIControlStateNormal];
    [self.tagBtn setEnlargeEdgeWithTop:15 right:15 bottom:15 left:15];
    [self.tagBtn addTarget:self action:@selector(addbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.tagBtn];
}

- (void)addbuttonClick:(UIButton *)sender {
    [self.delegate startAddDidSelectWithIndex:sender.tag];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

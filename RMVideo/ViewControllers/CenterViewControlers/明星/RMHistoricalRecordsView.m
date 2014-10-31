//
//  RMHistoricalRecordsView.m
//  RMVideo
//
//  Created by runmobile on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMHistoricalRecordsView.h"
#import "UtilityFunc.h"

@implementation RMHistoricalRecordsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    UILabel * title = [[UILabel alloc] init];
    title.frame = CGRectMake(5, 5, [UtilityFunc shareInstance].globleWidth, 30);
    title.text = @"清空历史记录";
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:title];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  RMEmptyCellView.m
//  RMVideo
//
//  Created by runmobile on 14-11-21.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMEmptyCellView.h"

@implementation RMEmptyCellView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showEmptyView {
    UILabel * title = [[UILabel alloc] init];
    title.text = @"暂无视频";
    title.frame = CGRectMake((self.frame.size.width - 154)/2, 50, 154, 154);
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:16.0];
    title.backgroundColor = [UIColor clearColor];
    [self addSubview:title];
//    UIImageView * image = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 154)/2, 50, 154, 154)];
//    image.image = [UIImage imageNamed:@"no_cashe_video"];
//    image.backgroundColor = [UIColor clearColor];
//    [self addSubview:image];
}

@end

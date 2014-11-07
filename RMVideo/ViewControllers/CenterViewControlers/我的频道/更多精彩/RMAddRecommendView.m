//
//  RMAddRecommendView.m
//  RMVideo
//
//  Created by runmobile on 14-10-20.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMAddRecommendView.h"

@implementation RMAddRecommendView

- (void)loadViewWithTitle:(NSString *)title {
    UILabel * tagTitle;
    tagTitle = [[UILabel alloc] initWithFrame:CGRectMake(6, 0, 90, 30)];
    tagTitle.textAlignment = NSTextAlignmentLeft;
    tagTitle.userInteractionEnabled = YES;
    tagTitle.backgroundColor = [UIColor clearColor];
    tagTitle.textColor = [UIColor colorWithRed:arc4random_uniform(100)/100. green:arc4random_uniform(100)/100. blue:arc4random_uniform(100)/100. alpha:1];
    tagTitle.numberOfLines = 2;
    tagTitle.adjustsFontSizeToFitWidth = YES;
    tagTitle.backgroundColor = [UIColor clearColor];
    tagTitle.font = [UIFont systemFontOfSize:12.0];
    tagTitle.text = title;
    tagTitle.layer.masksToBounds=YES;
    tagTitle.layer.cornerRadius=3;
    [self addSubview:tagTitle];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  RMHistoricalRecordsView.m
//  RMVideo
//
//  Created by runmobile on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMHistoricalRecordsView.h"
#import "UtilityFunc.h"

@interface RMHistoricalRecordsView (){
    UILabel * disTitle;
}

@end
@implementation RMHistoricalRecordsView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}

- (void)initView {
    disTitle = [[UILabel alloc] init];
    disTitle.frame = CGRectMake(10, 5, [UtilityFunc shareInstance].globleWidth, 30);
    disTitle.backgroundColor = [UIColor clearColor];
    disTitle.font = [UIFont systemFontOfSize:14.0];
    [self addSubview:disTitle];
}

- (void)updateDisplayTitle:(NSString *)displayTitle {
    disTitle.text = displayTitle;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

//
//  RMSearchCell.m
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMSearchResultCell.h"

@implementation RMSearchResultCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)DirectBroadcastClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(DirectBroadcastMethodWithValue:)]){
        [self.delegate DirectBroadcastMethodWithValue:sender.tag];
    }
}

@end

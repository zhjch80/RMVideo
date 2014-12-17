//
//  RMDailyListTableViewCell.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDailyListTableViewCell.h"

@implementation RMDailyListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clickPlayBtn:(UIButton *)sender {
    if([self.delegate respondsToSelector:@selector(palyMovieWithIndex:)]){
        [self.delegate palyMovieWithIndex:sender.tag];
    }
}
@end

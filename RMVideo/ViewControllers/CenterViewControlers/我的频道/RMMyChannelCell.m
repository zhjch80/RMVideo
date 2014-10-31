//
//  RMMyChannelCell.m
//  RMVideo
//
//  Created by runmobile on 14-10-14.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMMyChannelCell.h"

@implementation RMMyChannelCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cellbuttonClick:(UIButton *)sender {
    [self.delegate startCellDidSelectWithIndex:1];
    
}
@end

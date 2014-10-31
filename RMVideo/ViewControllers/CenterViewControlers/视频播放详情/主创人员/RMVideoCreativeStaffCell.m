//
//  RMVideoCreativeStaffCell.m
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMVideoCreativeStaffCell.h"

@implementation RMVideoCreativeStaffCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cbuttonClick:(UIButton *)sender {
    [self.delegate startCellDidSelectWithIndex:1];
    
}
@end

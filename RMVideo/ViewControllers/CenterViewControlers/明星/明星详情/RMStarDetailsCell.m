//
//  RMStarDetailsCell.m
//  RMVideo
//
//  Created by runmobile on 14-10-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMStarDetailsCell.h"

@implementation RMStarDetailsCell

- (void)awakeFromNib {
    // Initialization code
    [self.fristImage addTarget:self WithSelector:@selector(cellImageClick:)];
    [self.secondImage addTarget:self WithSelector:@selector(cellImageClick:)];
    [self.threeImage addTarget:self WithSelector:@selector(cellImageClick:)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cellImageClick:(RMImageView *)image {
    [self.delegate startDetailsCellDidSelectWithImage:image];
}
@end

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
    [self.videoFirstImg addTarget:self WithSelector:@selector(videoImageClick:)];
    [self.videoSecondImg addTarget:self WithSelector:@selector(videoImageClick:)];
    [self.videoThirdImg addTarget:self WithSelector:@selector(videoImageClick:)];
}

- (void)showEmptyView {
    RMEmptyCellView * emptyView = [[RMEmptyCellView alloc] initWithFrame:self.frame];
    emptyView.userInteractionEnabled = YES;
    emptyView.backgroundColor = [UIColor clearColor];
    [emptyView showEmptyView];
    [self.contentView addSubview:emptyView];
}

- (void)videoImageClick:(RMImageView *)imageView {
    if ([self.delegate respondsToSelector:@selector(clickVideoImageViewMehtod:)]) {
        [self.delegate clickVideoImageViewMehtod:imageView];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)cellbuttonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(startCellDidSelectWithIndex:)]){
        [self.delegate startCellDidSelectWithIndex:sender.tag];
    }
}
@end

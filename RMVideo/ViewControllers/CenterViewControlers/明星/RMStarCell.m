//
//  RMStarCell.m
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMStarCell.h"

@implementation RMStarCell

- (void)awakeFromNib {
    // Initialization code
    
    [self.starLeftImg addTarget:self WithSelector:@selector(videoImageClick:)];
    [self.starCenterImg addTarget:self WithSelector:@selector(videoImageClick:)];
    [self.starRightImg addTarget:self WithSelector:@selector(videoImageClick:)];

    [self.starAddLeftImg addTarget:self WithSelector:@selector(addVideoStarImageClick:)];
    [self.starAddCenterImg addTarget:self WithSelector:@selector(addVideoStarImageClick:)];
    [self.starAddRightImg addTarget:self WithSelector:@selector(addVideoStarImageClick:)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)videoImageClick:(RMImageView *)imageView {
    if ([self.delegate respondsToSelector:@selector(clickVideoImageViewMehtod:)]) {
        [self.delegate clickVideoImageViewMehtod:imageView];
    }
}

- (void)addVideoStarImageClick:(RMImageView *)imageView {
    if ([self.delegate respondsToSelector:@selector(clickAddMyChannelMethod:)]) {
        [self.delegate clickAddMyChannelMethod:imageView];
    }
}

- (void)setImageWithImage:(UIImage *)image IdentifierString:(NSString *)tag AddMyChannel:(BOOL)isAdd {
    if ([self.starAddLeftImg.identifierString isEqualToString:tag]){
        self.starAddLeftImg.image = image;
        self.starAddLeftImg.isAttentionStarState = isAdd;
    }else if ([self.starAddCenterImg.identifierString isEqualToString:tag]){
        self.starAddCenterImg.image = image;
        self.starAddCenterImg.isAttentionStarState = isAdd;
    }else if ([self.starAddRightImg.identifierString isEqualToString:tag]){
        self.starAddRightImg.image = image;
        self.starAddRightImg.isAttentionStarState = isAdd;
    }
}

@end

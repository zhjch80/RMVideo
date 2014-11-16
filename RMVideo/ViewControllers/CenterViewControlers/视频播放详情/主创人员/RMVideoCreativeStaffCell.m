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
    [self.leftAddImg addTarget:self WithSelector:@selector(starHeadClick:)];
    [self.centerAddImg addTarget:self WithSelector:@selector(starHeadClick:)];
    [self.rightAddImg addTarget:self WithSelector:@selector(starHeadClick:)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)starHeadClick:(RMImageView *)imageView {
    [self.delegate clickCreativeStaffCellAddMyChannelMethod:imageView];
}

- (void)setImageWithImage:(UIImage *)image IdentifierString:(NSString *)tag AddMyChannel:(BOOL)isAdd {
    if ([self.leftAddImg.identifierString isEqualToString:tag]){
        self.leftAddImg.image = image;
        self.leftAddImg.isAttentionStarState = isAdd;
    }else if ([self.centerAddImg.identifierString isEqualToString:tag]){
        self.centerAddImg.image = image;
        self.centerAddImg.isAttentionStarState = isAdd;
    }else if ([self.rightAddImg.identifierString isEqualToString:tag]){
        self.rightAddImg.image = image;
        self.rightAddImg.isAttentionStarState = isAdd;
    }
}

@end

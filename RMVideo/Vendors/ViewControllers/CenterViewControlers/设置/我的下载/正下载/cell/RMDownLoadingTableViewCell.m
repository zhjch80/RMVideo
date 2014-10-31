//
//  RMDownLoadingTableViewCell.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDownLoadingTableViewCell.h"
#import "CONST.h"
#import "UtilityFunc.h"

@implementation RMDownLoadingTableViewCell

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginAnimation) name:kDownLoadingControStartEditing object:nil];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(endAnimation) name:kDownLoadingControEndEditing object:nil];
    int spaceing = 0;
    if(IS_IPHONE_6_SCREEN){
        spaceing = 50;
    }
    else if (IS_IPHONE_6p_SCREEN){
        spaceing = 90;
    }
    self.downLoadProgress.frame = CGRectMake(self.downLoadProgress.frame.origin.x, self.downLoadProgress.frame.origin.y, self.downLoadProgress.frame.size.width+spaceing, self.downLoadProgress.frame.size.height);
    self.showDownLoading.frame = CGRectMake(self.showDownLoading.frame.origin.x+spaceing, self.showDownLoading.frame.origin.y, self.showDownLoading.frame.size.width, self.showDownLoading.frame.size.height);
}
- (void)setCellViewOfFrame{
    self.headImage.frame = CGRectMake(self.headImage.frame.origin.x+30, self.headImage.frame.origin.y, self.headImage.frame.size.width, self.headImage.frame.size.height);
    self.titleLable.frame = CGRectMake(self.titleLable.frame.origin.x+30, self.titleLable.frame.origin.y, self.titleLable.frame.size.width, self.titleLable.frame.size.height);
    self.editingImageView.frame = CGRectMake(self.editingImageView.frame.origin.x+35, self.editingImageView.frame.origin.y, self.editingImageView.frame.size.width, self.editingImageView.frame.size.height);
    self.showDownLoadingState.frame = CGRectMake(self.showDownLoadingState.frame.origin.x+30, self.showDownLoadingState.frame.origin.y, self.showDownLoadingState.frame.size.width, self.showDownLoadingState.frame.size.height);
    self.downLoadProgress.frame = CGRectMake(self.downLoadProgress.frame.origin.x+30, self.downLoadProgress.frame.origin.y, self.downLoadProgress.frame.size.width-30, self.downLoadProgress.frame.size.height);
}
- (void)beginAnimation{
    __weak RMDownLoadingTableViewCell *weekSelf = self;
    [UIView animateWithDuration:.5f animations:^{
        weekSelf.headImage.frame = CGRectMake(weekSelf.headImage.frame.origin.x+30, weekSelf.headImage.frame.origin.y, weekSelf.headImage.frame.size.width, weekSelf.headImage.frame.size.height);
        weekSelf.titleLable.frame = CGRectMake(weekSelf.titleLable.frame.origin.x+30, weekSelf.titleLable.frame.origin.y, weekSelf.titleLable.frame.size.width, weekSelf.titleLable.frame.size.height);
        weekSelf.editingImageView.frame = CGRectMake(weekSelf.editingImageView.frame.origin.x+35, weekSelf.editingImageView.frame.origin.y, weekSelf.editingImageView.frame.size.width, weekSelf.editingImageView.frame.size.height);
        weekSelf.showDownLoadingState.frame = CGRectMake(weekSelf.showDownLoadingState.frame.origin.x+30, weekSelf.showDownLoadingState.frame.origin.y, weekSelf.showDownLoadingState.frame.size.width, weekSelf.showDownLoadingState.frame.size.height);
        weekSelf.downLoadProgress.frame = CGRectMake(weekSelf.downLoadProgress.frame.origin.x+30, weekSelf.downLoadProgress.frame.origin.y, weekSelf.downLoadProgress.frame.size.width-30, weekSelf.downLoadProgress.frame.size.height);
    }];
}

- (void)endAnimation{
    __weak RMDownLoadingTableViewCell *weekSelf = self;
    [UIView animateWithDuration:.5f animations:^{
        weekSelf.headImage.frame = CGRectMake(weekSelf.headImage.frame.origin.x-30, weekSelf.headImage.frame.origin.y, weekSelf.headImage.frame.size.width, weekSelf.headImage.frame.size.height);
        weekSelf.titleLable.frame = CGRectMake(weekSelf.titleLable.frame.origin.x-30, weekSelf.titleLable.frame.origin.y, weekSelf.titleLable.frame.size.width, weekSelf.titleLable.frame.size.height);
        weekSelf.editingImageView.frame = CGRectMake(weekSelf.editingImageView.frame.origin.x-35, weekSelf.editingImageView.frame.origin.y, weekSelf.editingImageView.frame.size.width, weekSelf.editingImageView.frame.size.height);
        weekSelf.showDownLoadingState.frame = CGRectMake(weekSelf.showDownLoadingState.frame.origin.x-30, weekSelf.showDownLoadingState.frame.origin.y, weekSelf.showDownLoadingState.frame.size.width, weekSelf.showDownLoadingState.frame.size.height);
        weekSelf.downLoadProgress.frame = CGRectMake(weekSelf.downLoadProgress.frame.origin.x-30, weekSelf.downLoadProgress.frame.origin.y, weekSelf.downLoadProgress.frame.size.width+30, weekSelf.downLoadProgress.frame.size.height);
    }];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

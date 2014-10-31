//
//  RMFinishDownTableViewCell.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMFinishDownTableViewCell.h"
#import "UtilityFunc.h"
#import "CONST.h"

@implementation RMFinishDownTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginAnimation) name:kFinishViewControStartEditing object:nil];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(endAnimation) name:kFinishViewControEndEditing object:nil];
    self.memoryCount.frame = CGRectMake([UtilityFunc shareInstance].globleWidth - self.memoryCount.frame.size.width-10, self.memoryCount.frame.origin.y, self.memoryCount.frame.size.width, self.memoryCount.frame.size.height);

}
- (void)setCellViewFrame{
    self.headImage.frame = CGRectMake(self.headImage.frame.origin.x+30, self.headImage.frame.origin.y, self.headImage.frame.size.width, self.headImage.frame.size.height);
    self.movieName.frame = CGRectMake(self.movieName.frame.origin.x+30, self.movieName.frame.origin.y, self.movieName.frame.size.width, self.movieName.frame.size.height);
    self.editingImage.frame = CGRectMake(self.editingImage.frame.origin.x+35, self.editingImage.frame.origin.y, self.editingImage.frame.size.width, self.editingImage.frame.size.height);
    self.movieCount.frame = CGRectMake(self.movieCount.frame.origin.x+30, self.movieCount.frame.origin.y, self.movieCount.frame.size.width, self.movieCount.frame.size.height);
}
- (void)beginAnimation{
    __weak RMFinishDownTableViewCell *weekSelf = self;
    [UIView animateWithDuration:.3f animations:^{
        //动画飘出来
        weekSelf.headImage.frame = CGRectMake(weekSelf.headImage.frame.origin.x+30, weekSelf.headImage.frame.origin.y, weekSelf.headImage.frame.size.width, weekSelf.headImage.frame.size.height);
        weekSelf.movieName.frame = CGRectMake(weekSelf.movieName.frame.origin.x+30, weekSelf.movieName.frame.origin.y, weekSelf.movieName.frame.size.width, weekSelf.movieName.frame.size.height);
        weekSelf.editingImage.frame = CGRectMake(weekSelf.editingImage.frame.origin.x+35, weekSelf.editingImage.frame.origin.y, weekSelf.editingImage.frame.size.width, weekSelf.editingImage.frame.size.height);
        weekSelf.movieCount.frame = CGRectMake(weekSelf.movieCount.frame.origin.x+30, weekSelf.movieCount.frame.origin.y, weekSelf.movieCount.frame.size.width, weekSelf.movieCount.frame.size.height);
    }];
}

- (void)endAnimation{
    __weak RMFinishDownTableViewCell *weekSelf = self;
    [UIView animateWithDuration:.3f animations:^{
        //动画关闭
        //动画飘出来
        weekSelf.headImage.frame = CGRectMake(weekSelf.headImage.frame.origin.x-30, weekSelf.headImage.frame.origin.y, weekSelf.headImage.frame.size.width, weekSelf.headImage.frame.size.height);
        weekSelf.movieName.frame = CGRectMake(weekSelf.movieName.frame.origin.x-30, weekSelf.movieName.frame.origin.y, weekSelf.movieName.frame.size.width, weekSelf.movieName.frame.size.height);
        weekSelf.editingImage.frame = CGRectMake(weekSelf.editingImage.frame.origin.x-35, weekSelf.editingImage.frame.origin.y, weekSelf.editingImage.frame.size.width, weekSelf.editingImage.frame.size.height);
        weekSelf.movieCount.frame = CGRectMake(weekSelf.movieCount.frame.origin.x-30, weekSelf.movieCount.frame.origin.y, weekSelf.movieCount.frame.size.width, weekSelf.movieCount.frame.size.height);
    }];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}
@end

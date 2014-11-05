//
//  RMStarCell.h
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMImageView.h"

@protocol StarCellDelegate <NSObject>

- (void)clickAddMyChannelMethod:(RMImageView *)imageView;

- (void)clickVideoImageViewMehtod:(RMImageView *)imageView;

@end
@interface RMStarCell : UITableViewCell

@property (assign ,nonatomic) id<StarCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet RMImageView *starLeftImg;
@property (weak, nonatomic) IBOutlet RMImageView *starCenterImg;
@property (weak, nonatomic) IBOutlet RMImageView *starRightImg;

@property (weak, nonatomic) IBOutlet RMImageView *starAddLeftImg;
@property (weak, nonatomic) IBOutlet RMImageView *starAddCenterImg;
@property (weak, nonatomic) IBOutlet RMImageView *starAddRightImg;

@property (weak, nonatomic) IBOutlet UILabel *leftTitle;
@property (weak, nonatomic) IBOutlet UILabel *centerTitle;
@property (weak, nonatomic) IBOutlet UILabel *rightTitle;

/**
 *  改变用户对这个明星的关注状态
 */
- (void)setImageWithImage:(UIImage *)image IdentifierString:(NSString *)tag AddMyChannel:(BOOL)isAdd;

@end

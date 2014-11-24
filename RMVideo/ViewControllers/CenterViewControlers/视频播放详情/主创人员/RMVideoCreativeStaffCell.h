//
//  RMVideoCreativeStaffCell.h
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMImageView.h"

@protocol CreativeStaffCellDelegate <NSObject>

- (void)clickCreativeStaffCellAddMyChannelMethod:(RMImageView *)imageView;

- (void)clickStaffHeadImageViewMehtod:(RMImageView *)imageView;

@end
@interface RMVideoCreativeStaffCell : UITableViewCell
@property (assign ,nonatomic) id<CreativeStaffCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *leftRotatView;
@property (weak, nonatomic) IBOutlet UIView *centerRotatView;
@property (weak, nonatomic) IBOutlet UIView *rightRotatView;


@property (weak, nonatomic) IBOutlet RMImageView *leftHeadImg;
@property (weak, nonatomic) IBOutlet RMImageView *centerHeadImg;
@property (weak, nonatomic) IBOutlet RMImageView *rightHeadImg;

@property (weak, nonatomic) IBOutlet RMImageView *leftAddImg;
@property (weak, nonatomic) IBOutlet RMImageView *centerAddImg;
@property (weak, nonatomic) IBOutlet RMImageView *rightAddImg;

@property (weak, nonatomic) IBOutlet UILabel *leftTitle;
@property (weak, nonatomic) IBOutlet UILabel *centerTitle;
@property (weak, nonatomic) IBOutlet UILabel *rightTitle;


@property (weak, nonatomic) IBOutlet UILabel *leftRotatingTitle;
@property (weak, nonatomic) IBOutlet UILabel *centerRotatingTitle;
@property (weak, nonatomic) IBOutlet UILabel *rightRotatingTitle;



- (void)setImageWithImage:(UIImage *)image IdentifierString:(NSString *)tag AddMyChannel:(BOOL)isAdd;



@end

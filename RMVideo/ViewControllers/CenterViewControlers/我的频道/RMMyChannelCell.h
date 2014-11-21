//
//  RMMyChannelCell.h
//  RMVideo
//
//  Created by runmobile on 14-10-14.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"
#import "RMImageView.h"
#import "RMEmptyCellView.h"

@protocol MyChannemMoreWonderfulDelegate <NSObject>

- (void)startCellDidSelectWithIndex:(NSInteger)index;

- (void)clickVideoImageViewMehtod:(RMImageView *)imageView;

@end

@interface RMMyChannelCell : UITableViewCell

@property (assign ,nonatomic) id<MyChannemMoreWonderfulDelegate> delegate;

- (IBAction)cellbuttonClick:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet RatingView *firstMovieRateView;
@property (weak, nonatomic) IBOutlet RatingView *secondMovieRateView;
@property (weak, nonatomic) IBOutlet RatingView *thirdMovieRateView;

@property (weak, nonatomic) IBOutlet UILabel *tag_title;

@property (weak, nonatomic) IBOutlet UIView *title_bgView;

@property (weak, nonatomic) IBOutlet UILabel *videoFirstName;
@property (weak, nonatomic) IBOutlet UILabel *videoSecondName;
@property (weak, nonatomic) IBOutlet UILabel *videoThirdName;

@property (weak, nonatomic) IBOutlet RMImageView *videoFirstImg;
@property (weak, nonatomic) IBOutlet RMImageView *videoSecondImg;
@property (weak, nonatomic) IBOutlet RMImageView *videoThirdImg;

@property (weak, nonatomic) IBOutlet UIButton *moreBtn;

- (void)showEmptyView;

@end

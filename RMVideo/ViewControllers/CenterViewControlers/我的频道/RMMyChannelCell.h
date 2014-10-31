//
//  RMMyChannelCell.h
//  RMVideo
//
//  Created by runmobile on 14-10-14.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@protocol MyChannemMoreWonderfulDelegate <NSObject>

- (void)startCellDidSelectWithIndex:(NSInteger)index;

@end

@interface RMMyChannelCell : UITableViewCell

@property (assign ,nonatomic) id<MyChannemMoreWonderfulDelegate> delegate;

- (IBAction)cellbuttonClick:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet RatingView *firstMovieRateView;

@property (weak, nonatomic) IBOutlet RatingView *secondMovieRateView;

@property (weak, nonatomic) IBOutlet RatingView *thirdMovieRateView;

@end

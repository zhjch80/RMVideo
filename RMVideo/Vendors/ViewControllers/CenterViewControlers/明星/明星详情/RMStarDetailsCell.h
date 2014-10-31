//
//  RMStarDetailsCell.h
//  RMVideo
//
//  Created by runmobile on 14-10-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"

@protocol StarDetailsCellDelegate <NSObject>

- (void)startDetailsCellDidSelectWithIndex:(NSInteger)index;

@end

@interface RMStarDetailsCell : UITableViewCell

@property (assign ,nonatomic) id<StarDetailsCellDelegate> delegate;

- (IBAction)cellbuttonClick:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet RatingView *firstStarRateView;

@property (weak, nonatomic) IBOutlet RatingView *secondStarRateView;

@property (weak, nonatomic) IBOutlet RatingView *thirdStarRateView;

@end

//
//  RMStarDetailsCell.h
//  RMVideo
//
//  Created by runmobile on 14-10-16.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"
#import "RMImageView.h"
#import "DAAutoScrollView.h"

@protocol StarDetailsCellDelegate <NSObject>

- (void)startDetailsCellDidSelectWithImage:(RMImageView *)imageView;

@end

@interface RMStarDetailsCell : UITableViewCell

@property (assign ,nonatomic) id<StarDetailsCellDelegate> delegate;


@property (weak, nonatomic) IBOutlet RMImageView *fristImage;
@property (weak, nonatomic) IBOutlet RMImageView *secondImage;
@property (weak, nonatomic) IBOutlet RMImageView *threeImage;
@property (weak, nonatomic) IBOutlet DAAutoScrollView *fristLable;
@property (weak, nonatomic) IBOutlet DAAutoScrollView *secondLable;
@property (weak, nonatomic) IBOutlet DAAutoScrollView *threeLable;

@property (weak, nonatomic) IBOutlet RatingView *firstStarRateView;

@property (weak, nonatomic) IBOutlet RatingView *secondStarRateView;

@property (weak, nonatomic) IBOutlet RatingView *thirdStarRateView;

@end

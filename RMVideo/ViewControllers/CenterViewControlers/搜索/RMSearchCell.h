//
//  RMSearchCell.h
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"
@protocol SearchCellDelegate <NSObject>

- (void)startCellDidSelectWithIndex:(NSInteger)index;

@end
@interface RMSearchCell : UITableViewCell
@property (assign ,nonatomic) id<SearchCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet RatingView *searchFirstRateView;
@property (weak, nonatomic) IBOutlet RatingView *searchSecondRateView;
@property (weak, nonatomic) IBOutlet RatingView *searchThirdRateView;


- (IBAction)cbuttonClick:(UIButton *)sender;


@end

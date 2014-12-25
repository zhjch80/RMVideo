//
//  RMSearchCell.h
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RatingView.h"
@interface RMSearchResultCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *hits;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet RatingView *searchFirstRateView;

@property (weak, nonatomic) IBOutlet UILabel *type;

@end

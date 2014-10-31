//
//  RMAddRecommendView.h
//  RMVideo
//
//  Created by runmobile on 14-10-20.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CONST.h"

@protocol AddRecommendDelegate <NSObject>

- (void)startAddDidSelectWithIndex:(NSInteger)index;

@end
@interface RMAddRecommendView : UIView
@property (assign ,nonatomic) id<AddRecommendDelegate> delegate;


@property (nonatomic, strong) UILabel * tagTitle;
@property (nonatomic, strong) UIButton * tagBtn;

@end

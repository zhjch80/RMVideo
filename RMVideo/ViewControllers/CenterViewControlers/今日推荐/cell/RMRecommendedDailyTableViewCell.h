//
//  RMRecommendedDailyTableViewCell.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwipeView.h"

@protocol RecommendedDailyTableViewCellDelegate <NSObject>

@optional
- (void)didSelectCellImageWithTag:(NSInteger)tag andImageViewIdentifier:(NSString *)identifier;
- (void)clickDirectlyPlayBtnWithTag:(NSInteger)tag andtypeIdentifier:(NSString *)identifier;

@end
@interface RMRecommendedDailyTableViewCell : UITableViewCell<SwipeViewDelegate, SwipeViewDataSource>{
    NSInteger value;
    NSString *cellImgageIdentifier;
    NSArray *ImageArray;
}
@property (weak, nonatomic) IBOutlet SwipeView *MoviePostersView;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak ,nonatomic) id<RecommendedDailyTableViewCellDelegate> delegate;

- (void)cellAddMovieCountFromDataArray:(NSArray*)movieArray andCellIdentifiersName:(NSString *)identifier;
@end

//
//  RMDailyListTableViewCell.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RMDailyListTableViewCellDelegate <NSObject>
@optional
- (void)palyMovieWithIndex:(NSInteger)index;

@end
@interface RMDailyListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *movieName;
@property (weak, nonatomic) IBOutlet UILabel *movieKind;
@property (weak, nonatomic) IBOutlet UIImageView *TopImage;
@property (weak, nonatomic) IBOutlet UIImageView *ToPromoteImage;
@property (weak, nonatomic) IBOutlet UILabel *playCount;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@property (assign ,nonatomic) id<RMDailyListTableViewCellDelegate> delegate;
- (IBAction)clickPlayBtn:(UIButton *)sender;

@end

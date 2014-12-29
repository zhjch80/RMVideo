//
//  RMFinishDownTableViewCell.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMImageView.h"

@protocol RMFinishDownTableViewCellDelegate <NSObject>
@optional
- (void)palyMovieWithIndex:(NSInteger)index;

@end

@interface RMFinishDownTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet RMImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *movieName;
@property (weak, nonatomic) IBOutlet UILabel *memoryCount;
@property (weak, nonatomic) IBOutlet UIImageView *editingImage;
@property (weak, nonatomic) IBOutlet UILabel *movieCount;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) id<RMFinishDownTableViewCellDelegate> delegate;

- (void)setCellViewFrame;
@end

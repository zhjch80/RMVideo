//
//  RMDownLoadingTableViewCell.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RMDownLoadingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UIProgressView *downLoadProgress;
@property (weak, nonatomic) IBOutlet UILabel *showDownLoading;
@property (weak, nonatomic) IBOutlet UILabel *showDownLoadingState;
@property (weak, nonatomic) IBOutlet UIImageView *editingImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLable;

- (void)setCellViewOfFrame;

@end

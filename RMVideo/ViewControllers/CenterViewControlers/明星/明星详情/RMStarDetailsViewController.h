//
//  RMStarDetailsViewController.h
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMBaseViewController.h"
#import "DAAutoScrollView.h"

@interface RMStarDetailsViewController : RMBaseViewController{
    
}
@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIView *headSubView;
@property (weak, nonatomic) IBOutlet UIView *headSubChannelView;

@property (weak, nonatomic) IBOutlet UIImageView *starPhoto;
@property (weak, nonatomic) IBOutlet DAAutoScrollView *starName;
@property (weak, nonatomic) IBOutlet UITextView *starIntrduce;

@property (weak, nonatomic) IBOutlet UILabel *foldMarkTitle;
@property (weak, nonatomic) IBOutlet UIImageView *foldImg;
@property (weak, nonatomic) IBOutlet UIButton *foldBtn;

@property (weak, nonatomic) IBOutlet UIView *contentView;

- (IBAction)mbuttonClick:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UILabel *myChannelState;
@property (weak, nonatomic) IBOutlet UIImageView *myChannelImgState;

/**
 把明星的tag_id传过来
 */
- (void)setStarID:(NSString *)star_id;

@end

//
//  RMVideoPlaybackDetailsViewController.h
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"
#import "RatingView.h"

@interface RMVideoPlaybackDetailsViewController : RMBaseViewController

@property (nonatomic, strong) NSString * tabBarIdentifier;

@property (weak, nonatomic) IBOutlet UIView *videoHeadBGView;

@property (weak, nonatomic) IBOutlet RatingView *videoRateView;
@property (weak, nonatomic) IBOutlet UIImageView *videoImg;
@property (weak, nonatomic) IBOutlet UILabel *videoTitle;
@property (weak, nonatomic) IBOutlet UIImageView *videoPlayImg;
@property (weak, nonatomic) IBOutlet UILabel *videoPlayCount;
@property (weak, nonatomic) IBOutlet UIView *videoUpLine;
@property (weak, nonatomic) IBOutlet UIView *videoDownLine;
@property (weak, nonatomic) IBOutlet UIView *videoLeftLine;
@property (weak, nonatomic) IBOutlet UIView *videoRightLine;
@property (weak, nonatomic) IBOutlet UIButton *videoDownloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoCollectionBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoShareBtn;


- (IBAction)mbuttonClick:(UIButton *)sender;

/**
 * Default NO
 * identifier is YES when navigationController popViewController appear TabBar
 * identifier is NO when navigationController popViewController hide TabBar
 */
- (void)setAppearTabBarNextPopViewController:(NSString *)identifier;

@end

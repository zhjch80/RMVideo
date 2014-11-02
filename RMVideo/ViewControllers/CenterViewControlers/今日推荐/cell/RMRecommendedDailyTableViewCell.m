//
//  RMRecommendedDailyTableViewCell.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMRecommendedDailyTableViewCell.h"
#import "UtilityFunc.h"
#import "RMImageView.h"
#import "CONST.h"
#import "UIImageView+WebCache.h"


@implementation RMRecommendedDailyTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cellAddMovieCountFromDataArray:(NSArray *)movieArray andCellIdentifiersName:(NSString *)identifier{

    
    if (IS_IPHONE_4_SCREEN){
        self.MoviePostersView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 332);
    }else if (IS_IPHONE_5_SCREEN){
        self.MoviePostersView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 375);
        self.headImageView.frame = CGRectMake(50 - 5.5, 10 + 11, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
    }else if (IS_IPHONE_6_SCREEN){
        self.MoviePostersView.frame = CGRectMake(-15, 0, [UtilityFunc shareInstance].globleWidth +15, 460);
        self.headImageView.frame = CGRectMake(43, 20, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
    }else if (IS_IPHONE_6p_SCREEN){
        self.MoviePostersView.frame = CGRectMake(-10.0, 0, [UtilityFunc shareInstance].globleWidth + 10, 520);
        self.headImageView.frame = CGRectMake(33, 10 + 16, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
    }
    
    self.MoviePostersView.alignment = SwipeViewAlignmentCenter;
    self.MoviePostersView.delegate = self;
    self.MoviePostersView.dataSource = self;
    self.MoviePostersView.pagingEnabled = YES;
    self.MoviePostersView.wrapEnabled = NO;
    self.MoviePostersView.itemsPerPage = 1;
    self.MoviePostersView.truncateFinalPage = YES;
    cellImgageIdentifier = identifier;
    if(movieArray.count==0||movieArray==nil){
        [self.MoviePostersView removeFromSuperview];
    }else{
        ImageArray = movieArray;
    }
    [self.MoviePostersView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHeadImgeView) name:@"tableViewWillBeginDragging" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideHeadImageView) name:@"tableViewDidEndDecelerating" object:nil];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return ImageArray.count;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    //    UIView *view = (UIView *)view;
    //    if (view == nil)
    //    {
    view = [[UIView alloc] init];
    RMImageView * subImage = [[RMImageView alloc] init];
    subImage.identifierString = cellImgageIdentifier;
    
    
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[ImageArray objectAtIndex:index]]];
//    if(data==nil){
//        NSLog(@"预备图片");
//    }
//    subImage.image = [UIImage imageWithData:data];
    [subImage sd_setImageWithURL:[NSURL URLWithString:[ImageArray objectAtIndex:index]]];
    
    if(IS_IPHONE_4_SCREEN){
        view.frame = CGRectMake(0.0f, 0.0f, 230.0f, 332);
        subImage.frame = CGRectMake(5, 10, 215, 332-10);
    }
    else if(IS_IPHONE_5_SCREEN){
        view.frame = CGRectMake(0.0f, 0.0f, 250.0f, 372);
        subImage.frame = CGRectMake(10, 20, 225, 375-25);
    }else if (IS_IPHONE_6_SCREEN){
        view.frame = CGRectMake(0.0f, 0.0f, 315, 460);
        subImage.frame = CGRectMake(20, 20, 290, 460-20);
    }else if (IS_IPHONE_6p_SCREEN){
        view.frame = CGRectMake(0.0f, 0.0f, 365.0f, 502);
        subImage.frame = CGRectMake(13, 17, 347, 502-26);
    }
    [view addSubview:subImage];
    //        view = nil;
    //        view = view;
    //    }
    view.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    return view;
}
- (void)swipeViewWillBeginDragging:(SwipeView *)swipeView{
    [self showHeadImgeView];
}
- (void)swipeViewDidEndDecelerating:(SwipeView *)swipeView{
    [self hideHeadImageView];
}
- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView
{
    value = swipeView.currentItemIndex;
}

- (void)swipeView:(SwipeView *)swipeView didSelectItemAtIndex:(NSInteger)index
{
    if (index == value){
        if([self.delegate respondsToSelector:@selector(didSelectCellImageWithTag:andImageViewIdentifier:)]){
            [self.delegate didSelectCellImageWithTag:index andImageViewIdentifier:cellImgageIdentifier];
        }
    }else {
        [_MoviePostersView scrollToItemAtIndex:index duration:0.3];
    }
}
- (void)showHeadImgeView{
    self.headImageView.hidden = YES;
}
- (void)hideHeadImageView{
    self.headImageView.hidden = NO;
}
- (void)selectImageView:(RMImageView *)imageView{
    
}



@end

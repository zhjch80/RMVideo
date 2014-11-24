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
//    self.MoviePostersView.backgroundColor = [UIColor cyanColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)cellAddMovieCountFromDataArray:(NSArray *)movieArray andCellIdentifiersName:(NSString *)identifier{
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
//    ImageArray = [NSMutableArray arrayWithObjects:@"www.baidu.com",@"www.google.com.cn", nil];
    [self.MoviePostersView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHeadImgeView) name:@"tableViewWillBeginDragging" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideHeadImageView) name:@"tableViewDidEndDecelerating" object:nil];
    
    
    if (IS_IPHONE_4_SCREEN){
        if (ImageArray.count == 1){
            self.MoviePostersView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 332);
            self.headImageView.frame = CGRectMake(50 - 5.5, 10, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }else{
            self.MoviePostersView.frame = CGRectMake(-65, 0, [UtilityFunc shareInstance].globleWidth+65, 332);
            self.headImageView.frame = CGRectMake(18 - 5.5, 10, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }
    }else if (IS_IPHONE_5_SCREEN){
        if (ImageArray.count == 1){
            self.MoviePostersView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 375);
            self.headImageView.frame = CGRectMake(50 - 5.5, 11, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }else{
            self.MoviePostersView.frame = CGRectMake(-65, 0, [UtilityFunc shareInstance].globleWidth+65, 375);
            self.headImageView.frame = CGRectMake(18 - 5.5, 11, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }
    }else if (IS_IPHONE_6_SCREEN){
        if (ImageArray.count == 1){
            self.MoviePostersView.frame = CGRectMake(-15, 0, [UtilityFunc shareInstance].globleWidth +15, 460);
            self.headImageView.frame = CGRectMake(32, 10, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }else{
            self.MoviePostersView.frame = CGRectMake(-60, 0, [UtilityFunc shareInstance].globleWidth + 60, 460);
            self.headImageView.frame = CGRectMake(10, 10, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }
    }else if (IS_IPHONE_6p_SCREEN){
        if(ImageArray.count == 1){
            self.MoviePostersView.frame = CGRectMake(-10.0, 0, [UtilityFunc shareInstance].globleWidth + 10, 502);
            self.headImageView.frame = CGRectMake(31, -2 + 15, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }else{
            self.MoviePostersView.frame = CGRectMake(-50, 0, [UtilityFunc shareInstance].globleWidth + 50, 502);
            self.headImageView.frame = CGRectMake(10, 15, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }
    }
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
    subImage.backgroundColor = [UIColor clearColor];
    subImage.contentMode = UIViewContentModeScaleToFill;
    
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[ImageArray objectAtIndex:index]]];
//    if(data==nil){
//        NSLog(@"预备图片");
//    }
//    subImage.image = [UIImage imageWithData:data];
    
    if(IS_IPHONE_4_SCREEN){
        [subImage sd_setImageWithURL:[NSURL URLWithString:[ImageArray objectAtIndex:index]] placeholderImage:LOADIMAGE(@"Default215_322", kImageTypePNG)];
        view.frame = CGRectMake(0.0f, 0.0f, 230.0f, 332);
        subImage.frame = CGRectMake(5, 10, 215, 332-10);
    }
    else if(IS_IPHONE_5_SCREEN){
        [subImage sd_setImageWithURL:[NSURL URLWithString:[ImageArray objectAtIndex:index]] placeholderImage:LOADIMAGE(@"Default240_350", kImageTypePNG)];
        view.frame = CGRectMake(0.0f, 0.0f, 250.0f, 372);
        subImage.frame = CGRectMake(10, 10, 240, 375-25);
    }else if (IS_IPHONE_6_SCREEN){
        [subImage sd_setImageWithURL:[NSURL URLWithString:[ImageArray objectAtIndex:index]] placeholderImage:LOADIMAGE(@"Default300_450", kImageTypePNG)];
        view.frame = CGRectMake(0.0f, 0.0f, 310, 460);
        subImage.frame = CGRectMake(10, 10, 300, 450);
    }else if (IS_IPHONE_6p_SCREEN){
        [subImage sd_setImageWithURL:[NSURL URLWithString:[ImageArray objectAtIndex:index]] placeholderImage:LOADIMAGE(@"Default352_487", kImageTypePNG)];
        view.frame = CGRectMake(0.0f, 0.0f, 365.0f, 502);
        subImage.frame = CGRectMake(13, 15, 352, 502-15);
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

- (void)swipeViewDidScroll:(SwipeView *)swipeView{
    if (ImageArray.count == 1){
        return;
    }
    if (IS_IPHONE_4_SCREEN){
        if (swipeView.currentPage == 0){
            self.MoviePostersView.frame = CGRectMake(-65, 0, [UtilityFunc shareInstance].globleWidth+65, 332);
            self.headImageView.frame = CGRectMake(18 - 5.5, 10, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }
        else if (swipeView.currentPage == ImageArray.count-1){
            [UIView animateWithDuration:0.3 animations:^{
                self.MoviePostersView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth+80, 332);
                self.headImageView.frame = CGRectMake(18+70, 10, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
            }];
        }else{
            self.MoviePostersView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 332);
            self.headImageView.frame = CGRectMake(50 - 5.5, 10, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }
    }else if (IS_IPHONE_5_SCREEN){
        if (swipeView.currentPage == 0){
            [UIView animateWithDuration:0.3 animations:^{
                self.MoviePostersView.frame = CGRectMake(-65, 0, [UtilityFunc shareInstance].globleWidth+65, 375);
                self.headImageView.frame = CGRectMake(18 - 5.5, 11, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
            }];
        }
        else if (swipeView.currentPage == ImageArray.count-1){
            [UIView animateWithDuration:0.3 animations:^{
                self.MoviePostersView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth+45, 375);
                self.headImageView.frame = CGRectMake(18 - 5.5+55, 11, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
            }];
        }
        else{
            [UIView animateWithDuration:0.3 animations:^{
                self.MoviePostersView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth, 375);
                self.headImageView.frame = CGRectMake(50 - 5.5, 11, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
            }];
        }
    }else if (IS_IPHONE_6_SCREEN){
        if (swipeView.currentPage == 0){
            self.MoviePostersView.frame = CGRectMake(-60, 0, [UtilityFunc shareInstance].globleWidth + 60, 460);
            self.headImageView.frame = CGRectMake(10, 10, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }
        else if (swipeView.currentPage == ImageArray.count-1){
            [UIView animateWithDuration:0.3 animations:^{
                self.MoviePostersView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth+45, 460);
                self.headImageView.frame = CGRectMake(18 - 5.5+50, 10, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
            }];
        }else{
            self.MoviePostersView.frame = CGRectMake(-15, 0, [UtilityFunc shareInstance].globleWidth + 15, 460);
            self.headImageView.frame = CGRectMake(32, 10, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }
    }else if (IS_IPHONE_6p_SCREEN){
        if(swipeView.currentPage == 0){
            self.MoviePostersView.frame = CGRectMake(-50, 0, [UtilityFunc shareInstance].globleWidth + 50, 502);
            self.headImageView.frame = CGRectMake(10, 15, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }
        else if (swipeView.currentPage == ImageArray.count-1){
            [UIView animateWithDuration:0.3 animations:^{
                self.MoviePostersView.frame = CGRectMake(0, 0, [UtilityFunc shareInstance].globleWidth+25, 502);
                self.headImageView.frame = CGRectMake(18 +30, 15, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
            }];
        }else{
            self.MoviePostersView.frame = CGRectMake(-10.0, 0, [UtilityFunc shareInstance].globleWidth + 10, 502);
            self.headImageView.frame = CGRectMake(31, -2 + 15, self.headImageView.frame.size.width, self.headImageView.frame.size.height);
        }

    }
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

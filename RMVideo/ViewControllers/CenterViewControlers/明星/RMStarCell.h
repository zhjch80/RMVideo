//
//  RMStarCell.h
//  RMVideo
//
//  Created by runmobile on 14-10-13.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StarCellDelegate <NSObject>

- (void)startCellDidSelectWithIndex:(NSInteger)index;

@end
@interface RMStarCell : UITableViewCell

@property (assign ,nonatomic) id<StarCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *leftBtnView;
@property (weak, nonatomic) IBOutlet UIImageView *centerBtnView;
@property (weak, nonatomic) IBOutlet UIImageView *rightBtnView;

@property (weak, nonatomic) IBOutlet UILabel *leftTitle;
@property (weak, nonatomic) IBOutlet UILabel *centerTitle;
@property (weak, nonatomic) IBOutlet UILabel *rightTitle;

@property (weak, nonatomic) IBOutlet UIButton *leftImg_on_btn;
@property (weak, nonatomic) IBOutlet UIButton *centerImg_on_btn;
@property (weak, nonatomic) IBOutlet UIButton *rightImg_on_btn;

@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *centerBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;


- (IBAction)buttonClick:(id)sender;




@end

//
//  RMVideoCreativeStaffCell.h
//  RMVideo
//
//  Created by runmobile on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreativeStaffCellDelegate <NSObject>

- (void)startCellDidSelectWithIndex:(NSInteger)index;

@end
@interface RMVideoCreativeStaffCell : UITableViewCell
@property (assign ,nonatomic) id<CreativeStaffCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *leftRotatView;
@property (weak, nonatomic) IBOutlet UIView *centerRotatView;
@property (weak, nonatomic) IBOutlet UIView *rightRotatView;


- (IBAction)cbuttonClick:(UIButton *)sender;



@end

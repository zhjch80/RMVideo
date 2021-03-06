//
//  RMVideoPlayHistoryViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMVideoPlayHistoryViewController.h"
#import "RMFinishDownTableViewCell.h"
#import "RMVideoPlaybackDetailsViewController.h"

@interface RMVideoPlayHistoryViewController ()

@end

@implementation RMVideoPlayHistoryViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_Setup_History" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_Setup_History" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isSeleltAllCell = YES;
    [self setTitle:@"播放历史"];
    
    [self showEmptyViewWithImage:[UIImage imageNamed:@"no_play_history"] WithTitle:@"您没有播放记录"];
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
    self.dataArray = [NSMutableArray arrayWithArray:[[Database sharedDatabase] readitemFromListName:PLAYHISTORYLISTNAME]];
    if (self.dataArray.count==0) {
        [self isShouldSetHiddenEmptyView:NO];
        rightBarButton.hidden = YES;
    }else{
        [self isShouldSetHiddenEmptyView:YES];
        rightBarButton.hidden = NO;
    }
    selectCellArray = [NSMutableArray array];
    [showMemoryLable removeFromSuperview];
    cellEditingImageArray = [NSMutableArray array];
    for (int i=0; i<20; i++) {
        [cellEditingImageArray addObject:@"no-select_cellImage"];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)EditingViewBtnClick:(UIButton *)sender{
    if(sender.tag == 10){
        NSLog(@"全选");
        [selectCellArray removeAllObjects];
        if(isSeleltAllCell){
            [sender setImage:LOADIMAGE(@"uncancle_select_all", kImageTypePNG) forState:UIControlStateNormal];
            for(int i=0; i<self.dataArray.count;i++){
                [cellEditingImageArray replaceObjectAtIndex:i withObject:@"select_cellImage"];
                [selectCellArray addObject:[NSNumber numberWithInt:i]];
            }
            ((UIButton *)[btnView viewWithTag:11]).enabled = YES;
            [((UIButton *)[btnView viewWithTag:11]) setImage:LOADIMAGE(@"undelect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
        }
        else{
            [sender setImage:LOADIMAGE(@"unselect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
            for(int i=0; i<self.dataArray.count;i++){
                [cellEditingImageArray replaceObjectAtIndex:i withObject:@"no-select_cellImage"];
            }
            ((UIButton *)[btnView viewWithTag:11]).enabled = NO;
            [((UIButton *)[btnView viewWithTag:11]) setImage:LOADIMAGE(@"nodelect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
        }
        isSeleltAllCell = !isSeleltAllCell;
        [self.mainTableView reloadData];
    }else{
        NSMutableArray *deleteArray = [NSMutableArray array];
        NSArray *sort = [selectCellArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
            return obj1.integerValue<obj2.integerValue;
        }];
        ((UIButton *)[btnView viewWithTag:11]).enabled = NO;
        [((UIButton *)[btnView viewWithTag:11]) setImage:LOADIMAGE(@"nodelect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
        for(int i=0;i<sort.count;i++){
            NSNumber *number = [sort objectAtIndex:i];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:number.integerValue inSection:0];
            [deleteArray addObject:indexPath];
        }
        for(int i=0;i<sort.count;i++){
            NSNumber *number = [sort objectAtIndex:i];
            [cellEditingImageArray removeObjectAtIndex:number.integerValue];
            RMPublicModel *model = [self.dataArray objectAtIndex:number.integerValue];
            [[Database sharedDatabase] deleteItem:model fromListName:PLAYHISTORYLISTNAME];
            [self.dataArray removeObjectAtIndex:number.integerValue];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:number.integerValue inSection:0];
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            [self.mainTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            if (self.dataArray.count==0) {
                [self isShouldSetHiddenEmptyView:NO];
                rightBarButton.hidden = YES;
            }else{
                [self isShouldSetHiddenEmptyView:YES];
                rightBarButton.hidden = NO;
                [self setRightBarBtnItemImageWith:YES];
            }
        }
        [selectCellArray removeAllObjects];
        [UIView animateWithDuration:0.5 animations:^{
            btnView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth, 49);
            self.mainTableView.frame = CGRectMake(self.mainTableView.frame.origin.x, self.mainTableView.frame.origin.y, self.mainTableView.frame.size.width, self.mainTableView.frame.size.height+49);
        }];
        [[NSNotificationCenter defaultCenter ] postNotificationName:kFinishViewControEndEditing object:nil];
        isEditing = NO;
    }
}
- (void) navgationBarButtonClick:(UIBarButtonItem *)sender{
    if(sender.tag==1){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self setRightBarBtnItemImageWith:isEditing];
        if(!isEditing){
            [UIView animateWithDuration:0.5 animations:^{
                btnView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleAllHeight-49-64, [UtilityFunc shareInstance].globleWidth, 49);
                self.mainTableView.frame = CGRectMake(self.mainTableView.frame.origin.x, self.mainTableView.frame.origin.y, self.mainTableView.frame.size.width, self.mainTableView.frame.size.height-49);
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFinishViewControStartEditing object:nil];
            
        }
        else{
            [UIView animateWithDuration:0.5 animations:^{
                btnView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth, 49);
                self.mainTableView.frame = CGRectMake(self.mainTableView.frame.origin.x, self.mainTableView.frame.origin.y, self.mainTableView.frame.size.width, self.mainTableView.frame.size.height+49);
            }];
            
            ((UIButton *)[btnView viewWithTag:11]).enabled = NO;
            [((UIButton *)[btnView viewWithTag:11]) setImage:LOADIMAGE(@"nodelect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
            [((UIButton *)[btnView viewWithTag:10]) setImage:LOADIMAGE(@"unselect_all_btn", kImageTypePNG) forState:UIControlStateNormal];

            [[NSNotificationCenter defaultCenter ] postNotificationName:kFinishViewControEndEditing object:nil];
            for(int i=0;i<selectCellArray.count;i++){
                NSNumber *number = [selectCellArray objectAtIndex:i];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:number.integerValue inSection:0];
                RMFinishDownTableViewCell *cell = (RMFinishDownTableViewCell*)[self.mainTableView cellForRowAtIndexPath:indexPath];
                cell.editingImage.image = [UIImage imageNamed:@"no-select_cellImage"];
                [cellEditingImageArray replaceObjectAtIndex:number.integerValue withObject:@"no-select_cellImage"];
            }
            [selectCellArray removeAllObjects];
        }
        isEditing = !isEditing;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cellIIdentifier";
    RMFinishDownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMFinishDownTableViewCell" owner:self options:nil] lastObject];
        if(isEditing)
            [cell setCellViewFrame];
    }
    RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [cell.editingImage setImage:[UIImage imageNamed:[cellEditingImageArray objectAtIndex:indexPath.row]]];
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.pic_url] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
    cell.movieName.text = model.name;
    cell.memoryCount.hidden = YES;
    cell.movieCount.hidden = YES;
    return cell;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(isEditing){
        NSString *cellIamge = [cellEditingImageArray objectAtIndex:indexPath.row];
        if([cellIamge isEqualToString:@"no-select_cellImage"]){
            [cellEditingImageArray replaceObjectAtIndex:indexPath.row withObject:@"select_cellImage"];
        }else{
            [cellEditingImageArray replaceObjectAtIndex:indexPath.row withObject:@"no-select_cellImage"];
        }
        if([selectCellArray containsObject:[NSNumber numberWithInt:indexPath.row]]){
            [selectCellArray removeObject:[NSNumber numberWithInt:indexPath.row]];
        }
        else{
            [selectCellArray addObject:[NSNumber numberWithInt:indexPath.row]];
        }
        UIButton *button = (UIButton *)[btnView viewWithTag:11];
        if(selectCellArray.count>0){
            [button setImage:[UIImage imageNamed:@"undelect_all_btn"] forState:UIControlStateNormal];
            button.enabled = YES;
        }else{
            [button setImage:[UIImage imageNamed:@"nodelect_all_btn"] forState:UIControlStateNormal];
            button.enabled = NO;
        }

        [self.mainTableView reloadData];
    }
    else{
        NSLog(@"非编辑状态下---index：%d",indexPath.row);
        RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];

        RMVideoPlaybackDetailsViewController *videoPlay = [[RMVideoPlaybackDetailsViewController alloc] init];
        videoPlay.currentVideo_id = model.video_id;
        [self.navigationController pushViewController:videoPlay animated:YES];
    }
}


@end

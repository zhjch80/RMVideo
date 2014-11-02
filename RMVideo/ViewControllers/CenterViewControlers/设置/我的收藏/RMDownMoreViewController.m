//
//  RMDownMoreViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-22.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDownMoreViewController.h"
#import "RMFinishDownTableViewCell.h"
#import "RMVideoPlaybackDetailsViewController.h"

typedef enum{
    downLoadRequestType = 1,
    deleteRequestType
    
}AFNRequestType;

@interface RMDownMoreViewController (){
    RMAFNRequestManager *manager;
    AFNRequestType requestType;
}

@end

@implementation RMDownMoreViewController

- (void)navgationBarButtonClick:(UIBarButtonItem *)sender{
    if(sender.tag==1){
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [self setRightBarBtnItemImageWith:isEditing];
        if(!isEditing){
            [UIView animateWithDuration:0.5 animations:^{
                btnView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleAllHeight-49-64, [UtilityFunc shareInstance].globleWidth, 49);
                self.mainTableView.frame = CGRectMake(self.mainTableView.frame.origin.x, self.mainTableView.frame.origin.y, self.mainTableView.frame.size.width, self.mainTableView.frame.size.height-25);
            }];
            [[NSNotificationCenter defaultCenter] postNotificationName:kFinishViewControStartEditing object:nil];
            
        }
        else{
            [UIView animateWithDuration:0.5 animations:^{
                btnView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth, 49);
                self.mainTableView.frame = CGRectMake(self.mainTableView.frame.origin.x, self.mainTableView.frame.origin.y, self.mainTableView.frame.size.width, self.mainTableView.frame.size.height+25);
            }];
            ((UIButton *)[btnView viewWithTag:11]).enabled = NO;
            [((UIButton *)[btnView viewWithTag:11]) setImage:LOADIMAGE(@"nodelect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isSeleltAllCell = YES;
    requestType = downLoadRequestType;
    
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
    
    selectCellArray = [NSMutableArray array];
    cellEditingImageArray = [NSMutableArray array];
    for (int i=0; i<20; i++) {
        [cellEditingImageArray addObject:@"no-select_cellImage"];
    }

    manager = [[RMAFNRequestManager alloc] init];
    manager.delegate = self;
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeBlack];
    [manager getFavoriteVideoListWithToken:testToken Page:@"1" count:@"10"];
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
        }
        else{
            [sender setImage:LOADIMAGE(@"unselect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
            for(int i=0; i<self.dataArray.count;i++){
                [cellEditingImageArray replaceObjectAtIndex:i withObject:@"no-select_cellImage"];
            }
        }
        isSeleltAllCell = !isSeleltAllCell;
        [self.mainTableView reloadData];
    }else{
        requestType = deleteRequestType;
        if (selectCellArray.count>0) {
            NSString *deleteID = @"id";
            for(int i=0;i<selectCellArray.count;i++){
                int index = [[selectCellArray objectAtIndex:i] intValue];
                RMPublicModel *model = [self.dataArray objectAtIndex:index];
                deleteID = [NSString stringWithFormat:@"%@,%@",deleteID,model.video_id];
            }
            ((UIButton *)[btnView viewWithTag:11]).enabled = NO;
            [((UIButton *)[btnView viewWithTag:11]) setImage:LOADIMAGE(@"nodelect_all_btn", kImageTypePNG) forState:UIControlStateNormal];
            deleteID = [deleteID substringFromIndex:3];
            [SVProgressHUD showWithStatus:@"删除中" maskType:SVProgressHUDMaskTypeBlack];
            [manager getDeleteFavoriteVideoWithToken:testToken videoID:deleteID];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请选择要删除的选项" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alertView show];
        }
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
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.pic]];
    cell.movieName.text = model.name;
    cell.movieCount.text = nil;
    [cell.editingImage setImage:[UIImage imageNamed:[cellEditingImageArray objectAtIndex:indexPath.row]]];
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
        RMVideoPlaybackDetailsViewController *videoPlay = [[RMVideoPlaybackDetailsViewController alloc] init];
        [self.navigationController pushViewController:videoPlay animated:YES];
    }
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    
    if(requestType == downLoadRequestType){
        self.dataArray = data;
        [self.mainTableView reloadData];
    }else if (requestType == deleteRequestType) {
        
        NSMutableArray *deleteArray = [NSMutableArray array];
        NSArray *sort = [selectCellArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
            return obj1.integerValue<obj2.integerValue;
        }];
        for(int i=0;i<sort.count;i++){
            NSNumber *number = [sort objectAtIndex:i];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:number.integerValue inSection:0];
            [deleteArray addObject:indexPath];
        }
        for(int i=0;i<sort.count;i++){
            NSNumber *number = [sort objectAtIndex:i];
            [self.dataArray removeObjectAtIndex:number.integerValue];
            [cellEditingImageArray removeObjectAtIndex:number.integerValue];
        }
        
        [self.mainTableView deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationNone];
        [self.mainTableView reloadData];
        [selectCellArray removeAllObjects];
        [UIView animateWithDuration:0.5 animations:^{
            btnView.frame = CGRectMake(0, [UtilityFunc shareInstance].globleAllHeight, [UtilityFunc shareInstance].globleWidth, 49);
            self.mainTableView.frame = CGRectMake(self.mainTableView.frame.origin.x, self.mainTableView.frame.origin.y, self.mainTableView.frame.size.width, self.mainTableView.frame.size.height+25);
        }];
        [[NSNotificationCenter defaultCenter ] postNotificationName:kFinishViewControEndEditing object:nil];
        isEditing = NO;
        requestType = downLoadRequestType;
    }
    [SVProgressHUD dismiss];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

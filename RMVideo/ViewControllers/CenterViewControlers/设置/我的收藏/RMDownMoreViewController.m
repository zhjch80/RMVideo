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
#import "RMWebViewPlayViewController.h"
#import "RMModel.h"
#import "RMPlayer.h"
#import "RMCustomPresentNavViewController.h"

typedef enum{
    downLoadRequestType = 1,
    deleteRequestType
    
}AFNRequestType;

@interface RMDownMoreViewController ()<RMFinishDownTableViewCellDelegate>{
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_Setup_Collect" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_Setup_Collect" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isSeleltAllCell = YES;
    requestType = downLoadRequestType;
    
    [self setTitle:@"我的收藏"];
    [leftBarButton setImage:[UIImage imageNamed:@"backup_img"] forState:UIControlStateNormal];
    
    selectCellArray = [NSMutableArray array];
    cellEditingImageArray = [NSMutableArray array];
    for (int i=0; i<20; i++) {
        [cellEditingImageArray addObject:@"no-select_cellImage"];
    }
    [self showEmptyViewWithImage:[UIImage imageNamed:@"no_save_history"] WithTitle:@"您没有收藏记录"];
    manager = [[RMAFNRequestManager alloc] init];
    manager.delegate = self;
    [SVProgressHUD showWithStatus:@"加载中" maskType:SVProgressHUDMaskTypeClear];
    CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
    NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
    [manager getFavoriteVideoListWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] Page:@"1" count:@"10"];
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
            [SVProgressHUD showWithStatus:@"删除中" maskType:SVProgressHUDMaskTypeClear];
            CUSFileStorage *storage = [CUSFileStorageManager getFileStorage:CURRENTENCRYPTFILE];
            NSDictionary *dict = [storage objectForKey:UserLoginInformation_KEY];
            [manager getDeleteFavoriteVideoWithToken:[NSString stringWithFormat:@"%@",[dict objectForKey:@"token"]] videoID:deleteID];
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
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMFinishDownTableViewCell_1" owner:self options:nil] lastObject];
        if(isEditing)
            [cell setCellViewFrame];
    }
    RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
    cell.movieName.text = model.name;
    cell.playButton.tag = indexPath.row;
    cell.delegate = self;
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
        RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
        videoPlay.currentVideo_id = model.video_id;
        [self.navigationController pushViewController:videoPlay animated:YES];
    }
}

- (void)requestFinishiDownLoadWith:(NSMutableArray *)data{
    if(requestType == downLoadRequestType){
        if (data.count==0) {
            [SVProgressHUD dismiss];
            rightBarButton.hidden = YES;
            [self isShouldSetHiddenEmptyView:NO];
            return;
        }else{
            rightBarButton.hidden = NO;
            [self isShouldSetHiddenEmptyView:YES];
        }
        self.dataArray = data;
        [self.mainTableView reloadData];
    }else if (requestType == deleteRequestType) {
        NSMutableArray *deleteArray = [NSMutableArray array];
        NSArray *sort = [selectCellArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
            [SVProgressHUD dismiss];
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
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:number.integerValue inSection:0];
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            [self.mainTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [cellEditingImageArray removeObjectAtIndex:number.integerValue];
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
            self.mainTableView.frame = CGRectMake(self.mainTableView.frame.origin.x, self.mainTableView.frame.origin.y, self.mainTableView.frame.size.width, self.mainTableView.frame.size.height+25);
        }];
        [[NSNotificationCenter defaultCenter ] postNotificationName:kFinishViewControEndEditing object:nil];
        isEditing = NO;
        requestType = downLoadRequestType;
    }
    [SVProgressHUD dismiss];
}

- (void)requestError:(NSError *)error {
    NSLog(@"error:%@",error);
}

/**
 *  直接播放
 */
- (void)palyMovieWithIndex:(NSInteger)index{
    RMPublicModel *model = [self.dataArray objectAtIndex:index];
    if ([model.video_type isEqualToString:@"1"]){
        if([model.downLoadURL isEqualToString:@""]||model.downLoadURL== nil){
            if([model.jumpurl isEqualToString:@""]||model.jumpurl==nil){
                [SVProgressHUD showErrorWithStatus:@"暂时不能播放该视频"];
                return;
            }
            //跳转web
            //保存数据sqlit
            RMPublicModel *insertModel = [[RMPublicModel alloc] init];
            insertModel.name = model.name;
            insertModel.pic_url = model.pic;
            insertModel.jumpurl = model.jumpurl;
            insertModel.playTime = @"0";
            insertModel.video_id = model.video_id;
            [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
            RMWebViewPlayViewController *webView = [[RMWebViewPlayViewController alloc] init];
            RMCustomPresentNavViewController * webNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:webView];
            webView.urlString = model.jumpurl;
            [self presentViewController:webNav animated:YES completion:^{
            }];
        }
        else{
            //使用custom play 播放mp4
            //保存数据sqlit
            RMPublicModel *insertModel = [[RMPublicModel alloc] init];
            insertModel.name = model.name;
            insertModel.pic_url = model.pic;
            insertModel.reurl = model.downLoadURL;
            insertModel.playTime = @"0";
            insertModel.video_id = model.video_id;
            [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
            //电影
            RMModel * playmodel = [[RMModel alloc] init];
            playmodel.url = model.downLoadURL;
            playmodel.title = model.name;
            [RMPlayer presentVideoPlayerWithPlayModel:playmodel withUIViewController:self withVideoType:1];
        }
    }else{
        if([[[model.urls objectAtIndex:0] objectForKey:@"m_down_url"] isEqualToString:@""] || [[model.urls objectAtIndex:0] objectForKey:@"m_down_url"] == nil){
            if([[[model.urls objectAtIndex:0] objectForKey:@"jumpurl"] isEqualToString:@""] || [[model.urls objectAtIndex:0] objectForKey:@"jumpurl"] == nil){
                [SVProgressHUD showErrorWithStatus:@"暂时不能播放该视频"];
                return;
            }
            //跳转web
            //保存数据sqlit
            RMPublicModel *insertModel = [[RMPublicModel alloc] init];
            insertModel.name = model.name;
            insertModel.pic_url = model.pic;
            insertModel.jumpurl = [[model.urls objectAtIndex:0] objectForKey:@"jumpurl"];
            insertModel.playTime = @"0";
            insertModel.video_id = model.video_id;
            [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
            RMWebViewPlayViewController *webView = [[RMWebViewPlayViewController alloc] init];
            RMCustomPresentNavViewController * webNav = [[RMCustomPresentNavViewController alloc] initWithRootViewController:webView];
            webView.urlString = [[model.urls objectAtIndex:0] objectForKey:@"jumpurl"];
            [self presentViewController:webNav animated:YES completion:^{
            }];
        }else{
            //使用custom play 播放mp4
            //保存数据sqlit
            RMPublicModel *insertModel = [[RMPublicModel alloc] init];
            insertModel.name = model.name;
            insertModel.pic_url = model.pic;
            insertModel.reurl = [[model.urls objectAtIndex:0] objectForKey:@"m_down_url"];
            insertModel.playTime = @"0";
            insertModel.video_id = model.video_id;
            [[Database sharedDatabase] insertProvinceItem:insertModel andListName:PLAYHISTORYLISTNAME];
            
            NSMutableArray * arr = [[NSMutableArray alloc] init];
            for (int i=0; i<[model.urls count]; i++) {
                RMModel * playmodel = [[RMModel alloc] init];
                playmodel.url = [[model.urls objectAtIndex:i] objectForKey:@"m_down_url"];
                playmodel.title = model.name;
                playmodel.EpisodeValue = [[model.urls objectAtIndex:i] objectForKey:@"order"];
                [arr addObject:playmodel];
            }
            [RMPlayer presentVideoPlayerWithPlayArray:arr withUIViewController:self withVideoType:2];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

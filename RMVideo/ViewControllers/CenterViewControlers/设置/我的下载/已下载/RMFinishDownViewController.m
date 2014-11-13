//
//  RMFinishDownViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMFinishDownViewController.h"
#import "RMFinishDownTableViewCell.h"
#import "RMDownMoreViewController.h"
#import "RMMyDownLoadViewController.h"
#import "RMDownLoadTVSeriesDetailViewController.h"

@interface RMFinishDownViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation RMFinishDownViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [Flurry logEvent:@"VIEW_Setup_Downloaded" timed:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [Flurry endTimedEvent:@"VIEW_Setup_Downloaded" withParameters:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    [self showEmptyViewWithImage:[UIImage imageNamed:@"no_cashe_video"] WithTitle:@"您没有缓存记录"];
    [self setExtraCellLineHidden:self.maiTableView];
    NSArray *tmpArray = [[Database sharedDatabase] readItemFromDownLoadList];
    if ([tmpArray count] == 0){
        [self isShouldSetHiddenEmptyView:NO];

    }else{
        [self isShouldSetHiddenEmptyView:YES];
        RMPublicModel *tmpModel = [tmpArray objectAtIndex:0];
        NSString *titleString =tmpModel.name;
        NSString *tvname = @"";
        if([titleString rangeOfString:@"电视剧"].location == NSNotFound){
            [self.dataArray addObject:tmpModel];
            for(RMPublicModel *model in tmpArray){
                if([model.name rangeOfString:@"电视剧"].location != NSNotFound){
                    NSString *mm = [model.name substringFromIndex:[model.name rangeOfString:@"_"].location+1];
                    NSString *nn = [mm substringToIndex:[mm rangeOfString:@"_"].location];
                    if(![nn isEqualToString:tvname]){
                        model.isTVModel = YES;
                        [self.dataArray addObject:model];
                        tvname = nn;
                    }
                }else if(![model.name isEqualToString:titleString]){
                    [self.dataArray addObject:model];
                }
            }
        }
        else{
            for(RMPublicModel *model in tmpArray){
                if([model.name rangeOfString:@"电视剧"].location == NSNotFound){
                    [self.dataArray addObject:model];
                }else{
                    NSString *mm = [model.name substringFromIndex:[model.name rangeOfString:@"_"].location+1];
                    NSString *nn = [mm substringToIndex:[mm rangeOfString:@"_"].location];
                    if(![nn isEqualToString:tvname]&&![model.name isEqualToString:titleString]){
                        model.isTVModel = YES;
                        [self.dataArray addObject:model];
                        tvname = nn;
                    }
                }
                
            }
        }

        // Do any additional setup after loading the view from its nib.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginAnimation) name:kFinishViewControStartEditing object:nil];
        [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(endAnimation) name:kFinishViewControEndEditing object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadSuccess) name:DownLoadSuccess_KEY object:nil];
        
        selectCellArray = [NSMutableArray array];
        cellEditingImageArray = [NSMutableArray array];
        for (int i=0; i<self.dataArray.count; i++) {
            [cellEditingImageArray addObject:@"no-select_cellImage"];
        }
    
//        NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSString *path = [document stringByAppendingPathComponent:@"DownLoadSuccess"];
//        
//        NSFileManager* fileManeger = [NSFileManager defaultManager];
//        NSError *error;
//        NSArray *array = [fileManeger contentsOfDirectoryAtPath:path error:&error];
        
    }
    
}

//开启编辑状态
- (void)beginAnimation{
    isBegingEditing = YES;
    self.maiTableView.frame = CGRectMake(self.maiTableView.frame.origin.x, self.maiTableView.frame.origin.y, self.maiTableView.frame.size.width, self.maiTableView.frame.size.height-25);
}
//关闭编辑状态
- (void)endAnimation{
    isBegingEditing = NO;
    for(int i=0;i<selectCellArray.count;i++){
        NSNumber *number = [selectCellArray objectAtIndex:i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:number.integerValue inSection:0];
        RMFinishDownTableViewCell *cell = (RMFinishDownTableViewCell*)[self.maiTableView cellForRowAtIndexPath:indexPath];
        cell.editingImage.image = [UIImage imageNamed:@"no-select_cellImage"];
        [cellEditingImageArray replaceObjectAtIndex:number.integerValue withObject:@"no-select_cellImage"];
    }
    [selectCellArray removeAllObjects];
    self.maiTableView.frame = CGRectMake(self.maiTableView.frame.origin.x, self.maiTableView.frame.origin.y, self.maiTableView.frame.size.width, self.maiTableView.frame.size.height+25);
}
//电影下载成功。更新界面
- (void)downLoadSuccess{
    [self.dataArray removeAllObjects];
    NSArray *tmpArray = [[Database sharedDatabase] readItemFromDownLoadList];
    RMPublicModel *tmpModel = [tmpArray objectAtIndex:0];
    NSString *titleString =tmpModel.name;
    NSString *tvname = @"";
    if([titleString rangeOfString:@"电视剧"].location == NSNotFound){
        [self.dataArray addObject:tmpModel];
        for(RMPublicModel *model in tmpArray){
            if([model.name rangeOfString:@"电视剧"].location != NSNotFound){
                NSString *mm = [model.name substringFromIndex:[model.name rangeOfString:@"_"].location+1];
                NSString *nn = [mm substringToIndex:[mm rangeOfString:@"_"].location];
                if(![nn isEqualToString:tvname]){
                    model.isTVModel = YES;
                    [self.dataArray addObject:model];
                    tvname = nn;
                }
            }else if(![model.name isEqualToString:titleString]){
                [self.dataArray addObject:model];
            }
        }
    }
    else{
        for(RMPublicModel *model in tmpArray){
            if([model.name rangeOfString:@"电视剧"].location == NSNotFound){
                [self.dataArray addObject:model];
            }else{
                NSString *mm = [model.name substringFromIndex:[model.name rangeOfString:@"_"].location+1];
                NSString *nn = [mm substringToIndex:[mm rangeOfString:@"_"].location];
                if(![nn isEqualToString:tvname]&&![model.name isEqualToString:titleString]){
                    model.isTVModel = YES;
                    [self.dataArray addObject:model];
                    tvname = nn;
                }
            }
            
        }
    }
    
    if (self.dataArray.count==0) {
        [self isShouldSetHiddenEmptyView:NO];
    }else{
        [self isShouldSetHiddenEmptyView:YES];
    }
    [self.maiTableView reloadData];
    [cellEditingImageArray removeAllObjects];
    for (int i=0; i<self.dataArray.count; i++) {
        [cellEditingImageArray addObject:@"no-select_cellImage"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cellIIdentifier";
    RMFinishDownTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMFinishDownTableViewCell" owner:self options:nil] lastObject];
        if(isBegingEditing){
            [cell setCellViewFrame];
        }
    }
    RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [cell.editingImage setImage:[UIImage imageNamed:[cellEditingImageArray objectAtIndex:indexPath.row]]];
    if(model.isTVModel){
        [cell.headImage setFileShowImageView:model.pic];
        NSString *tmpStr = [model.name substringFromIndex:[model.name rangeOfString:@"_"].location+1];
        tmpStr = [tmpStr substringToIndex:[tmpStr rangeOfString:@"_"].location];
        cell.movieName.text = tmpStr;
        cell.movieCount.text = [NSString stringWithFormat:@"有%d个视频",[self searchTVCountWith:tmpStr]];
    }else{
        [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:LOADIMAGE(@"rb_loadingImg", kImageTypePNG)];
        cell.movieName.text = model.name;
    }
    
    cell.memoryCount.text = model.totalMemory;
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 84.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(isBegingEditing){
        
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
        selectArray(selectCellArray);
        [self.maiTableView reloadData];
    }
    else{
        RMPublicModel *model = [self.dataArray objectAtIndex:indexPath.row];
        if(model.isTVModel){
            RMDownLoadTVSeriesDetailViewController * downLoadTVSeriesDetailCtl = [[RMDownLoadTVSeriesDetailViewController alloc] init];
            downLoadTVSeriesDetailCtl.modelID = model.video_id;
            downLoadTVSeriesDetailCtl.TVName = model.name;
            downLoadTVSeriesDetailCtl.dataArray = [[[Database sharedDatabase] readItemFromDownLoadList] mutableCopy];
            RMMyDownLoadViewController * myDownLoadCtl = self.myDownLoadDelegate;
            [myDownLoadCtl.navigationController pushViewController:downLoadTVSeriesDetailCtl animated:YES];
        }else{
            selectIndex(model.name);
        }
    }
    
}

#pragma mark 全选
- (void)selectAllTableViewCellWithState:(BOOL)state{
    [selectCellArray removeAllObjects];
    if(state){
        for(int i=0; i<self.dataArray.count;i++){
            [cellEditingImageArray replaceObjectAtIndex:i withObject:@"select_cellImage"];
            [selectCellArray addObject:[NSNumber numberWithInt:i]];
        }
        
    }else{
        for(int i=0; i<self.dataArray.count;i++){
            [cellEditingImageArray replaceObjectAtIndex:i withObject:@"no-select_cellImage"];
        }
    }
    [self.maiTableView reloadData];
    
}
#pragma mark 删除
- (void)deleteAllTableViewCell{
    
    NSMutableArray *deleteArray = [NSMutableArray array];
    NSArray *sort = [selectCellArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *obj1, NSNumber *obj2) {
        return obj1.integerValue<obj2.integerValue;
    }];
    for(int i=0;i<sort.count;i++){
        NSNumber *number = [sort objectAtIndex:i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:number.integerValue inSection:0];
        [deleteArray addObject:indexPath];
    }
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [document stringByAppendingPathComponent:@"DownLoadSuccess"];
    
    for(int i=0;i<sort.count;i++){
        NSNumber *number = [sort objectAtIndex:i];
        RMPublicModel *model = [self.dataArray objectAtIndex:number.intValue];
        NSString *removePath = [NSString stringWithFormat:@"%@/%@.mp4",path,model.name];
        NSError *error = nil;
        BOOL remove = [[NSFileManager defaultManager] removeItemAtPath:removePath error:&error];
        [[Database sharedDatabase] deleteItem:model fromListName:DOWNLOADLISTNAME];
        if(remove){
            NSLog(@"删除成功");
        }
        [self.dataArray removeObjectAtIndex:number.integerValue];
        [cellEditingImageArray removeObjectAtIndex:number.integerValue];
        if (self.dataArray.count==0) {
            [self isShouldSetHiddenEmptyView:NO];
        }else{
            [self isShouldSetHiddenEmptyView:YES];
        }
    }
    
    [self.maiTableView deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationNone];
    [self.maiTableView reloadData];
    [selectCellArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinishViewControEndEditing object:nil];
}

//回调 ，
- (void)selectTableViewCellWithIndex:(void (^)(NSString *))block{
    selectIndex = block;
}
- (void)delectCellArray:(void (^)(NSMutableArray *))block{
    selectArray = block;
}

- (NSInteger)searchTVCountWith:(NSString *)title{
    NSArray *tmpArray = [[Database sharedDatabase] readItemFromDownLoadList];
    int sum = 0;
    for(RMPublicModel *model in tmpArray){
        if([model.name rangeOfString:title].location!= NSNotFound){
            sum++;
        }
    }
    return sum;
}
@end

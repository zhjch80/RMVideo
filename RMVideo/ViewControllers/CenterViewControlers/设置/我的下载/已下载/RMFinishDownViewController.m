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
    self.dataArray = [[NSMutableArray alloc] init];
    [self showEmptyViewWithImage:[UIImage imageNamed:@"no_cashe_video"] WithTitle:@"您没有缓存记录"];
    [self setExtraCellLineHidden:self.maiTableView];
    NSArray *tmpArray = [[Database sharedDatabase] readItemFromDownLoadList];
    if ([tmpArray count] == 0){
        [self isShouldSetHiddenEmptyView:NO];
    }else{
        // dataBaseArray主要实在删除的时候使用 dataBaseArray包含的是所有的下载视屏数据
        if(dataBaseArray==nil){
            dataBaseArray = [NSMutableArray arrayWithArray:tmpArray];
        }
        else{
            [dataBaseArray removeAllObjects];
            dataBaseArray = [tmpArray mutableCopy];
        }
        [self isShouldSetHiddenEmptyView:YES];
        for(RMPublicModel *model in tmpArray){
            if([model.name rangeOfString:@"电视剧"].location == NSNotFound){
                [self.dataArray addObject:model];
            }else {
                NSString *mm = [model.name substringFromIndex:[model.name rangeOfString:@"_"].location+1];
                NSString *nn = [mm substringToIndex:[mm rangeOfString:@"_"].location];
                
                if(![self arrayIsHaveTitle:nn inArray:self.dataArray]){
                    model.isTVModel = YES;
                    [self.dataArray addObject:model];
                }
            }
        }
        //开始编辑的时候接受到的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginAnimation) name:kFinishViewControStartEditing object:nil];
        //结束编辑的时候接受到的通知
        [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(endAnimation) name:kFinishViewControEndEditing object:nil];
        //电视机下载详情页面中，编辑完电视机的时候，该界面要进行更新
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TVSericesDetailFinishEditing) name:kTVSeriesDetailDeleteFinish object:nil];
        
        selectCellArray = [NSMutableArray array];
        cellEditingImageArray = [NSMutableArray array];
        for (int i=0; i<self.dataArray.count; i++) {
            [cellEditingImageArray addObject:@"no-select_cellImage"];
        }
    
        //此处注释的部分，显示的下载成功后影片保存的的沙河目录路径 其中array中保存的是所有的下载后的MP4文件
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

//电视剧下载详情编辑完成之后要更新主界面
- (void) TVSericesDetailFinishEditing{
    [self takeTheDataFromDataBase];
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
        [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.pic] placeholderImage:LOADIMAGE(@"Default90_119", kImageTypePNG)];
        cell.movieName.text = model.name;
    }
    NSString *count = [model.totalMemory substringToIndex:[model.totalMemory rangeOfString:@"M"].location];
    if(count.integerValue==0){
        cell.memoryCount.text = @"0.9M";
    }else{
        cell.memoryCount.text = model.totalMemory;
    }
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140.f;
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
        if(model.isTVModel){
            NSString *mm = [model.name substringFromIndex:[model.name rangeOfString:@"_"].location+1];
            NSString *nn = [mm substringToIndex:[mm rangeOfString:@"_"].location];
            for (RMPublicModel *tmpModel in dataBaseArray) {
                if([tmpModel.name rangeOfString:nn].location != NSNotFound){
                    NSString *removePath = [NSString stringWithFormat:@"%@/%@.mp4",path,tmpModel.name];
                    NSError *error = nil;
                    BOOL remove = [[NSFileManager defaultManager] removeItemAtPath:removePath error:&error];
                    [[Database sharedDatabase] deleteItem:tmpModel fromListName:DOWNLOADLISTNAME];
                    if(remove){
                        NSLog(@"删除成功");
                    }
                }
            }
            [self.dataArray removeObjectAtIndex:number.integerValue];
            [cellEditingImageArray removeObjectAtIndex:number.integerValue];
        }else{
            NSString *removePath = [NSString stringWithFormat:@"%@/%@.mp4",path,model.name];
            NSError *error = nil;
            BOOL remove = [[NSFileManager defaultManager] removeItemAtPath:removePath error:&error];
            [[Database sharedDatabase] deleteItem:model fromListName:DOWNLOADLISTNAME];
            if(remove){
                NSLog(@"删除成功");
            }
            [self.dataArray removeObjectAtIndex:number.integerValue];
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:number.integerValue inSection:0];
            NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
            [self.maiTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [cellEditingImageArray removeObjectAtIndex:number.integerValue];
        }
        if (self.dataArray.count==0) {
            [self isShouldSetHiddenEmptyView:NO];
        }else{
            [self isShouldSetHiddenEmptyView:YES];
        }
    }
    [selectCellArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinishViewControEndEditing object:nil];
}

//回调
- (void)selectTableViewCellWithIndex:(void (^)(NSString *))block{
    selectIndex = block;
}
- (void)delectCellArray:(void (^)(NSMutableArray *))block{
    selectArray = block;
}

//判断相关的电视剧有几部  在cell
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
//判断数组中是否存在改字段的model
- (BOOL)arrayIsHaveTitle:(NSString *)titel inArray:(NSMutableArray *)array{
    for(RMPublicModel *model in array){
        if([model.name rangeOfString:titel].location != NSNotFound){
            return YES;
        }
    }
    return NO;
}
//从数据库中去数据，并对数据进行分类，主要是对电视剧进行归类
- (void)takeTheDataFromDataBase{
    [self.dataArray removeAllObjects];
    NSArray *tmpArray = [[Database sharedDatabase] readItemFromDownLoadList];
    if(dataBaseArray==nil){
        dataBaseArray = [NSMutableArray arrayWithArray:tmpArray];
    }
    else{
        [dataBaseArray removeAllObjects];
        dataBaseArray = [tmpArray mutableCopy];
    }
    for(RMPublicModel *model in tmpArray){
        if([model.name rangeOfString:@"电视剧"].location == NSNotFound){
            [self.dataArray addObject:model];
        }else {
            NSString *mm = [model.name substringFromIndex:[model.name rangeOfString:@"_"].location+1];
            NSString *nn = [mm substringToIndex:[mm rangeOfString:@"_"].location];
            
            if(![self arrayIsHaveTitle:nn inArray:self.dataArray]){
                model.isTVModel = YES;
                [self.dataArray addObject:model];
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
@end

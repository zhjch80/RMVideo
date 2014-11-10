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

@interface RMFinishDownViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation RMFinishDownViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray arrayWithArray:[[Database sharedDatabase] readItemFromDownLoadList]];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginAnimation) name:kFinishViewControStartEditing object:nil];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(endAnimation) name:kFinishViewControEndEditing object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downLoadSuccess) name:DownLoadSuccess_KEY object:nil];
    
    selectCellArray = [NSMutableArray array];
    cellEditingImageArray = [NSMutableArray array];
    for (int i=0; i<self.dataArray.count; i++) {
        [cellEditingImageArray addObject:@"no-select_cellImage"];
    }

    [self setExtraCellLineHidden:self.maiTableView];
    

    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [document stringByAppendingPathComponent:@"DownLoadSuccess"];
    
    NSFileManager* fileManeger = [NSFileManager defaultManager];
    NSError *error;
    NSArray *array = [fileManeger contentsOfDirectoryAtPath:path error:&error];
    NSLog(@"array:%@",array);
    
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"backspace" ofType:@"mov"];
//    NSURL *sourceMovieURL = [NSURL fileURLWithPath:filePath];
    
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
    self.dataArray = [NSMutableArray arrayWithArray:[[Database sharedDatabase] readItemFromDownLoadList]];
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
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.pic]];
    cell.movieName.text = model.name;
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
        selectIndex(model.name);
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
@end

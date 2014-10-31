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
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginAnimation) name:kFinishViewControStartEditing object:nil];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(endAnimation) name:kFinishViewControEndEditing object:nil];
    selectCellArray = [NSMutableArray array];
    cellEditingImageArray = [NSMutableArray array];
    for (int i=0; i<self.dataArray.count; i++) {
        [cellEditingImageArray addObject:@"no-select_cellImage"];
    }
//    if (self.dataArray.count==0) {
//        self.maiTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    }else{
//        self.maiTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    }
    [self setExtraCellLineHidden:self.maiTableView];
}

- (void)beginAnimation{
    isBegingEditing = YES;
    self.maiTableView.frame = CGRectMake(self.maiTableView.frame.origin.x, self.maiTableView.frame.origin.y, self.maiTableView.frame.size.width, self.maiTableView.frame.size.height-25);
}

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
    [cell.editingImage setImage:[UIImage imageNamed:[cellEditingImageArray objectAtIndex:indexPath.row]]];
   
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
        [self.maiTableView reloadData];
    }
    else{
        selectIndex(indexPath.row);
    }
    
}
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
    for(int i=0;i<sort.count;i++){
        NSNumber *number = [sort objectAtIndex:i];
        [self.dataArray removeObjectAtIndex:number.integerValue];
        [cellEditingImageArray removeObjectAtIndex:number.integerValue];
    }

    [self.maiTableView deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationNone];
    [self.maiTableView reloadData];
    [selectCellArray removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFinishViewControEndEditing object:nil];
}
- (void)selectTableViewCellWithIndex:(void (^)(NSInteger))block{
    selectIndex = block;
}
@end

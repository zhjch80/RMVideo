//
//  RMDownLoadingViewController.m
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMDownLoadingViewController.h"
#import "RMDownLoadingTableViewCell.h"

@interface RMDownLoadingViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation RMDownLoadingViewController
static id _instance;

+ (id) alloc{
    return [super alloc];
}
+ (id) allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+(id)copyWithZone:(struct _NSZone *)zone{
    return _instance;
}

- (id)init {
    static id obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if((obj=[super init]) != nil){
        }
    });
    self = obj;
    return self;
}
+(instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginAnimation) name:kDownLoadingControStartEditing object:nil];
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(endAnimation) name:kDownLoadingControEndEditing object:nil];
    selectCellArray = [[NSMutableArray alloc] init];
    cellEditingImageArray = [[NSMutableArray alloc] init];
    isPauseAllDownLoadAssignment = NO;
    for (int i=0; i<self.dataArray.count; i++) {
        [cellEditingImageArray addObject:@"no-select_cellImage"];
    }
}

- (void)beginAnimation{
    isBeginEditing = YES;
    self.mainTableView.frame = CGRectMake(self.mainTableView.frame.origin.x, self.mainTableView.frame.origin.y, self.mainTableView.frame.size.width, self.mainTableView.frame.size.height-25);
}

- (void)endAnimation{
    
    isBeginEditing = NO;
    for(int i=0;i<selectCellArray.count;i++){
        NSNumber *number = [selectCellArray objectAtIndex:i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:number.integerValue inSection:0];
        RMDownLoadingTableViewCell *cell = (RMDownLoadingTableViewCell*)[self.mainTableView cellForRowAtIndexPath:indexPath];
        cell.editingImageView.image = [UIImage imageNamed:@"no-select_cellImage"];
        [cellEditingImageArray replaceObjectAtIndex:number.integerValue withObject:@"no-select_cellImage"];
    }
    [selectCellArray removeAllObjects];
    self.mainTableView.frame = CGRectMake(self.mainTableView.frame.origin.x, self.mainTableView.frame.origin.y, self.mainTableView.frame.size.width, self.mainTableView.frame.size.height+25);
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"downLoadingcellIIdentifier";
    RMDownLoadingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell==nil){
        cell = [[[NSBundle mainBundle] loadNibNamed:@"RMDownLoadingTableViewCell" owner:self options:nil] lastObject];
        if(isBeginEditing)
            [cell setCellViewOfFrame];
    }
    
    //[cell setCellViewOfFrame];
    [cell.editingImageView setImage:[UIImage imageNamed:[cellEditingImageArray objectAtIndex:indexPath.row]]];
    return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 84.f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(isBeginEditing){
        
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
        [self.mainTableView reloadData];
    }else{
        selectIndex(indexPath.row);
    }
}
- (IBAction)pauseOrStarAllBtnClick:(UIButton *)sender {
    if(!isPauseAllDownLoadAssignment){
        [self.pauseOrStarBtn setBackgroundImage:[UIImage imageNamed:@"start_all_downLoad_image"] forState:UIControlStateNormal];
        [self.showDownLoadState setTitle:@"全部开始" forState:UIControlStateNormal];
    }
    else{
        [self.pauseOrStarBtn setBackgroundImage:[UIImage imageNamed:@"pause_all_downLoad_Image"] forState:UIControlStateNormal];
        [self.showDownLoadState setTitle:@"全部暂停" forState:UIControlStateNormal];
    }
    isPauseAllDownLoadAssignment = !isPauseAllDownLoadAssignment;
}

- (void)selectTableViewCellWithIndex:(void (^)(NSInteger))selectBlock{
    selectIndex = selectBlock;
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
    [self.mainTableView reloadData];
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
    
    [self.mainTableView deleteRowsAtIndexPaths:deleteArray withRowAnimation:UITableViewRowAnimationNone];
    [self.mainTableView reloadData];
    [selectCellArray removeAllObjects];
    [[NSNotificationCenter defaultCenter ] postNotificationName:kDownLoadingControEndEditing object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

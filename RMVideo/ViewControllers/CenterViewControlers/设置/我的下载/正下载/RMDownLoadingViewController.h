//
//  RMDownLoadingViewController.h
//  RMVideo
//
//  Created by 润华联动 on 14-10-17.
//  Copyright (c) 2014年 runmobile. All rights reserved.
//

#import "RMBaseViewController.h"

@interface RMDownLoadingViewController : RMBaseViewController
{
    NSMutableArray *selectCellArray; //编辑时将要编辑的cell
    NSMutableArray *cellEditingImageArray; //编辑按钮的数组，在编辑状态主要是更换数组中的图片来达到编辑的效果
    void (^selectIndex)(NSInteger index);
    void(^selectArray)(NSMutableArray *array);
    BOOL isBeginEditing;
    BOOL isPauseAllDownLoadAssignment;//是否暂停所有下载任务
    AFHTTPRequestOperation *operation;
    NSInteger downLoadIndex; //标记当前下载位置。即那个电影正在下载
    //该值主要在开始下载的时候用。假若为YES的，说明当前下载进度被暂停，要下载下一个。若为NO，则表示从其他界面控制该界面进行下载该电影
    BOOL isCLickPauseCell;
    unsigned long long downloadedBytes;
}
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UIButton *showDownLoadState;
@property (weak, nonatomic) IBOutlet UIButton *pauseOrStarBtn;
@property (strong, nonatomic) NSMutableArray *dataArray;  //tableview 的数据源
@property (strong, nonatomic) NSMutableArray *downLoadIDArray; //正在下载的数组
@property (strong, nonatomic) NSMutableArray *pauseLoadingArray;//暂停中的数组
@property (nonatomic)BOOL isDownLoadNow; //判断当前是否有下载任务
@property (nonatomic)NSUInteger downLoadSpeed;
@property (nonatomic)long long haveReadTheSchedule;
@property (nonatomic)long long totalDownLoad;
@property (nonatomic, assign) id myDownLoadDelegate;


- (IBAction)pauseOrStarAllBtnClick:(UIButton *)sender;

- (void)selectTableViewCellWithIndex:(void(^)(NSInteger index))selectBlock;

- (void)delectCellArray:(void(^)(NSMutableArray *array))block;

+(instancetype)shared;

//全选
- (void)selectAllTableViewCellWithState:(BOOL)state;

//删除
- (void)deleteAllTableViewCell;

- (void)BeginDownLoad;

- (void)saveData;

- (BOOL)dataArrayContainsModel:(RMPublicModel *)model;
@end

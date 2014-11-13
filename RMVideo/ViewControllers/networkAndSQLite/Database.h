//
//  Database.h
//  jumeiyouping
//
//  Created by qianfeng on 13-3-28.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "RMPublicModel.h"

@interface Database : NSObject
{
    FMDatabase *mdb;
}

//数据库保存目录
+(NSString *)filePath:(NSString *)fileName;

//实例化数据库
+(Database *)sharedDatabase;

-(id)init;
//称数据插入
-(void)insertProvinceItem:(RMPublicModel *)item andListName:(NSString *)listName;

//更新数据
//-(void)updateWithItem:(RMPublicModel *)item fromListName:(NSString *)listName;

//删除表中所有数据
-(void)deleteAllDataSourceFromListName:(NSString *)listName;

-(void)deleteItem:(RMPublicModel *)item fromListName:(NSString *)listName;

//多条数据插入 
-(void)insertArray:(NSArray *)array toListName:(NSString *)listName;

//下载数据多条插入
- (void)insertDownLoadArray:(NSArray *)array;
//下载数据单挑插入
- (void)insertDownLoadItem:(RMPublicModel *)item;

//读取表中的数据个数
-(NSInteger)itemcountFromListName:(NSString *)listName ;

//从数据库中读取数据
-(NSArray *)readitemFromListName:(NSString *)listName;
//已下载电影数据读取
- (NSArray *)readItemFromDownLoadList;
- (void)deletFristItem;

- (BOOL)isDownLoadMovieWith:(RMPublicModel *)model;
- (BOOL)isDownLoadMovieWithModelName:(NSString *)modelName;

@end

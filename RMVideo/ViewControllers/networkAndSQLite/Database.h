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
//省名称数据插入
-(void)insertProvinceItem:(RMPublicModel *)item andListName:(NSString *)listName;

//-(void)updatecountnum:(NSString *)itemID count:(NSString *)count;

//删除表中所有数据
-(void)deleteAllDataSourceFromListName:(NSString *)listName;

//多条数据插入 只有在cityName数据插入的时候需要传provinceID，其余传nil就可以
-(void)insertArray:(NSArray *)array toListName:(NSString *)listName andProvinveID:(NSString *)provinceID;

//读取表中的数据个数 查询cityName的个数时需要传入provinceID
-(NSInteger)itemcountFromListName:(NSString *)listName andProvinceID:(NSString *)provinceID;

//查询当条件满足genre的结果
- (NSString *)selectMovieGenre:(NSString *)genre forListName:(NSString *)name;

//-(NSInteger)itemcountnumber:(NSString *)ItemID;

//从数据库中读取数据
-(NSArray *)readitemFromListName:(NSString *)listName andProvinceID:(NSString *)provinceID;

@end

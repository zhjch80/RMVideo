//
//  Database.m
//  jumeiyouping
//
//  Created by qianfeng on 13-3-28.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "Database.h"

#define DATABASENAME @"SQLite.db"
#define PLAYHISTORYLISTNAME @"PlayHistoryListname"

static Database *gl_database=nil;
@implementation Database

//实例化数据库
+(Database *)sharedDatabase
{
    if(!gl_database)
    {
        gl_database = [[Database alloc] init];
    }
    return gl_database;
}

//创建数据库文件目录
+(NSString *)filePath:(NSString *)fileName
{
    NSString *rootPath = NSHomeDirectory();
    rootPath = [rootPath stringByAppendingPathComponent:@"Library/Caches"];
    if(fileName&&[fileName length]!=0)
    {
        rootPath = [rootPath stringByAppendingPathComponent:fileName];
    }
    
    return rootPath;
}

//创建表
-(void)creatDatabaseWithListName:(NSString *)listName
{
    NSString *filepath = [Database filePath:DATABASENAME];
    
    mdb = [FMDatabase databaseWithPath:filepath];
    
    if([mdb open])
    {
        NSString *playHistoryNameSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (serial integer  Primary Key Autoincrement,provinceName TEXT(1024) DEFAULT NULL,provinceID TEXT(1024) DEFAULT NULL)",PLAYHISTORYLISTNAME];
       
        if(![mdb executeUpdate:playHistoryNameSql])
        {
            NSLog(@"创建表失败");
        }
    }
    [mdb close];
}

//-(void)updatecountnum:(NSString *)itemID count:(NSString *)count
//{
//    NSString *sql = [NSString stringWithFormat:@"update %@ set countnum=? where ID=?",LISTNAME,count,itemID];
//    if([mdb executeUpdate:sql,count,itemID]){
//        NSLog(@"更新成功");
//    }
//    else{
//        NSLog(@"更新失败");
//    }
//}

//删除数据库中表中的数据
-(void)deleteAllDataSourceFromListName:(NSString *)listName;
{
    if([mdb open]){
        NSString *sql = [NSString stringWithFormat:@"delete from %@",listName];
        if([mdb executeUpdate:sql]){
            NSLog(@"删除成功");
        }
        else{
            NSLog(@"删除失败");
        }
    }
    [mdb close];
}

//判断所插入省份的数据是否已经在数据库中，避免重复插入
-(BOOL)isExistProvinceItem:(RMPublicModel *)item FromListName:(NSString *)listName
{
    NSString *sql = [NSString stringWithFormat:@"select provincrID from %@ where provincrID=?",listName];
    FMResultSet *rs = [mdb executeQuery:sql,item.video_id];
    while ([rs next]) {
        return YES;
    }
    return NO;
}
//插入单个省份数据
-(void)insertProvinceItem:(RMPublicModel *)item andListName:(NSString *)listName
{
    if([self isExistProvinceItem:item FromListName:listName])
    {
        return;
    }
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (provinceName,provinceID) values (?,?)",listName];
    if([mdb executeUpdate:sql,item.name,item.video_id])
    {
        NSLog(@"插入成功");
    }
    else
    {
        NSLog(@"插入失败:%@",[mdb lastErrorMessage]);
    }

}

//多条数据插入
-(void)insertArray:(NSArray *)array toListName:(NSString *)listName andProvinveID:(NSString *)provinceID
{
    if([mdb open]){
        [mdb beginTransaction];
        if([listName isEqualToString:PLAYHISTORYLISTNAME]){
            for(RMPublicModel *item in array)
            {
                [self insertProvinceItem:item andListName:listName];
            }
        }
        [mdb commit];
    }
    [mdb close];
}

//表中数据个数
-(NSInteger)itemcountFromListName:(NSString *)listName andProvinceID:(NSString *)provinceID
{
    if([mdb open]){
        NSString *sql = nil;
        if([listName isEqualToString:PLAYHISTORYLISTNAME])
            sql = [NSString stringWithFormat:@"select count(*) from %@ where provinceID='%@'",listName,provinceID];
        else
            sql = [NSString stringWithFormat:@"select count(*) from %@",listName];
        FMResultSet *rs = [mdb executeQuery:sql];
        while ([rs next]) {
            NSInteger count = [rs intForColumnIndex:0];
            [mdb close];
            return count;
        }
    }
    [mdb close];
    return 0;
    
}
//
//-(NSInteger)itemcountnumber:(NSString *)ItemID
//{
//    NSString *sql = @"select countnum from newtablelist where ID=?";
//    FMResultSet *rs = [mdb executeQuery:sql,ItemID];
//   if([rs next])
//   {
//       NSInteger countnum = [rs intForColumnIndex:0];
//       return countnum;
//   }
//    return 0;
//}

//读取数据
-(NSArray *)readitemFromListName:(NSString *)listName andProvinceID:(NSString *)provinceID
{
    if([mdb open]){
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        
        NSString *sql = nil;
        
        if([listName isEqualToString:PLAYHISTORYLISTNAME]){
            sql = [NSString stringWithFormat:@"select provinceName,provinceID from %@",listName];
        }
        FMResultSet *rs = [mdb executeQuery:sql];
        
        if([listName isEqualToString:PLAYHISTORYLISTNAME]){
            while ([rs next]) {
                RMPublicModel *item = [[RMPublicModel alloc] init];
                item.name = [rs stringForColumn:@"provinceName"];
                item.video_id = [rs stringForColumn:@"provinceID"];
                [array addObject:item];
            }

        }
        [mdb close];
        return array;
    }
    [mdb close];
    return nil;
    
}

- (NSString *)selectMovieGenre:(NSString *)genre forListName:(NSString *)name{
    
    if([mdb open]){
        
        NSString *sql = [NSString stringWithFormat:@"select cinemaLineID from %@ where cinemaLineName=?",name];
        FMResultSet *rs = [mdb executeQuery:sql,genre];
        
        NSString *stringID = nil;
        while ([rs next])
                stringID = [rs stringForColumn:@"cinemaLineID"];
        NSLog(@"stringID:%@",stringID);
        [mdb close];
        return stringID;
            
    }
    [mdb close];
    return nil;

}

-(id)init
{
    if(self=[super init])
    {
        [self creatDatabaseWithListName:nil];
    }
    return self;
}


/*
 1、创建数据库 在AppDelete中
 [Database sharedDatabase];
 2、查询条数
 NSUInteger num = [[Database sharedDatabase] itemcountFromListName:CITYNAMELISTNAME andProvinceID:self.provinceID];
 3、读取数据
 NSArray *array = [[Database sharedDatabase] readitemFromListName:CITYNAMELISTNAME andProvinceID:self.provinceID];
 4、插入数据库
 //将下载结果插入数据库中
 [[Database sharedDatabase] insertArray:tmpModel.array toListName:CITYNAMELISTNAME andProvinveID:self.provinceID];
 */

@end

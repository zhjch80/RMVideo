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
#define DOWNLOADLISTNAME @"DownLoadListname"

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
        NSString *playHistoryNameSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (serial integer  Primary Key Autoincrement,titleName TEXT(1024) DEFAULT NULL,titleImage TEXT(1024),movieURL TEXT(1024),playTime TEXT(1024) DEFAULT NULL)",PLAYHISTORYLISTNAME];
        NSString *downLoadSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (serial integer  Primary Key Autoincrement,titleName TEXT(1024) DEFAULT NULL,titleImage TEXT(1024),totalMemory TEXT(1024) DEFAULT NULL)",DOWNLOADLISTNAME];
       
        if(![mdb executeUpdate:playHistoryNameSql]||![mdb executeUpdate:downLoadSql])
        {
            NSLog(@"创建表失败");
        }
    }
    [mdb close];
}

//-(void)updatecountnum:(NSString *)itemID count:(NSString *)count
//{
//    NSString *sql = [NSString stringWithFormat:@"update %@ set countnum=? where titleName=?",PLAYHISTORYLISTNAME,count,itemID];
//    if([mdb executeUpdate:sql,count,itemID]){
//        NSLog(@"更新成功");
//    }
//    else{
//        NSLog(@"更新失败");
//    }
//}

- (void)deletFristItem{
    NSArray *array = [self readitemFromListName:PLAYHISTORYLISTNAME];
    [self deleteItem:[array objectAtIndex:0] fromListName:PLAYHISTORYLISTNAME];
}

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
//删除某一条
-(void)deleteItem:(RMPublicModel *)item fromListName:(NSString *)listName{
    
//    NSString * sql=[NSString stringWithFormat:@"delete from HJMKIGHRModels where txtpath=?"];
    
    if([mdb open]){
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where titleName='%@'",listName,item.name];
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
    NSString *sql = [NSString stringWithFormat:@"select titleName from %@ where titleName=?",listName];
    FMResultSet *rs = [mdb executeQuery:sql,item.name];
    while ([rs next]) {
        return YES;
    }
    return NO;
}

- (BOOL)isDownLoadMovieWith:(RMPublicModel *)model{
    NSString *sql = [NSString stringWithFormat:@"select titleName from DownLoadListname where titleName=?"];
    FMResultSet *rs = [mdb executeQuery:sql,model.name];
    while ([rs next]) {
        return YES;
    }
    return NO;
}
//插入单个省份数据
-(void)insertProvinceItem:(RMPublicModel *)item andListName:(NSString *)listName
{
   if([mdb open]){
        if([self isExistProvinceItem:item FromListName:listName])
        {
            [self deleteItem:item fromListName:listName];
        }
        if([self itemcountFromListName:listName]>20){
            [self deletFristItem];
        }
       [mdb open];
        NSString *sql = [NSString stringWithFormat:@"insert into %@ (titleName,titleImage,movieURL,playTime) values (?,?,?,?)",listName];
        if([mdb executeUpdate:sql,item.name,item.pic_url,item.reurl,item.playTime])
        {
            NSLog(@"插入成功");
        }
        else
        {
            NSLog(@"插入失败:%@",[mdb lastErrorMessage]);
        }
    }
    [mdb close];

}
- (void)insertDownLoadItem:(RMPublicModel *)item{
    if([mdb open]){
        //titleName,titleImage,downURL,downStatus,totalMemory,alreadDownLoad,downLoadProgress
        NSString *sql = [NSString stringWithFormat:@"insert into DownLoadListname (titleName,titleImage,totalMemory) values (?,?,?)"];
        if([mdb executeUpdate:sql,item.name,item.pic,item.totalMemory])
        {
            NSLog(@"插入成功");
        }
        else
        {
            NSLog(@"插入失败:%@",[mdb lastErrorMessage]);
        }
    }
    [mdb close];
}

- (void)insertDownLoadArray:(NSArray *)array{
    if([mdb open]){
        [mdb beginTransaction];
            for(RMPublicModel *item in array)
            {
                [self insertDownLoadItem:item];
            }
        [mdb commit];
    }
    [mdb close];

}
//多条数据插入
-(void)insertArray:(NSArray *)array toListName:(NSString *)listName{
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
-(NSInteger)itemcountFromListName:(NSString *)listName
{
    if([mdb open]){
        NSString *sql = nil;
        if([listName isEqualToString:PLAYHISTORYLISTNAME])
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

//读取数据
-(NSArray *)readitemFromListName:(NSString *)listName
{
    if([mdb open]){
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        
        NSString *sql = nil;
        
        if([listName isEqualToString:PLAYHISTORYLISTNAME]){
            sql = [NSString stringWithFormat:@"select titleName,titleImage,movieURL,playTime from %@",PLAYHISTORYLISTNAME];
        }
        FMResultSet *rs = [mdb executeQuery:sql];
        
        if([listName isEqualToString:PLAYHISTORYLISTNAME]){
            while ([rs next]) {
                RMPublicModel *item = [[RMPublicModel alloc] init];
                item.name = [rs stringForColumn:@"titleName"];
                item.pic_url = [rs stringForColumn:@"titleImage"];
                item.reurl = [rs stringForColumn:@"movieURL"];
                item.playTime = [rs stringForColumn:@"playTime"];
                [array addObject:item];
            }

        }
        [mdb close];
        return array;
    }
    [mdb close];
    return nil;
    
}

- (NSArray *)readItemFromDownLoadList{
    if([mdb open]){
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        
        NSString *sql = [NSString stringWithFormat:@"select titleName,titleImage,totalMemory from DownLoadListname"];
        FMResultSet *rs = [mdb executeQuery:sql];
        
        while ([rs next]) {
            RMPublicModel *item = [[RMPublicModel alloc] init];
            item.name = [rs stringForColumn:@"titleName"];
            item.pic = [rs stringForColumn:@"titleImage"];
            item.totalMemory = [rs stringForColumn:@"totalMemory"];
            [array addObject:item];
        }
        
        [mdb close];
        return array;
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

//
//  DataBase.m
//  HYSEM
//
//  Created by 王一成 on 2017/5/15.
//  Copyright © 2017年 WGM. All rights reserved.
//

//
//  DataBase.m
//  EveryDayTravel
//
//  Created by 王一成 on 16/4/12.
//  Copyright © 2016年 王一成. All rights reserved.
//

#import "DataBase.h"

#import "FMDatabase.h"

#import "AppUtil.h"

#import "orderModel.h"

#import "UserModel.h"

@interface DataBase()

@property (nonatomic,retain)FMDatabase *FMDB_t;

@end

@implementation DataBase

DEFINE_SINGLETON_FOR_CLASS(DataBase);

#pragma mark - 创建数据库（存储在沙盒的/Library/Caches/目录下）

-(id)init
{
    if (self ==[super init]) {
        
    }
    return self;
}

-(void)createDatabase
{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSString * oldPath = [NSString stringWithFormat:@"%@Car.db",[AppUtil getCachesPath]];
    //数据库地址
    NSFileManager * fileM = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@Car.db",[AppUtil getCachesPath]];
    NSLog(@"%@",path);
    if (!self.FMDB_t) {
        self.FMDB_t = [FMDatabase databaseWithPath:path];
    }
    if ([fileM fileExistsAtPath:path]) {
        DLog(@"数据库已存在");
    }else{
        if ([self.FMDB_t open]) {
            NSLog(@"数据库打开成功");
            [self createUserTable];
        }else{
            NSLog(@"数据库打开失败");
        }
    }
}


#pragma mark - 创建商品表
/**
 *商品表订单IDtext，用户IDtext，支付金额text，电表IDtext，支付状态integer，提交状态integer,生成时间text，支付方式integer
 *
 */
- (void)createGoodsTable
{
    [self.FMDB_t open];
    [self.FMDB_t executeUpdate:@"create table Goods(keyID integer primary key autoincrement, GoodsId text,userID text,deviceID text,Fee text,tag integer,commitTag integer,createTime text,paySelected integer)"];
    
    NSLog(@"数据库表Goods - 创建成功");
    [self.FMDB_t close];
}

- (void)createUserTable
{
    [self.FMDB_t open];
    [self.FMDB_t executeUpdate:@"create table User(keyID integer primary key autoincrement, userID text,userName text,userPassWord text,tag text)"];
    
    NSLog(@"数据库表Goods - 创建成功");
    [self.FMDB_t close];
}

#pragma mark - 删除商品表
- (void)deleteGoodsTable
{
    [self.FMDB_t open];
    [self.FMDB_t executeUpdate:@"delete table Goods"];
    NSLog(@"删除成功");
    [self.FMDB_t close];
    
}

#pragma mark - 删除商品表中所有条数据
- (void)deleteAllGoods
{
    [self.FMDB_t open];
    [self.FMDB_t executeUpdate:@"delete from Goods"];
    NSLog(@"表中数据已全部删除");
    [self.FMDB_t close];
}

#pragma mark - 修改商品数量

- (void)changeJoinTimesADDWithGoodsGHID:(NSString *)ghid andAddNum:(NSInteger)num
{
    [self.FMDB_t open];
    [self.FMDB_t close];
}
/*商品数量 ＋1 */
-(void)changeJoinTimesSUBWithGoodsGHID:(NSString *)ghid andCutNum:(NSInteger)num
{
    [self.FMDB_t open];
    
    [self.FMDB_t executeUpdate:@"update Goods set GoodsJoinTimes = (GoodsJoinTime -?) where GoodsGHID = ?",[NSNumber numberWithInteger:num],ghid];
    [self.FMDB_t close];
}

/**  商品数量修改  **/
- (void)changeJoinTimesWithGoodsGHID:(NSString *)ghid andGoodsJoinTimes:(NSString *)joinTimes
{
    [self.FMDB_t open];
    
    [self.FMDB_t executeUpdate:@"update Goods set GoodsJoinTimes = ? where GoodsGHID = ?",joinTimes,ghid];
    
    [self.FMDB_t close];
}

#pragma mark -删除一条数据

- (void)cancelUserWithUsrID:(NSString *)UserID
{
    [self.FMDB_t open];
    BOOL success = [self.FMDB_t executeUpdate:@"delete from User where userID = ?",UserID];
    DLog(@"删除数据%d",success);
}
- (void)cancelGoodsWithGHID:(NSString *)orderID
{
    [self.FMDB_t open];
    [ self.FMDB_t executeUpdate:@"delete from Goods where GoodsId =?",orderID];
    DLog(@"%@已经移除",orderID);
    [self.FMDB_t close];
}

#pragma mark - 判断数据是否存在
-(BOOL)GoodsIsExistInDataBaseWith:(NSString *)ghid
{
    [self.FMDB_t open];
    FMResultSet *result = [self.FMDB_t executeQuery:@"select * from Goods"];
    
    while ([result next]) {
        if ([[result stringForColumn:@"GoodsId"] isEqualToString:ghid]) {
            NSLog(@"已存在");
            return YES;
            
        }
    }
    [self.FMDB_t close];
    return NO;
}

-(BOOL)UserIsExistInDataBaseWith:(NSString *)ghid
{
    [self.FMDB_t open];
    FMResultSet *result = [self.FMDB_t executeQuery:@"select * from User"];
    
    while ([result next]) {
        if ([[result stringForColumn:@"userID"] isEqualToString:ghid]) {
            NSLog(@"已存在");
            return YES;
            
        }
    }
    [self.FMDB_t close];
    return NO;
}

#pragma mark - 查找返回数组用作"购物车"数据源

-(NSArray *)selectAllGoods
{
    [self.FMDB_t open];
    NSMutableArray * itemArray = [[NSMutableArray alloc] init];
    
    FMResultSet * result = [self.FMDB_t executeQuery:@"select * from Goods"];
    
    while ([result next]) {
        NSString * userID         = [result stringForColumn:@"userID"];/** y用户ID*/
        NSString * deviceID       = [result stringForColumn:@"deviceID"];/** 设备ID*/
        NSString * fee       = [result stringForColumn:@"Fee"];/** 支付金额*/
        int tag   = [result intForColumn:@"tag"];/** 支付状态*/
        int commit = [result intForColumn:@"commitTag"];/** 上传服务器状态*/
        NSString *createTime = [result stringForColumn:@"createTime"];/** 创建时间*/
        int paySelected = [result intForColumn:@"paySelected"];/** 支付方式*/
        NSString * GoodsId = [result stringForColumn:@"GoodsId"];/** 订单ID*/
        int keyID = [result intForColumn:@"keyID"];
        DLog(@"打印表中所有数据 - 第%d条",keyID);
        orderModel * model = [[orderModel alloc] initWithOrderID:GoodsId andUserID:userID andFee:fee andDeviceID:deviceID andTag:tag andCommit:commit andCreateTime:createTime andPaySelecte:paySelected];
     
//        
        [itemArray addObject:model];
        //  create table Goods(GoodsId integer primary key autoincrement,GoodsGHID text,GoodsImgUrl text,GoodsTitle text,GoodsPrice text,GoodsRemainCount text,GoodsJoinTimes integer,GoodsJoinPeriods integer
        
        //        [itemArray addObject:@"1,"];
    }
    [self.FMDB_t close];
    return itemArray;
    
}

-(NSArray *)selectAllUser
{
    [self.FMDB_t open];
    NSMutableArray * itemArray = [[NSMutableArray alloc] init];
    
    FMResultSet * result = [self.FMDB_t executeQuery:@"select * from User"];
    //[self.FMDB_t executeUpdate:@"create table User(keyID integer primary key autoincrement, userID text,userName text,userPassWord text,tag integer)"];
    while ([result next]) {
        NSString * userID         = [result stringForColumn:@"userID"];/** y用户ID*/
        NSString * deviceID       = [result stringForColumn:@"userName"];/** 设备ID*/
        NSString * fee       = [result stringForColumn:@"userPassWord"];/** 支付金额*/
        NSString * tag   = [result stringForColumn:@"tag"];/** 支付状态*/
        //
        UserModel * userModel = [[UserModel alloc] init];
        userModel.userId = userID;
        userModel.userName = deviceID;
        userModel.passWord = fee;
        userModel.tag = tag;
        [itemArray addObject:userModel];
        //  create table Goods(GoodsId integer primary key autoincrement,GoodsGHID text,GoodsImgUrl text,GoodsTitle text,GoodsPrice text,GoodsRemainCount text,GoodsJoinTimes integer,GoodsJoinPeriods integer
        
        //        [itemArray addObject:@"1,"];
    }
    [self.FMDB_t close];
    return itemArray;
    
}


#pragma mark - 获取购物车种商品种类数量
-(NSInteger *)selectAllGoodsCount
{
    [self.FMDB_t open];
    NSInteger * count = 0;
    FMResultSet * result = [self.FMDB_t executeQuery:@"select * from Goods"];
    while ([result next]) {
        count ++;
    }
    [self.FMDB_t close];
    
    return count;
}

#pragma mark - 为商品表中添加一条数据
- (void)insertGoodsWithOredrID:(NSString *)orderID
                   andUserID:(NSString *)userID
                   andDeviceID:(NSString *)deviceID
                   andFee:(NSString *)fee
                   andtag:(NSInteger)tag
                   andCommit:(int)commit
                   andCreateTime:(NSString *)createTime
                   andPaySelected:(NSInteger)paySelected
{
    [self.FMDB_t open];
    //    GoodsId text primary key,userID text,deviceID text,Fee text,tag integer,commit integer,createTime text,paySelected integer
    BOOL success = [self.FMDB_t executeUpdate:@"insert into Goods(GoodsId,userID,deviceID,Fee,tag,commitTag,createTime,paySelected) values(?,?,?,?,?,?,?,?)",orderID,userID,deviceID,fee,[NSNumber numberWithInteger:tag],[NSNumber numberWithInt:commit],createTime,[NSNumber numberWithInteger:paySelected]];
    DLog(@"%d",success);
    //    HS_Log(@"数据插入成功__%@__%@",title,ghid);
    [self.FMDB_t close];
}

- (void)insertUserWithUserID:(NSString *)userID
                     andUserName:(NSString *)name
                   andUserPassword:(NSString *)password
                        andTag:(NSString *)tag
{
    [self.FMDB_t open];
    //[self.FMDB_t executeUpdate:@"create table User(keyID integer primary key autoincrement, userID text,userName text,userPassWord text,tag integer)"];
    //    GoodsId text primary key,userID text,deviceID text,Fee text,tag integer,commit integer,createTime text,paySelected integer
    if (![self UserIsExistInDataBaseWith:userID]) {
        [self.FMDB_t open];
        BOOL success = [self.FMDB_t executeUpdate:@"insert into User(userID,userName,userPassWord,tag) values(?,?,?,?)",userID,name,password,tag];
        DLog(@"插入用户档案%d",success);
    }else{
        [self.FMDB_t open];
        BOOL success = [self.FMDB_t executeUpdate:[NSString stringWithFormat:@"UPDATE User SET userPassWord= '%@', tag= '%@' WHERE userID = '%@'",password,tag,userID]];
        DLog(@"修改用户档案%d",success);
    }
    //    HS_Log(@"数据插入成功__%@__%@",title,ghid);
    [self.FMDB_t close];
}


#pragma mark - 结果集
- (void)selectAllGoodsResult
{
    [self.FMDB_t open];
    
    //    FMResultSet *res = [self.FMDB_t executeQuery:@"select *from Goods where GoodsId=?",[NSNumber numberWithInt:1]];
    FMResultSet *result = [self.FMDB_t executeQuery:@"select *from Goods"];
    //每一次循环是一行数据
    while ([result next])
    {
        //    GoodsId text primary key,userID text,deviceID text,Fee text,tag integer,commit integer,createTime text,paySelected integer
        NSString * userID         = [result stringForColumn:@"userID"];/** y用户ID*/
        NSString * deviceID       = [result stringForColumn:@"deviceID"];/** 设备ID*/
        NSString * fee       = [result stringForColumn:@"Fee"];/** 支付金额*/
        int tag   = [result intForColumn:@"tag"];/** 支付状态*/
        int joinPeriods = [result intForColumn:@"commitTag"];/** 上传服务器状态*/
        NSString *createTime = [result stringForColumn:@"createTime"];/** 创建时间*/
        int joinPeriods1 = [result intForColumn:@"paySelected"];/** 支付方式*/
        int GoodsId = [result intForColumn:@"GoodsId"];/** 订单ID*/
        int keyID = [result intForColumn:@"keyID"];
        DLog(@"打印表中所有数据 - 第%d条",keyID);
        //        NSLog(@"%@ |  %@|  %@|  %@|  %@|  %@|  %@|  %@| %@|",ghid,issue,Img,title,price,sumCount,remainCount,joinTimes,joinPeriods);
    }
    
    [self.FMDB_t close];
}
@end


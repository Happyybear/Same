//
//  DataBaseManager.m
//  ZeroGo
//
//  Created by colorPen on 15/7/28.
//  Copyright (c) 2015年 colorful. All rights reserved.
//

#import "DataBaseManager.h"
#import "orderModel.h"
#import "DataBase.h"
#import "UserModel.h"
@implementation DataBaseManager

DEFINE_SINGLETON_FOR_CLASS(DataBaseManager);


#pragma mark - 创建数据库（存储在沙盒的/Library/Caches/目录下）
- (void)createDatabase
{
    [[DataBase sharedDataBase] createDatabase];
}

#pragma mark - 创建商品表
- (void)createGoodsTable
{
    [[DataBase sharedDataBase] createGoodsTable];
}

#pragma mark - 删除商品表
- (void)deleteGoodsTable
{
    [[DataBase sharedDataBase] deleteGoodsTable];
}

#pragma mark - 删除商品表中所有条数据
- (void)deleteAllGoods
{
    [[DataBase sharedDataBase] deleteAllGoods];
}

#pragma mark - 为商品表中添加一条数据
- (void)insertGoodsWithModel:(id)normalModel
{
    orderModel * model = (orderModel*)normalModel;
    [[DataBase sharedDataBase] insertGoodsWithOredrID:model.orderID andUserID:model.userID andDeviceID:model.deviceID andFee:model.fee andtag:model.tag andCommit:model.commit andCreateTime:model.createTime andPaySelected:model.paySelected];
}

#pragma mark - 为用户表中添加一条数据
- (void)insertUserWithModel:(id)normalModel
{
    UserModel * model = (UserModel*)normalModel;
    [[DataBase sharedDataBase] insertUserWithUserID:model.userId andUserName:model.userName andUserPassword:model.passWord andTag:model.tag];
}

#pragma mark - 删除一条数据
- (void)cancelGoodsWithGHID:(NSString *)ghid
{
    [[DataBase sharedDataBase] cancelGoodsWithGHID:ghid];
}
- (void)cancelUserWithUsrID:(NSString *)UserID
{
    [[DataBase sharedDataBase] cancelUserWithUsrID:UserID];
}

#pragma mark - 查找返回数组用作"购物车"数据源
- (NSArray *)selectAllGoods
{
    return [[DataBase sharedDataBase] selectAllGoods];
}

- (NSInteger *)selectAllGoodsCount
{
    return [[DataBase sharedDataBase] selectAllGoodsCount];
}

#pragma mark - 查找返回数组用作"用户"数据源
- (NSArray *)selectAllUser
{
    return [[DataBase sharedDataBase] selectAllUser];
}

#pragma mark - 结果集
- (void)selectAllGoodsResult
{
    [[DataBase sharedDataBase] selectAllGoodsResult];
}

#pragma mark - 用户结果集
//- (void)selectAllGoodsResult
//{
//    [[DataBase sharedDataBase] selectAllResult];
//}

#pragma mark - 判断数据是否存在
- (BOOL)GoodsIsExistInDataBaseWith:(NSString *)ghid
{
    return [[DataBase sharedDataBase]GoodsIsExistInDataBaseWith:ghid];
}

- (BOOL)UserIsExistInDataBaseWith:(NSString *)ghid
{
    return [[DataBase sharedDataBase]UserIsExistInDataBaseWith:ghid];
}

@end

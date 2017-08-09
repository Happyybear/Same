//
//  DataBaseManager.h
//  ZeroGo
//
//  Created by colorPen on 15/7/28.
//  Copyright (c) 2015年 colorful. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"

@interface DataBaseManager : NSObject

DEFINE_SINGLETON_FOR_HEADER(DataBaseManager);


#pragma mark - 创建数据库（存储在沙盒的/Library/Caches/目录下）
- (void)createDatabase;

#pragma mark - 创建商品表
- (void)createGoodsTable;

#pragma mark - 删除商品表
- (void)deleteGoodsTable;

#pragma mark - 删除商品表中所有条数据
- (void)deleteAllGoods;

#pragma mark - 为商品表中添加一条数据
- (void)insertGoodsWithModel:(id)normalModel;
- (void)insertUserWithModel:(id)userModel;

#pragma mark - 删除一条数据
- (void)cancelGoodsWithGHID:(NSString *)ghid;
- (void)cancelUserWithUsrID:(NSString *)UserID;
#pragma mark - 查找返回数组用作"购物车"数据源
- (NSArray *)selectAllGoods;
- (NSArray *)selectAllUser;
- (NSInteger *)selectAllGoodsCount;

#pragma mark - 结果集
- (void)selectAllGoodsResult;

#pragma mark - 判断数据是否存在
- (BOOL)GoodsIsExistInDataBaseWith:(NSString *)ghid;
- (BOOL)UserIsExistInDataBaseWith:(NSString *)ghid;

@end

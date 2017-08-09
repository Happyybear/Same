//
//  DataBase.h
//  HYSEM
//
//  Created by 王一成 on 2017/5/15.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBase : NSObject


DEFINE_SINGLETON_FOR_HEADER(DataBase);

#pragma mark - 创建数据库（存储在沙盒的/Library/Caches/目录下）
- (void)createDatabase;

#pragma mark - 创建商品表
- (void)createGoodsTable;

#pragma mark - 删除商品表
- (void)deleteGoodsTable;

#pragma mark - 删除商品表中所有条数据
- (void)deleteAllGoods;

#pragma mark - 为商品表中添加一条数据
- (void)insertGoodsWithOredrID:(NSString *)orderID
                     andUserID:(NSString *)userID
                   andDeviceID:(NSString *)deviceID
                        andFee:(NSString *)fee
                        andtag:(NSInteger)tag
                     andCommit:(int)commit
                 andCreateTime:(NSString *)createTime
                andPaySelected:(NSInteger)paySelected
;

#pragma mark - 修改商品数量
/**  商品数量 + 1 */
- (void)changeJoinTimesADDWithGoodsGHID:(NSString *)ghid andAddNum:(NSInteger)num;
/**  商品数量 + 1 */
- (void)changeJoinTimesSUBWithGoodsGHID:(NSString *)ghid andCutNum:(NSInteger)num;
/**  商品数量修改  **/
- (void)changeJoinTimesWithGoodsGHID:(NSString *)ghid andGoodsJoinTimes:(NSString *)joinTimes;


/**  商品期数修改  **/
- (void)changeJoinPeriodsWithGoodsGHID:(NSString *)ghid andGoodsJoinPeriods:(NSString *)joinPeriods;

- (void)changeJoinPeriodsADDWithGoodsGHID:(NSString *)ghid;

- (void)changeJoinPeriodsSUBWithGoodsGHID:(NSString *)ghid;

#pragma mark - 删除一条数据
- (void)cancelGoodsWithGHID:(NSString *)ghid;
- (void)cancelUserWithUsrID:(NSString *)UserID;

#pragma mark - 查找返回数组用作"购物车"数据源
- (NSArray *)selectAllGoods;
- (NSInteger *)selectAllGoodsCount;

#pragma mark - 结果集
- (void)selectAllGoodsResult;

#pragma mark - 判断数据是否存在
- (BOOL)GoodsIsExistInDataBaseWith:(NSString *)ghid;


#pragma mark - **************** 用户
- (void)insertUserWithUserID:(NSString *)userID
                 andUserName:(NSString *)name
             andUserPassword:(NSString *)password
                      andTag:(NSString *)tag;

-(NSArray *)selectAllUser;

-(BOOL)UserIsExistInDataBaseWith:(NSString *)ghid;


@end

//
//  orderModel.h
//  HYSEM
//
//  Created by 王一成 on 2017/5/18.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <Foundation/Foundation.h>
//商品表订单IDtext，用户IDtext，支付金额text，电表IDtext，支付状态integer，提交状态integer,生成时间text，支付方式integer
@interface orderModel : NSObject

@property (nonatomic,copy) NSString * orderID;
@property (nonatomic,copy) NSString * userID;
@property (nonatomic,copy) NSString * fee;
@property (nonatomic,copy) NSString * deviceID;
@property (nonatomic,copy) NSString * deviceName;
@property (nonatomic,assign) int tag;
@property (nonatomic,assign) int commit;
@property (nonatomic,copy) NSString * createTime;
@property (nonatomic,assign) int  paySelected;
@property (nonatomic,copy) NSString * SemAPP_ID;
@property (nonatomic,copy) NSString * private_key;


- (id)initWithOrderID:(NSString *)orderID andUserID:(NSString *)userID andFee:(NSString* )fee andDeviceID:(NSString *)deviceID andTag:(int)tag andCommit:(int)commit andCreateTime:(NSString *)time andPaySelecte:(int) paySelect;
@end

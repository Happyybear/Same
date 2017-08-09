//
//  ViewController.h
//  IM
//
//  Created by 王一成 on 2017/4/10.
//  Copyright © 2017年 Yicheng.Wang. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "Order.h"
#import "orderModel.h"

@interface PaymentMethod : NSObject

/**
 *上传订单信息到服务器
 *
 **/
@property (nonatomic,copy) void(^upLoadOrderToSrvice)(NSString * fee);

+ (PaymentMethod *)sharedInstance;
/**
 *  支付宝支付
 */
- (void)excuteAlipayWithOrederString:(NSString *)order andFee:(NSString *)price andDeviceID:(NSString *)deviceID;
- (Order *)doAlipayPayWithOrder:(orderModel *)orderModel;
/**
 *  微信支付
 */
- (void)doWXPayWithOrder:(orderModel *)orderModel_data;


@end

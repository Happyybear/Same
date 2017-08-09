//
//  ViewController.h
//  IM
//
//  Created by 王一成 on 2017/4/10.
//  Copyright © 2017年 Yicheng.Wang. All rights reserved.
//

#import "PaymentMethod.h"

#import "WXApi.h"

#import "WXUtil.h"

#import "payRequsestHandler.h"

#import <AlipaySDK/AlipaySDK.h>

#import "RSADataSigner.h"

#import "AppDelegate.h"

#import "DataBaseManager.h"


@interface PaymentMethod()<WXApiDelegate>

@end

@implementation PaymentMethod


+ (PaymentMethod *)sharedInstance
{
    static PaymentMethod *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

#pragma mark   ==============点击订单模拟支付行为==============
//
//选中商品调用支付宝极简支付
//

//- (NSString *)getTradeNO{
//    NSString * order = [[NSString alloc] init];
//    if ([HY_NSusefDefaults objectForKey:@"orderID"]) {
//        NSDate *date = [NSDate date];
//        NSTimeInterval time = [date timeIntervalSince1970];
//        float sec = time - [[HY_NSusefDefaults objectForKey:@"orderIDCreateTime"] floatValue];
//        if (sec < 29*60 ) {//29min后订单废弃
//            order = [HY_NSusefDefaults objectForKey:@"orderID"];
//        }else{
//            order = [self generateTradeNO];
//        }
//    }else{
//        order = [self generateTradeNO];
//    }
//    return order;
//}
//
//- (NSString *)generateTradeNO
//{
//    HYSingleManager *manager = [HYSingleManager sharedManager];
//    HYUserModel * user =  manager.user;
//    NSDate * date = [NSDate date];
//    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
//    NSString * currentDate = [dateFormatter stringFromDate:date];
//    NSMutableString * useID = [[NSMutableString alloc] initWithFormat:@"%llu",user.user_ID];
//    NSString * userString = [useID substringWithRange:NSMakeRange(0, 13)];
//    NSString * order = [[NSString alloc] initWithFormat:@"%@%@",userString,currentDate ];
//    [HY_NSusefDefaults setObject:order forKey:@"orderID"];
//    NSTimeInterval time = [date timeIntervalSince1970];
//    NSString * timeString = [[NSString alloc] initWithFormat:@"%f",time];
//    [HY_NSusefDefaults setObject:timeString forKey:@"orderIDCreateTime"];//保存订单创建时间
//    return order;
//}

#pragma mark - **************** 存数据库
- (void)saveToDBWithOrder:(orderModel *)order
{
    DataBaseManager * dbManager = [DataBaseManager sharedDataBaseManager];
    NSString * timeString = [HY_NSusefDefaults objectForKey:@"orderIDCreateTime"];//保存订单创建时间
    HYSingleManager * single = [HYSingleManager sharedManager];
    orderModel * model = [[orderModel alloc] initWithOrderID:order.orderID andUserID:[NSString stringWithFormat:@"%lld",single.user.user_ID] andFee:order.fee andDeviceID:order.deviceID andTag:0 andCommit:0 andCreateTime:timeString andPaySelecte:0];// ------0表示未处理状态
    [dbManager insertGoodsWithModel:model];
}
//
//- (void)excuteAlipayWithOrederString:(NSString *)order andFee:(NSString *)price andDeviceID:(NSString *)deviceID
//{
////    order = @"app_id=2017041906817095&biz_content=%7B%22timeout%5Fexpress%22%3A%2230m%22%2C%22seller%5Fid%22%3A%22m18605316655%40163.com%22%2C%22product%5Fcode%22%3A%22QUICK%5FMSECURITY%5FPAY%22%2C%22total%5Famount%22%3A%2200000002.00%22%2C%22subject%22%3A%22%E5%A4%A7%E4%B9%90%E9%80%8F%22%2C%22body%22%3A%22%E6%8F%8F%E8%BF%B0%E4%BF%A1%E6%81%AF%22%2C%22out%5Ftrade%5Fno%22%3A%22008f007c00560048003400a8006600bd%22%7D&charset=UTF-8&method=alipay.trade.app.pay&sign=mXesT7n8KdyqaHEZ0PJEoXGrZlkx00B1hqP1nuP1dZPd5npfshnE80gI%2FG84f7OOAbmalu033dtRpA%2BEgzplPE7N%2FY0ib7dR1HUrUKLYIOGu6ZSHgTTTPl9bsL2%2FbRPjJd7Ahzvfv4SQvGiIytxMdU2JZNc9vdLYScp4TytUEWh2fEsqPs6RM%2BLRlFtUpYaN2BVntLZKaJFDuEJO1vsJTtJRdUksRqbpOsrik%2BAtl9bezZqtwtU9ahVV9L8N22Zt2XLr6mt02I1DyCFwqxqVEAw0S%2FYJ8rWXuj5jHkKfgIqx65xA8%2BUnBWJde5v%2F7TisMYbvVgBN0tbTfInLFxG6kQ%3D%3D&sign_type=RSA2&timestamp=2017-07-11%2016%3A52%3A23&version=1.0";
////
//    if (order) {
//        NSString *appScheme = @"SEM";
//        [[AlipaySDK defaultService] payOrder:order fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//            NSLog(@"reslut = %@",resultDic);
//            NSNumber *resultStatus = resultDic[@"resultStatus"];
//            if (9000 == [resultStatus integerValue])
//            {//支付成功
////                [self saveToDBWithOrder:or];
//                NSLog(@"支付成功__未安装回调__1111");
//                // 支付成功
//                //                CGRect rectLabel = CGRectMake((WIDTH - 150)/2, 150, 150, 50);
//                //                [Visitor_AppFunction showLabelWithFrame:rectLabel andTitle:@"充值成功" andComplete:^{
//                //
//                //                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                //     |               if (app.PaySuccessBlock) {
//                //                        app.PaySuccessBlock();
//                //                    }
//                //
//                //                }];
//                self.upLoadOrderToSrvice(price);
//                //                [HY_NSusefDefaults setObject:nil forKey:@"orderID"];//订单支付成功，需重新生成
//            }
//            else if (4000 == [resultStatus integerValue])
//            {//订单支付失败
//                NSLog(@"支付宝充值失败__%@",resultDic);
//                NSString *resultStr = resultDic[@"memo"];
//                if (!resultStr.length) {
//                    resultStr = @"支付失败";
//                }
//                //支付失败，弹出支付宝返回的失败原因
//                //                [UIAlertView alertWithTitle:nil
//                //                                    message:resultStr
//                //                              cancelBtnName:@"确定"
//                //                              callBackBlock:nil];
//                [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
//            }
//            else if (6001 == [resultStatus integerValue])
//            {//用户中途取消
//                DLog(@"用户中途取消");
////                [[NSNotificationCenter defaultCenter] postNotificationName:@"payResult" object:@"Failed" userInfo:@{@"status":@"Failed"}];
//                [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
//            }
//            else if (5000 == [resultStatus integerValue])
//            {//重复请求
//                [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
//            }
//            else if (6002 == [resultStatus integerValue])
//            {
//                //网络连接出错
//                [UIView addMJNotifierWithText:@"网路连接错误" dismissAutomatically:YES];
//            }
//            else if (8000 == [resultStatus integerValue])
//            {
//                //正在处理，结果未知（服务器请求异步通知支付结果）
//                //这里需要向服务器请求支付结果
////                [self saveToDBWithFee:price andDeviceID:deviceID];
//                self.upLoadOrderToSrvice(price);
//            }
//            else if (6004 == [resultStatus integerValue])
//            {
//                //支付结果未知（服务器请求异步通知结果）
//                //这里需要向服务器请求支付结果
////                [self saveToDBWithFee:price andDeviceID:deviceID];
//                self.upLoadOrderToSrvice(price);
//            }
//            else
//            {
//                //其他支付错误
//                [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
//            }
//            
//        }];
//
//    }
//}

- (Order *)doAlipayPayWithOrder:(orderModel *)orderModel_data
{
    //将订单存到数据库
    [self saveToDBWithOrder:orderModel_data];
    //重要说明
    //这里只是为了方便直接向商户展示支付宝的整个支付流程；所以Demo中加签过程直接放在客户端完成；
    //真实App里，privateKey等数据严禁放在客户端，加签过程务必要放在服务端完成；
    //防止商户私密数据泄露，造成不必要的资金损失，及面临各种安全风险；
    /*============================================================================*/
    /*=======================需要填写商户app申请的===================================*/
    /*============================================================================*/
    NSString *appID = orderModel_data.SemAPP_ID;

    // 如下私钥，rsa2PrivateKey 或者 rsaPrivateKey 只需要填入一个
    // 如果商户两个都设置了，优先使用 rsa2PrivateKey
    // rsa2PrivateKey 可以保证商户交易在更加安全的环境下进行，建议使用 rsa2PrivateKey
    // 获取 rsa2PrivateKey，建议使用支付宝提供的公私钥生成工具生成，
    // 工具地址：https://doc.open.alipay.com/docs/doc.htm?treeId=291&articleId=106097&docType=1
    NSString *rsa2PrivateKey = orderModel_data.private_key;
//
    NSString *rsaPrivateKey = @"";
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([appID length] == 0 ||
        ([rsa2PrivateKey length] == 0 && [rsaPrivateKey length] == 0))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"缺少appId或者私钥。"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order* order = [Order new];
    
    // NOTE: app_id设置
    order.app_id = appID;
    
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    
    // NOTE: 参数编码格式
    order.charset = @"UTF-8";
    
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    // NOTE: 支付版本
    order.version = @"1.0";
    
    // NOTE: sign_type 根据商户设置的私钥来决定
    order.sign_type = (rsa2PrivateKey.length > 1)?@"RSA2":@"RSA";
    
    // NOTE: 商品数据
    order.biz_content = [BizContent new];
    order.biz_content.body = @"描述信息";
    order.biz_content.subject = @"电费";
    order.biz_content.out_trade_no = orderModel_data.orderID; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = @"30m"; //超时时间设置
    order.biz_content.total_amount = orderModel_data.fee; //商品价格
//    order.biz_content.seller_id = @"m18605316655@163.com";
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    NSLog(@"orderSpec = %@",orderInfo);
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    //    NSString *signedString = nil;

    RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:((rsa2PrivateKey.length > 1)?rsa2PrivateKey:rsaPrivateKey)];
    NSString *signedString = nil;
    if ((rsa2PrivateKey.length > 1)) {
        signedString = [signer signString:orderInfo withRSA2:YES];
    } else {
        signedString = [signer signString:orderInfo withRSA2:NO];
    }
    //将相关订单信息存入沙盒
    NSArray * info = @[@[@"",orderModel_data.orderID,order.timestamp,@"支付宝"],@[orderModel_data.fee]];
    NSString *documentPath = DOCUMENTPATH;
    NSString * path = [documentPath stringByAppendingString:@"/flie.plist"];
    [NSKeyedArchiver archiveRootObject:info toFile:path];
    
    
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"SEM";
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded, signedString];
        DLog(@"%@",orderString);
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
            NSNumber *resultStatus = resultDic[@"resultStatus"];
            if (9000 == [resultStatus integerValue])
            {//支付成功
                
                NSLog(@"支付成功__未安装回调__1111");
                // 支付成功
                self.upLoadOrderToSrvice(orderModel_data.fee);
            }
            else if (4000 == [resultStatus integerValue])
            {//订单支付失败
                NSLog(@"支付宝充值失败__%@",resultDic);
                NSString *resultStr = resultDic[@"memo"];
                if (!resultStr.length) {
                    resultStr = @"支付失败";
                }
                //支付失败，弹出支付宝返回的失败原因
                //                [UIAlertView alertWithTitle:nil
                //                                    message:resultStr
                //                              cancelBtnName:@"确定"
                //                              callBackBlock:nil];
                [[DataBaseManager sharedDataBaseManager] deleteAllGoods];
                [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
            }
            else if (6001 == [resultStatus integerValue])
            {//用户中途取消
                DLog(@"用户中途取消");
                [[DataBaseManager sharedDataBaseManager] deleteAllGoods];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"payResult" object:@"Failed" userInfo:@{@"status":@"Failed"}];
                [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
            }
            else if (5000 == [resultStatus integerValue])
            {//重复请求
                [[DataBaseManager sharedDataBaseManager] deleteAllGoods];
                [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
            }
            else if (6002 == [resultStatus integerValue])
            {
                //网络连接出错
                [[DataBaseManager sharedDataBaseManager] deleteAllGoods];
                [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
            }
            else if (8000 == [resultStatus integerValue])
            {
                //正在处理，结果未知（服务器请求异步通知支付结果）
                //这里需要向服务器请求支付结果
                self.upLoadOrderToSrvice(orderModel_data.fee);
                [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
            }
            else if (6004 == [resultStatus integerValue])
            {
                //支付结果未知（服务器请求异步通知结果）
                //这里需要向服务器请求支付结果
                self.upLoadOrderToSrvice(orderModel_data.fee);
                [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
            }
            else
            {
                [[DataBaseManager sharedDataBaseManager] deleteAllGoods];
                //其他支付错误
                [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
            }
            
        }];
    }
    return order;
    //orederInfo传给服务器
}

/**
 *  @param partnerID - 商家ID
 *  @param sellerID - 支付宝收款账号
 *  @param tradeNO - 订单ID,不能是自己随机生成的,要和后台id对应
 *  @param productName - 商品标题
 *  @param productDescription - 商品描述
 *  @param amount - 商品价格
 *  @param notifyUrl - 回调地址
 */
- (void)myAlipayWithPartnerID:(NSString *)partnerID
                     sellerID:(NSString *)sellerID
                      TradeNO:(NSString *)tradeNO
                  ProductName:(NSString *)productName
           productDescription:(NSString *)productDescription
                       Amount:(float)amount
                    notifyURL:(NSString *)notifyUrl
{
    /*=======================需要填写商户app申请的=========================*/
    NSString *rsa2PrivateKey = @"";
    NSString *rsaPrivateKey =@"";
    //测试使用时删掉
    /*============================================================================*/
    
    /**
     *  生成订单信息及签名
     *
    //将商品信息赋予AlixPayOrder的成员变量
    *生成订单信息及签名
    */
    //将商品信息赋予AlixPayOrder的成员变量
    Order* order = [Order new];
    
    // NOTE: app_id设置
    order.app_id = APPID;
    
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    
    // NOTE: 参数编码格式
    order.charset = @"utf-8";
    
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    
    // NOTE: 支付版本
    order.version = @"1.0";
    
    // NOTE: sign_type 根据商户设置的私钥来决定
    order.sign_type = (rsa2PrivateKey.length > 1)?@"RSA2":@"RSA";
    
    // NOTE: 商品数据
    order.biz_content = [BizContent new];
    order.biz_content.body = @"我是测试数据";
    order.biz_content.subject = @"1";
    order.biz_content.out_trade_no = @"200198"; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = @"30m"; //超时时间设置
    order.biz_content.total_amount = [NSString stringWithFormat:@"%.2f", 100.01]; //商品价格
    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"SEM";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    
    //获取私钥并将商户信息签名
    //外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    NSString *signedString = nil;
    RSADataSigner* signer = [[RSADataSigner alloc] initWithPrivateKey:((rsa2PrivateKey.length > 1)?rsa2PrivateKey:rsaPrivateKey)];
    if ((rsa2PrivateKey.length > 1)) {
        signedString = [signer signString:orderSpec withRSA2:YES];
    } else {
        signedString = [signer signString:orderSpec withRSA2:NO];
    }

    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil)
    {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        //没有安装支付宝应用的情况下调用的
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSNumber *resultStatus = resultDic[@"resultStatus"];
            NSLog(@"充值状态____%@",resultStatus);
            
            if (9000 == [resultStatus integerValue])
            {//支付成功
                NSLog(@"支付成功__未安装回调__1111");
                // 支付成功
//                CGRect rectLabel = CGRectMake((WIDTH - 150)/2, 150, 150, 50);
//                [Visitor_AppFunction showLabelWithFrame:rectLabel andTitle:@"充值成功" andComplete:^{
//
//                    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
//                    if (app.PaySuccessBlock) {
//                        app.PaySuccessBlock();
//                    }
//
//                }];
            }
            else if (4000 == [resultStatus integerValue])
            {//订单支付失败
                NSLog(@"支付宝充值失败__%@",resultDic);
                
                DLog(@"%@",resultDic[@"memo"] );
                NSString *resultStr = resultDic[@"memo"];
                if (!resultStr.length) {
                    resultStr = @"支付失败";
                }
                //支付失败，弹出支付宝返回的失败原因
//                [UIAlertView alertWithTitle:nil
//                                    message:resultStr
//                              cancelBtnName:@"确定"
//                              callBackBlock:nil];
            }
            else if (6001 == [resultStatus integerValue])
            {//用户中途取消
                
            }
            else if (5000 == [resultStatus integerValue])
            {//重复请求
                
            }
            else if (6002 == [resultStatus integerValue])
            {
                //网络连接出错
            }
            else if (8000 == [resultStatus integerValue])
            {
                //正在处理，结果未知（服务器请求异步通知支付结果）
                //这里需要向服务器请求支付结果
            }
            else if (6004 == [resultStatus integerValue])
            {
                //支付结果未知（服务器请求异步通知结果）
                //这里需要向服务器请求支付结果
            }
            else
            {
             //其他支付错误
            }
        }];
    }
    
}

/**
 *  统一下单获取预支付ID，后开始发起支付
 *  传入支付参数
 *
 */
- (void)doWXPayWithOrder:(orderModel *)orderModel_data
{
    //判断是否安装微信
    if ([WXApi isWXAppInstalled]) {
        if ([WXApi isWXAppSupportApi]) {
            DLog(@"已安装微信");
            //将订单存入数据库
            [self saveToDBWithOrder:orderModel_data];
        }else{
            [UIView addMJNotifierWithText:@"请将微信升级到最新版本" dismissAutomatically:YES];
            return ;
        }
        DLog(@"---------pass------");
    }else{
        [UIView addMJNotifierWithText:@"未安装微信" dismissAutomatically:NO];
//        return ;
    }
    
    //创建支付签名对象
    payRequsestHandler *req = [payRequsestHandler alloc];
    //初始化支付签名对象
    [req init:APP_ID mch_id:MCH_ID];
    //设置密钥
    [req setKey:PARTNER_ID];
    
    //}}}
    
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [req sendPayWithData:orderModel_data];
    
    if(dict == nil){
        //错误提示
        NSString *debug = [req getDebugifo];
        DLog(@"%@\n",debug);
        
    }else{
        NSLog(@"%@\n\n",[req getDebugifo]);
        //[self alert:@"确认" msg:@"下单成功，点击OK后调起支付！"];
        
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        [WXApi sendReq:req];
    }
}
/**
 *  调起微信支付
 *
 *  @param openID       公众账号ID（微信分配的公众账号ID
 *  @param partnerID    商户号（微信支付分配的商户号）
 *  @param prepayID     预支付交易会话ID
 *  @param nonceStr     随机字符串
 *  @param timeStamp    时间戳
 *  @param sign         签名
 */
//- (void)myWxPayWithOpenID:(NSString *)openID
//                partnerID:(NSString *)partnerID
//                 prepayID:(NSString *)prepayID
//                 nonceStr:(NSString *)nonceStr
//                timeStamp:(NSString *)timeStamp
//                  package:(NSString *)package
//                     sign:(NSString *)sign
//{
//    PayReq* req             = [[PayReq alloc] init];
//    req.openID              = openID;
//    req.partnerId           = partnerID;
//    req.prepayId            = prepayID;
//    req.nonceStr            = nonceStr;
//    req.timeStamp           = [timeStamp intValue];
//    req.package             = package;
//    req.sign                = sign;
//    BOOL isWxTurned = [WXApi sendReq:req];
//    
//    NSLog(@"%d%d",[WXApi openWXApp],[WXApi isWXAppSupportApi]);
//    //日志输出
//    NSLog(@"[微信支付日志输出\nisWxTurned=%d\nappid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@]",isWxTurned,req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign);
//
//}

@end

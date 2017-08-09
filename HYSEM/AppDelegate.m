//
//  AppDelegate.m
//  HYSEM
//
//  Created by xlc on 16/11/15.
//  Copyright © 2016年 WGM. All rights reserved.
//

#import "AppDelegate.h"
#import "HYSocket.h"
#import <AlipaySDK/AlipaySDK.h>
#import "HYScoketManage.h"
#import "DataBaseManager.h"
#import "HYRightViewController.h"
#import "LeftSlideViewController.h"
#import "orderModel.h"
#import "WXApi.h"
@interface AppDelegate ()<WXApiDelegate>
{
    HYSocket *_socket;
}

@property (nonatomic,strong) HYRootViewController *rootVC;
@property (nonatomic,strong) HYLoginViewController *loginVC;


@end

@implementation AppDelegate


- (BOOL)shouldAutorotate
{
    return NO;
    
}

- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return  UIInterfaceOrientationPortrait ;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //验证是否过期
    [self judgeExpired];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"AutoLogin"])
    {
        //已登陆，直接进入主页面
        [self login];
        
    }else{
        //否则，进入Login页面
        [self login];
        
    }
    //初始化数据库
    [self aboutSqlite];
    
    [self.window makeKeyWindow];
    
    //向微信注册／／wxd930ea5d5a258f4f
    [WXApi registerApp:@"wx3c0b24dbf0f658a9" enableMTA:YES];
    
    return YES;
}

/**
 *  @brief  接受微信钱包的返回支付结果
 *
 *  @param  application     resp返回结果
 *  @param  launchOptions   发起微信支付，App dalegaet 接受结果
 *
 *  @return void
 
 */

-(void)onResp:(BaseResp*)resp{
    
    if ([resp isKindOfClass:[PayResp class]]){
        PayResp*response=(PayResp*)resp;
        switch(response.errCode){
            case WXSuccess:
                //服务器端查询支付通知或查询API返回的结果再提示成功
                [self upLoadOrderWith:@"OK"];
                break;
            default:
                NSLog(@"支付失败，retcode=%d",resp.errCode);
                [[DataBaseManager sharedDataBaseManager] deleteAllGoods];
                break;
        }
    }
}
#pragma mark - **************** 初始化数据库
- (void)aboutSqlite
{
    DataBaseManager * manager = [DataBaseManager sharedDataBaseManager];
    [manager createDatabase];
    [manager createGoodsTable];
}

//过期验证
-(void)judgeExpired
{
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh"];
    NSString *date = [dateFormatter stringFromDate:currentDate];
    NSInteger time = [date integerValue] - [[[NSUserDefaults standardUserDefaults] objectForKey:@"date"] integerValue];
    if (time >= 0) {
        //[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"AutoLogin"];
        //NSLog(@"%ld...%@",(long)time,[[NSUserDefaults standardUserDefaults] objectForKey:@"date"]);
    }
}

#pragma mark-  login
- (void)login
{
    HYLoginViewController *login = [[HYLoginViewController alloc] init];
    self.window.rootViewController = login;
    //block
    login.block = ^{
        [self createRootViewController];
    };
}
//解除window
- (void)uninstall{
    self.window.rootViewController = nil;
}
#pragma mark-  首页
- (void)createRootViewController
{
    self.rootVC = [[HYRootViewController alloc]init];
    HYLeftViewController *leftVC = [[HYLeftViewController alloc]init];
    self.LeftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:self.rootVC];
    self.window.rootViewController = self.LeftSlideVC;
    
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    //进入后台,之后每10分钟发一次通知
    [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreateGcdSocket" object:nil userInfo:nil];
        //如果需要添加NSTimer
    }];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            DLog(@"result = %@",resultDic);
            [self alipayResult:resultDic];
        }];
    }else{
        return [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}

- (void)upLoadOrderWith:(NSString *)price
{
    NSArray *arr = [NSArray array];
    if ([HY_NSusefDefaults objectForKey:@"payFee"]) {
        arr = [HY_NSusefDefaults objectForKey:@"payFee"];
        NSString * nodeID = arr[0];
        NSString * fee = arr[1];
        HYScoketManage * manegr = [HYScoketManage shareManager];
        manegr.mpID = (UInt64)[nodeID longLongValue];
        manegr.fee = fee;
        [manegr getNetworkDatawithIP:[HY_NSusefDefaults objectForKey:@"IP"] withTag:@"7"];
        [SVProgressHUD showWithStatus:@"上传中..."];
    }
}

// NOTE: 9.0以后使用新API接口（安装支付宝客户端调用的方法）
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            DLog(@"result = %@",resultDic);
            [self alipayResult:resultDic];

        }];
        

    }else{
        return [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}
//@"payFee" userdefaults中（MPID,Fee,MPName,ordeStr.orderID）
#pragma mark - **************** 处理支付宝支付
- (void)alipayResult:(NSDictionary*)resultDic
{
    NSNumber *resultStatus = resultDic[@"resultStatus"];
    if (9000 == [resultStatus integerValue])
    {//支付成功
        NSLog(@"支付成功__未安装回调__1111");
        // 支付成功
        //uplaod
        [self upLoadOrderWith:@"0.1"];
    }
    else if (4000 == [resultStatus integerValue])
    {//订单支付失败
        NSLog(@"支付宝充值失败__%@",resultDic);
        NSString *resultStr = resultDic[@"memo"];
        if (!resultStr.length) {
            resultStr = @"支付失败";
        }
        [[DataBaseManager sharedDataBaseManager] deleteAllGoods];
        [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
    }
    else if (6001 == [resultStatus integerValue])
    {//用户中途取消
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"payResult" object:@"Failed" userInfo:@{@"status":@"Failed"}];
        [[DataBaseManager sharedDataBaseManager] deleteAllGoods];
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
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"payResult" object:@"Failed" userInfo:@{@"status":@"Failed"}];
        [[DataBaseManager sharedDataBaseManager] deleteAllGoods];
        [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
    }
    else if (8000 == [resultStatus integerValue])
    {
        //正在处理，结果未知（服务器请求异步通知支付结果）
        //这里需要向服务器请求支付结果
        
        //uplaod
        [self upLoadOrderWith:@"0.1"];
    }
    else if (6004 == [resultStatus integerValue])
    {
        //支付结果未知（服务器请求异步通知结果）
        //这里需要向服务器请求支付结果
        //uplaod
        [self upLoadOrderWith:@"0.1"];
    }
    else
    {
        //其他支付错误
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"payResult" object:@"Failed" userInfo:@{@"status":@"Failed"}];
        [[DataBaseManager sharedDataBaseManager] deleteAllGoods];
        [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
    }

}



#pragma mark - **************** 存数据库
- (void)saveToDBWithOrder:(orderModel *)order
{
    DataBaseManager * dbManager = [DataBaseManager sharedDataBaseManager];
    
    NSString * timeString = [HY_NSusefDefaults objectForKey:@"orderIDCreateTime"];//保存订单创建时间
    HYSingleManager * single = [HYSingleManager sharedManager];
    orderModel * model = [[orderModel alloc] initWithOrderID:order.orderID andUserID:[NSString stringWithFormat:@"%lld",single.user.user_ID] andFee:order.fee andDeviceID:order.deviceID andTag:0 andCommit:0 andCreateTime:timeString andPaySelecte:0];// ------0表示未处理状态
    [dbManager insertGoodsWithModel:model];
}


@end

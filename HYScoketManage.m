//
//  HYScoketManage.m
//  HYSEM
//
//  Created by 王一成 on 2017/2/24.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "HYScoketManage.h"
#import "DeviceModel.h"
#import "DataModel.h"
#import "DateModel.h"
#import "DataBaseManager.h"
#import "orderModel.h"
#import "FlieUtils.h"
@interface HYScoketManage()<GCDAsyncSocketDelegate>

@property (nonatomic,strong) __block NSMutableArray * timeArray;

@end
@implementation HYScoketManage
{
    NSMutableData *mData;
    int isAppend;
    int appendLen;
//    NSString *ipv6Addr;
    GCDAsyncSocket * _sendSocket;
    NSString * _tag;
    __block NSString * end;
    int _time;
    int isError;//表示错误信息
    NSMutableArray * _timeArr;
    int requestType ;
    NSString * myip;
    NSInteger upLoadCount;// ------上传次数重传不超过三次
    
}


static HYScoketManage * manage = nil;
+ (id)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manage = [[HYScoketManage alloc] init];
    });
    return manage;
    
}

//
- (BOOL)validateSocket
{
    if ([_sendSocket isConnected]) {
        return YES;
    }else{
        return false;
    }
}

- (void)getNetworkDatawithIP:(NSString *)ipv6Addr withTag:(NSString *)tag
{
    _tag = tag;
    isError = 0;
    end = [[NSString alloc] init];
    myip = SocketHOST;
    NSString * ipv6 = [self convertHostToAddress:myip];
    if ([self validateSocket]) {
        [_sendSocket disconnect];
    }
    _sendSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError * error = nil;
    [_sendSocket connectToHost:ipv6 onPort:SocketonPort withTimeout:15 error:&error];
    if (error.code == 2) {
        [UIView addMJNotifierWithText:@"无法连接到服务器" dismissAutomatically:YES];
    }
}


- (void)writeDataToHostWithTag:(NSString *)tag
{
    NSData * data = [[NSData alloc] init];
    [_sendSocket writeData:data withTimeout:10 tag:0];
}

#pragma mark - **************** 短信提醒 tag ==8
- (void)writeMessageDataToHostWith:(MessageModel *)messageModel{
    _tag = @"8";
    HYExplainManager *expalin = [HYExplainManager shareManager];
    HYSingleManager *manager = [HYSingleManager sharedManager];
    NSString * m_id = [NSString string];
    unsigned char outbuf[1024];
    //
    //                            self.mpID = 3;
    //                            self.fee = @"112233.22";
    int length = [expalin TSR376_GetACK_SendMessageFame:@"" Company_ID:messageModel.companyID Usr_check_ID:manager.user.check_ID User_ID:messageModel.userID device_ID:messageModel.deviceID messageLen:messageModel.messageLen message:messageModel.message andTel:messageModel.messageArr[0] OutBufData:outbuf];
    NSData *data = [NSData dataWithBytes:outbuf length:length];
    [SVProgressHUD showWithStatus:@"通讯中..."];
    [_sendSocket writeData:data withTimeout:10 tag:8];
    [_sendSocket readDataWithTimeout:10 tag:8];
}

#pragma mark --注册
- (void)registToHostWithUser:(NSString *)user{
    _tag = @"9";
    HYExplainManager *expalin = [HYExplainManager shareManager];
    HYSingleManager *manager = [HYSingleManager sharedManager];
    NSString * m_id = [NSString string];
    unsigned char outbuf[1024];
    //
    //                            self.mpID = 3;
    //                            self.fee = @"112233.22";
    int length = [expalin TSR376_GetACK_Registe:manager.user.check_ID andUSer:user OutBufData:outbuf];
    NSData *data = [NSData dataWithBytes:outbuf length:length];
//    [SVProgressHUD showWithStatus:@"通讯中..."];
    [_sendSocket writeData:data withTimeout:10 tag:9];
    [_sendSocket readDataWithTimeout:10 tag:9];
}

#pragma mark --修改密码
- (void)changePassWordToHostWithUser:(NSString *)user{
    _tag = @"10";
    HYExplainManager *expalin = [HYExplainManager shareManager];
    HYSingleManager *manager = [HYSingleManager sharedManager];
    NSString * m_id = [NSString string];
    unsigned char outbuf[1024];
    //
    //                            self.mpID = 3;
    //                            self.fee = @"112233.22";
    int length = [expalin TSR376_GetACK_changePassWord:manager.user.check_ID andUSer:user andPassword:@"123" OutBufData:outbuf];;
    NSData *data = [NSData dataWithBytes:outbuf length:length];
    //    [SVProgressHUD showWithStatus:@"通讯中..."];
    [_sendSocket writeData:data withTimeout:10 tag:9];
    [_sendSocket readDataWithTimeout:10 tag:9];
}

//处理支持IPv6
-(NSString *)convertHostToAddress:(NSString *)host {
    
    NSError *err = nil;
    
    NSMutableArray *addresses = [GCDAsyncSocket lookupHost:host port:0 error:&err];
    NSData *address4 = nil;
    NSData *address6 = nil;
    
    for (NSData *address in addresses)
    {
        if (!address4 && [GCDAsyncSocket isIPv4Address:address])
        {
            address4 = address;
        }
        else if (!address6 && [GCDAsyncSocket isIPv6Address:address])
        {
            address6 = address;
        }
    }
    
    NSString *ip;
    
    if (address6) {
        //        NSLog(@"ipv6%@",[GCDAsyncSocket hostFromAddress:address6]);
        ip = [GCDAsyncSocket hostFromAddress:address6];
    }else {
        //        NSLog(@"ipv4%@",[GCDAsyncSocket hostFromAddress:address4]);
        ip = [GCDAsyncSocket hostFromAddress:address4];
    }
    
    return ip;
    
}

- (void)setupReadTimerWithTimeout:(NSTimeInterval)timeout
{
//    [SVProgressHUD showWithStatus:@"超时"];
//    [SVProgressHUD dismiss];
}
#pragma mark - **************** 重新上传 上传失败的 订单
- (void)reUploadOrder
{
    // ------检查是否有没上传的订单
    DataBaseManager * dbManager = [DataBaseManager sharedDataBaseManager];
    NSArray * item = [dbManager selectAllGoods];
    if (item.count > 0) {// ------重新发起请求
        [self getNetworkDatawithIP:@"7" withTag:@"7"];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error
{
    DLog(@"66%ld--%@",error.code,error.userInfo);
    if ([_tag isEqualToString:@"7"] && !(error.code == 0&&error.userInfo == nil)) {// ------上传订单信息出现问题
//        if (upLoadCount<=3) {
//            [self reUploadOrder];
//            upLoadCount++;
//        }else{
            [SVProgressHUD dismissInNow];
            [UIView addMJNotifierWithText:@"支付上传失败，请再次点击支付重新上传" dismissAutomatically:NO];
//            upLoadCount = 0;
//        }
    }else if ([_tag isEqualToString:@"6"] && !(error.code == 0&&error.userInfo == nil)) {// ------上传订单信息出现问题
        //        if (upLoadCount<=3) {
        //            [self reUploadOrder];
        //            upLoadCount++;
        //        }else{
        [SVProgressHUD dismissInNow];
        [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
        //            upLoadCount = 0;
        //        }
    }else if (error.code == 3) {
        [SVProgressHUD dismissInNow];
        [UIView addMJNotifierWithText:@"连接服务器超时" dismissAutomatically:YES];
        
    }else if(error.code == 51){
        [SVProgressHUD dismissInNow];
        [UIView addMJNotifierWithText:@"无法连接到服务器" dismissAutomatically:YES];
    }else if(error.code == 0){
        if (error.userInfo) {
            [SVProgressHUD dismissInNow];
            [UIView addMJNotifierWithText:@"无法连接到服务器" dismissAutomatically:YES];
        }
    }else if(error.code == 4){
        //超时
        [SVProgressHUD dismissInNow];
        DLog(@"Socket 断开链接%d",[_sendSocket isConnected]);
    }else if(error.code == 61){
        [SVProgressHUD dismissInNow];
        [UIView addMJNotifierWithText:@"无法连接到服务器" dismissAutomatically:YES];
    } else if(error.code == 2){
        [SVProgressHUD dismissInNow];
        [UIView addMJNotifierWithText:@"连接失败" dismissAutomatically:YES];
    }else{
        [SVProgressHUD dismiss];
//        [UIView addMJNotifierWithText:@"获取数据失败" dismissAutomatically:YES];
    }


}

- (BOOL)checKDevice
{
    HYSingleManager *manager = [HYSingleManager sharedManager];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        for (int j = 0; j<company.child_obj1.count; j++) {
            CTerminalModel *terminal = company.child_obj1[j];
            int len = 0;
            for (int k = 0; k<terminal.child_obj.count; k++,len++) {
                return YES;
            }
        }
    }
    return NO;

}


//建立连接
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    //保存socket时间
    [FlieUtils saveTime];
    if (![self checKDevice] && ![_tag isEqualToString:@"1"]&&![_tag isEqualToString:@"9"]) {
        [SVProgressHUD dismiss];
        [UIView addMJNotifierWithText:@"设备不存在" dismissAutomatically:YES];
        return;
    }
    int tag = [_tag intValue];
    switch (tag) {
        case 2://用量
        {
            NSData * data = [HY_NSusefDefaults objectForKey:@"usePowerData"];
            NSArray * dataArr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [SVProgressHUD showWithStatus:@"通讯中..."];
            [_sendSocket readDataWithTimeout:10 tag:2];
        }
            
            break;
        case 1:
        {//用户请求
            //用户请求
            HYExplainManager *manager = [HYExplainManager shareManager];
            Byte inbuf[5] = {0x00,0x00,0x00,0x00,0x00};
            unsigned char outbuf[1024];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *username = [defaults objectForKey:@"username"];
            NSString *password = [defaults objectForKey:@"password"];
            int aaa = [manager TSR376_Get_Land_Fame:inbuf :username :password :outbuf];
            NSData *data = [NSData dataWithBytes:outbuf length:aaa];
            [_sendSocket writeData:data withTimeout:10 tag:1];
            [sock readDataWithTimeout:10 tag:0];
            //更新前，清空数据
//            HYSingleManager *single = [HYSingleManager sharedManager];
//            single.obj_dict = [[NSMutableDictionary alloc] init];
//            single.archiveUser = nil;
            // ------清除数据
            break;
        }
            
        case 3:
        {//状态tag = 3
            [SVProgressHUD showWithStatus:@"通讯中..."];
            [_sendSocket readDataWithTimeout:10 tag:3];
        }
            
            break;
        case 5:
        {//状态tag = 5
            [SVProgressHUD showWithStatus:@"通讯中..."];
            [_sendSocket readDataWithTimeout:10 tag:5];
        }
            
            break;
    
        case 4:
        {//表码
            HYExplainManager *expalin = [HYExplainManager shareManager];
            HYSingleManager *manager = [HYSingleManager sharedManager];
            for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
                CCompanyModel *company = manager.archiveUser.child_obj[i];
                for (int j = 0; j<company.child_obj1.count; j++) {
                    CTerminalModel *terminal = company.child_obj1[j];
                    unsigned int Pn[150];
                    int len = 0;
                    for (int k = 0; k<terminal.child_obj.count; k++,len++) {
                        CMPModel *mp = terminal.child_obj[k];
                        Pn[k] = mp.mp_point;
                    }
                    unsigned char outbuf[1024];
                    // ------没有设备.跳出本次循环
                    if (len == 0) {
                        continue;
                    }
                    int bufLength = [expalin TSR376_GetACK_TableCodeInfFame:terminal.term_ID mp_pointArr:Pn mp_pointNum:len Usr_checkID:manager.user.check_ID OurBufData:outbuf];
                    NSData *data = [NSData dataWithBytes:outbuf length:bufLength];
                    [_sendSocket writeData:data withTimeout:10 tag:4];
                }
            }
            [sock readDataWithTimeout:10 tag:4];

        }
            break;
        case 6://支付上传获取签名字符串（需要设备ID和fee）
        {
            HYExplainManager *expalin = [HYExplainManager shareManager];
            HYSingleManager *manager = [HYSingleManager sharedManager];
            NSString * m_id = [NSString string];
            unsigned char outbuf[1024];
            //
            for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
                CCompanyModel *company = manager.archiveUser.child_obj[i];
                for (int j = 0; j<company.child_obj1.count; j++) {
                    CTerminalModel *terminal = company.child_obj1[j];
                    m_id = terminal.term_ID;
                    unsigned int Pn[20];
                    int len = 0;
                    for (int k = 0; k<terminal.child_obj.count; k++,len++) {
                        CMPModel *mp = terminal.child_obj[k];
                        Pn[k] = mp.mp_point;
                        if (mp.strID == self.mpID) {
                            DLog(@"电表Id%llu",self.mpID);
                            //                            self.mpID = 3;
                            //                            self.fee = @"112233.22";
                            int length = [expalin TSR376_GetACK_UpLoadOrderNumFame:m_id Usr_check_ID:manager.user.check_ID User_ID:manager.user.user_ID OrderID:nil DeviceID:self.mpID Fee:self.fee OutBufData:outbuf];
                            NSData *data = [NSData dataWithBytes:outbuf length:length];
                            //tag赋值
                            _tag = @"6";
                            [sock writeData:data withTimeout:10 tag:6];
                            [sock readDataWithTimeout:10 tag:6];
                        }
                        
                    }
                }
            }
            break;
        }
        case 7:////向服务器上传支付结果
        {
            HYExplainManager *expalin = [HYExplainManager shareManager];
            HYSingleManager *manager = [HYSingleManager sharedManager];
            NSString * m_id = [NSString string];
            unsigned char outbuf[1024];
            //
            //                            self.mpID = 3;
//                            self.fee = @"112233.22";
            int length = [expalin TSR376_GetACK_UpLoadOrderInfoFame:nil Company_ID:nil Usr_check_ID:manager.user.check_ID User_ID:manager.user.user_ID MPPowrID:self.mpID Fee:[self.fee floatValue] OutBufData:outbuf];
            NSData *data = [NSData dataWithBytes:outbuf length:length];
            [sock writeData:data withTimeout:10 tag:7];
            [sock readDataWithTimeout:10 tag:7];
            break;
        }
        case 8://短信
        {
            break;
        }
        case 9://查询账号是否重复
        {
            break;
        }
        case 10://注册
        {
            break;
        }
        default:
            break;
    }
    
}


//接收数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    DLog(@"%@",data);
    HYExplainManager *manager = [HYExplainManager shareManager];
    unsigned char outbuf[1024*4];
    int rLen;
    int i = 0,len = 0;
    Byte *dataBytes;
    if (1 == isAppend) {
        [mData appendData:data];
        dataBytes = (Byte *)[mData bytes];
        appendLen += [data length];
    }else{
        dataBytes = (Byte *)[data bytes];
        appendLen = (int)[data length];
    }
    //首先分析是否粘包
    while (8<appendLen-i) {
        len = [manager TSR376_Get_All_frame:&dataBytes[i] :(appendLen-i) :outbuf :&rLen];
        if (1 == len) {
            //开始解析
            [self TSR376_Analysis_All_Frame:&dataBytes[i] length:rLen WithTag:tag];
            isAppend = 0;
        }else if (0 == len){
            DLog(@"存储不够长度的帧---%d", rLen);
            mData = [NSMutableData data];
            [mData appendBytes:outbuf length:rLen];
            appendLen = rLen;
            isAppend = 1;
        }else if (-1 == len){
            DLog(@"帧不对");
            isAppend = 0;
            mData = [NSMutableData data];
            break;
        }
        if (0 == rLen) {
            isAppend = 0;
            break;
        }
        i += rLen;
    }
    //处理use Power _tag ==2表明处理用量数据
    if ([_tag isEqualToString:@"2"] ) {
    //判断所有数据是否请求完成
        BOOL ret = [self isFinished];
        if (ret) {
            [SVProgressHUD showSuccessWithStatus:@"获取数据成功"];
            [SVProgressHUD dismiss];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getData" object:nil];
        }
    }
    if ([_tag isEqualToString:@"6"]){
        //服务器加密数据
    }
    if (tag == 7){
        //服务器查询结果处理
        
    }
    if ([_tag isEqualToString:@"8"]){
        //发送短信
        
    }
    //处理状态模块
    if ([_tag isEqualToString:@"3"]) {
        BOOL ret = [self isFinished1];
        if (ret) {
            [SVProgressHUD showSuccessWithStatus:@"获取数据成功"];
            [SVProgressHUD dismiss];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getStatusData" object:nil];
        }
    }
    //处理无功
    if ([_tag isEqualToString:@"5"]) {
        BOOL ret = [self isFinished1];
        if (ret) {
            [SVProgressHUD showSuccessWithStatus:@"获取数据成功"];
            [SVProgressHUD dismiss];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getWUgongData" object:nil];
        }
    }
    //表码模块
    if ([_tag isEqualToString:@"4"]) {
        //判断数据是否都已经解析完
        BOOL ret = [self isFinished1];
        if (ret) {
            [SVProgressHUD showSuccessWithStatus:@"获取数据成功"];
            // 延迟1秒后消失
            [SVProgressHUD dismiss];
            //获取数据源
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getTableCodeData" object:nil];
        }
    }
    [sock readDataWithTimeout:10 tag:tag];
}


////判断表码信息是否完成
//-(BOOL)JudgeTableCodeFrameIsRequest
//{
//    //依据是档案字典里的key的个数是否和表码字典里的key的个数相等
//    HYSingleManager *manager = [HYSingleManager sharedManager];
//    NSMutableArray *arr = [NSMutableArray array];
//    NSArray *tableKeys = manager.memory_Array;
//    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
//        CCompanyModel *company = manager.archiveUser.child_obj[i];
//        for (int j = 0; j<company.child_obj1.count; j++) {
//            CTerminalModel *terminal = company.child_obj1[j];
//            for (int k = 0; k<terminal.child_obj.count; k++) {
//                CMPModel *mp = terminal.child_obj[k];
//                [arr addObject:[NSString stringWithFormat:@"%llu",mp.strID]];
//            }
//        }
//    }
//    if (tableKeys.count == arr.count) {
//        return YES;
//    }
//    return NO;
//}

#pragma mark - **************** 用量判断
- (BOOL)isFinished
{
    NSData * data = [HY_NSusefDefaults objectForKey:@"usePowerData"];
    NSArray * dataArr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    HYSingleManager *manager1 = [HYSingleManager sharedManager];
    int terminalNum = 0;
    for (int a = 0; a<manager1.archiveUser.child_obj.count; a++) {
        CCompanyModel *company = manager1.archiveUser.child_obj[a];
        for (int b = 0; b<company.child_obj1.count; b++) {
            CTerminalModel *terminal = company.child_obj1[b];
            for (int c = 0; c<terminal.child_obj.count; c++) {
                CMPModel *mp = terminal.child_obj[c];
                terminalNum ++;
            }
        }
    }
    //目前只处理首页
    if (self.deviceID.count>0) {
        terminalNum = self.deviceID.count;
    }
    
    
    int num = 0;
    for (DeviceModel * de in dataArr) {
        for (DataModel * data in de.dataArr) {
            num ++;
        }
    }
    if (num == (_time +1)*terminalNum)
    {
        //接受完毕
        [HY_NSusefDefaults setObject:nil forKey:@"NextData"];
        return true;
    }
    NSMutableArray * errorData = [HY_NSusefDefaults objectForKey:@"NextData"];
    for (int i = 0; i < errorData.count; i++)
    {
        num ++;
    }
    if (num == (_time +1)*terminalNum) {
        if (errorData.count ==0) {
            [HY_NSusefDefaults removeObjectForKey:@"NextData"];
            return true;
        }
        for (int i = 0; i < errorData.count; i++) {
            NSDictionary * dic = errorData[i];
            isError = 2;//错误
            [self writeDataToHost1WithTime:dic[@"Time"] andPn:[dic[@"Pn"] intValue] andAddress:dic[@"Address"]];
        }
        return false;
    }else{
        return false;
    }
}

#pragma mark --  首先判断所有的数据是否请求完
- (BOOL)JudgeAllFrameIsRequest
{
    //依据是字典里边的key在其他value里是否存在
    HYSingleManager *single = [HYSingleManager sharedManager];
    NSArray *allKeys = [single.obj_dict allKeys];
    NSArray *allVaules = [single.obj_dict allValues];
    BOOL ret1 = YES;
    BOOL ret2 = YES;
    BOOL ret3 = YES;
    if (allKeys.count == 0||!allKeys) {
        return false;
    }
    for (int i = 0; i<allKeys.count; i++) {
        HYBaseModel *baseModel = allVaules[i];
        if ([baseModel.request_Type isEqualToString:@"company"]) {
            CCompanyModel *company = allVaules[i];
            for (int j = 0; j<company.children.count; j++) {
                //占线是否都存在
                ret1 = [allKeys containsObject:company.children[j]];
                if (ret1 == NO) {
                    return false;
                }
            }
            for (int j = 0; j<company.children1.count; j++) {
                //终端是否都存在
                ret2 = [allKeys containsObject:company.children1[j]];
                if (ret2 == NO) {
                    
                    return false;
                }
            }
        }else{
            //其他   （组、设备)
            for (int j = 0; j<baseModel.children.count; j++) {
                ret3 = [allKeys containsObject:baseModel.children[j]];
                if (ret3 == NO) {
                    return false;
                }
            }
        }
    }
    return true;
    
}
//登录
#pragma mark -- 验证登录帧的正确性
- (void)TSR376_Analysis_Land_return:(unsigned char*)dataBytes :(int)length
{
    HYExplainManager *manager = [HYExplainManager shareManager];
    int value = [manager TSR376_Analysis_Land_return:dataBytes :length];
    switch (value) {
        case 1:
            [SVProgressHUD showErrorWithStatus:@"错误帧"];
            break;
        case 2:
            [SVProgressHUD showErrorWithStatus:@"错误帧"];
            break;
        case 3:
            [SVProgressHUD showErrorWithStatus:@"普通确认帧"];
            break;
        case 4:
            [SVProgressHUD showErrorWithStatus:@"否认帧"];
            break;
        case 0:
        {//保存用户信息,用户名、密码、验证ID等等
            //请求用户信息
            unsigned char outbuf[1024];
            Byte inbuf[5] = {0x00,0x00,0x00,0x00,0x00};
            HYSingleManager *single = [HYSingleManager sharedManager];
            int length = [manager TSR376_GetACK_UsrInfFame:inbuf :single.user.user_ID :single.user.check_ID :outbuf];
            NSData *data = [NSData dataWithBytes:outbuf length:length];
            [_sendSocket writeData:data withTimeout:10 tag:0];
            break;
        }
        default:
            break;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"Exit"] || ![defaults objectForKey:@"isNoFirstLogin"] || ![defaults objectForKey:@"AutoLogin"]) {
        NSDate *currentDate = [NSDate date];//获取当前时间，日期
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm:ss"];
        NSString *date = [dateFormatter stringFromDate:currentDate];
        [defaults setObject:date forKey:@"date"];
        
    }
    [defaults setObject:@"aaa" forKey:@"loginTimer"];
    [defaults setObject:nil forKey:@"Exit"];
    // 登录成功
    [defaults setObject:@"Yes" forKey:@"isNoFirstLogin"];
    [defaults synchronize];
}


#pragma mark --解析所有帧
- (void)TSR376_Analysis_All_Frame:(unsigned char*)dataBytes length:(unsigned int)length WithTag:(long)tag
{
    HYExplainManager *manager = [HYExplainManager shareManager];
    HYSingleManager *single = [HYSingleManager sharedManager];
    unsigned int val = [manager GW09_Checkout:dataBytes :length];
    unsigned int AFN = [manager TSR376_Get_AFN_Frame:dataBytes];
    switch (val) {
        case 0:
            //错误帧
            [SVProgressHUD showErrorWithStatus:@"错误帧"];
            break;
        case 1:
            switch (AFN) {
                case 0:
                {
                    //全部确认
                    if (tag == 7) {//支付订单确认
                        [SVProgressHUD dismissInNow];
                        //socket断开连接
                        [_sendSocket disconnect];
                        [UIView addMJNotifierWithText:@"支付成功" dismissAutomatically:YES];
                        //数据库删除
                        [[DataBaseManager sharedDataBaseManager] deleteAllGoods];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"payResult" object:@"Success" userInfo:@{@"status":@"Success"}];
                    }else if ([_tag isEqualToString:@"6"]){//支付得到确认
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"payConfirm" object:@"Success" userInfo:@{@"status":@"Success"}];
                        [SVProgressHUD dismissInNow];
                        //socket断开连接
                        [_sendSocket disconnect];
                    }else if (tag == 8){//发送短信
                        [SVProgressHUD dismissInNow];
                        [UIView addMJNotifierWithText:@"短信发送成功" dismissAutomatically:YES];
                        //socket断开连接
                        [_sendSocket disconnect];
                    }else if (tag == 9){//查询用户是否存在
                        [UIView addMJNotifierWithText:@"账户可以使用" dismissAutomatically:YES];
                    }
                    break;
                    
                }
                case 1:
                {
                    //全部否认
                    if (tag == 7) {
                        [SVProgressHUD dismissInNow];
                        [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
                        //socket断开连接
                        [_sendSocket disconnect];
                        //数据库删除
                        [[DataBaseManager sharedDataBaseManager] deleteAllGoods];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"payResult" object:@"Failed" userInfo:@{@"status":@"Failed"}];
                    }else if (tag == 8){//发送短信
                        [SVProgressHUD dismissInNow];
                        [UIView addMJNotifierWithText:@"短信发送失败" dismissAutomatically:YES];
                        //socket断开连接
                        [_sendSocket disconnect];
                    }else if (tag == 9){//查询用户是否存在
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"userExit" object:self userInfo:nil];
                        [UIView addMJNotifierWithText:@"账户可以使用" dismissAutomatically:YES];
                    }
                    else{
                        [SVProgressHUD showErrorWithStatus:@"错误帧"];
                        //socket断开连接
                        [_sendSocket disconnect];
                    }
                    break;
                }
                case 2:
                    //数据单元标识确认和否认:对收到报文中的全部数据单元标识进行逐个确认/否认
                    break;
                case 3:
                {//验证码过期否认
                    [SVProgressHUD showErrorWithStatus:@"验证码过期,请重新登录"];
                    [_sendSocket disconnect];
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    [delegate login];
                    break;
                }
                case 4:
                    //用户验证ID,登录帧
                    [self TSR376_Analysis_Land_return:dataBytes :length];
                    break;
                case 5:
                {//接收到用户档案
                    int iEnd;
                    [manager TSR376_Analysis_UsrInf:dataBytes :length :single.user.user_ID :iEnd];
                    unsigned char outbuf[1024];
                    Byte inbuf[5] = {0x00,0x00,0x00,0x00,0x00};
                    
                    NSArray *keyArr = [single.obj_dict allKeys];
                    NSArray *valueArr = [single.obj_dict allValues];
                    for (int i = 0; i<keyArr.count; i++) {
                        HYBaseModel *model = valueArr[i];
                        if ([model.request_Type isEqualToString:@"user"]) {
                            HYUserModel *user = valueArr[i];
                            if (user.isRequest == false) {
                                //请求单位档案
                                for (int j = 0; j<user.children.count; j++) {
                                    int length = [manager TSR376_GetACK_CompanyInfFame:inbuf Company_ID:[user StringToUInt64:user.children[j]] Usr_checkID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data1 = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data1 withTimeout:10 tag:0];
                                }
                                user.isRequest = true;       //发送完一个就将请求状态设置为true
                            }
                        }
                    }
                    
                    break;}
                case 6:
                    //群档案
                    
                    break;
                case 7:
                {//接收单位档案
                    int iEnd;
                    [manager TSR376_Analysis_CompanyInf:dataBytes bufer_len:length Company_ID:single.company.strID iEnd:iEnd];
                    unsigned char outbuf[1024];
                    Byte inbuf[5] = {0x00,0x00,0x00,0x00,0x00};
                    
                    NSArray *keyArr = [single.obj_dict allKeys];
                    NSArray *valueArr = [single.obj_dict allValues];
                    for (int i = 0; i<keyArr.count; i++) {
                        HYBaseModel *model = valueArr[i];
                        if ([model.request_Type isEqualToString:@"company"]) {
                            CCompanyModel *company = valueArr[i];
                            if (company.isRequest == false) {
                                //请求占线
                                for (int j = 0; j<company.children.count; j++) {
                                    int length = [manager TSR376_GetACK_LineInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] Line_ID:[company StringToUInt64:company.children[j]] Usr_check_ID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data2 = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data2 withTimeout:10 tag:0];
                                }
                                //请求终端
                                for (int k = 0; k<company.children1.count; k++) {
                                    int length = [manager TSR376_GetACK_TerminalInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] Terminal_ID:[company StringToUInt64:company.children1[k]] Usr_checkID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data3 = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data3 withTimeout:10 tag:0];
                                }
                                company.isRequest = true;
                            }
                        }else if ([model.request_Type isEqualToString:@"transit"]){
                            //请求组档案
                            CTransitModel *transit = valueArr[i];
                            if (transit.isRequest == false) {
                                for (int j = 0; j<transit.children.count; j++) {
                                    int length = [manager TSR376_GetACK_SetInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] Set_ID:[transit StringToUInt64:transit.children[j]] Usr_CheckID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data withTimeout:10 tag:0];
                                }
                                transit.isRequest = true;
                                
                            }
                            
                        }else if ([model.request_Type isEqualToString:@"set"]){
                            //请求设备档案
                            CSetModel *set = valueArr[i];
                            if (set.isRequest == false) {
                                for (int j = 0; j<set.children.count; j++) {
                                    int length = [manager TSR376_GetACK_MPPowerInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] MPPower_ID:[set StringToUInt64:set.children[j]] Usr_check_ID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data withTimeout:10 tag:0];
                                }
                                set.isRequest = true;
                            }
                            
                        }
                    }
                    
                    break;}
                    case 8:
                    {//接收线路档案
                        int iEnd;
                        [manager TSR376_Analysis_LineInf:dataBytes bufer_len:length Company_ID:single.company.strID Line_ID:[single.company.children[0] strID] iEnd:iEnd];
                    
                        //请求组档案
                        unsigned char outbuf[1024];
                        Byte inbuf[5] = {0x00,0x00,0x00,0x00,0x00};
                    
                        NSArray *keyArr = [single.obj_dict allKeys];
                        NSArray *valueArr = [single.obj_dict allValues];
                        for (int i = 0; i<keyArr.count; i++) {
                            HYBaseModel *model = valueArr[i];
                            if ([model.request_Type isEqualToString:@"company"]) {
                            ////请求占线档案
                                CCompanyModel *company = valueArr[i];
                                if (company.isRequest == false) {
                                //占线
                                    for (int j = 0; j<company.children.count; j++) {
                                        int length = [manager TSR376_GetACK_LineInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] Line_ID:[company StringToUInt64:company.children[j]] Usr_check_ID:single.user.check_ID OutBufData:outbuf];
                                        NSData *data2 = [NSData dataWithBytes:outbuf length:length];
                                        [_sendSocket writeData:data2 withTimeout:10 tag:0];
                                    }
                                //终端
                                    for (int k = 0; k<company.children1.count; k++) {
                                        int length = [manager TSR376_GetACK_TerminalInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] Terminal_ID:[company StringToUInt64:company.children1[k]] Usr_checkID:single.user.check_ID OutBufData:outbuf];
                                        NSData *data3 = [NSData dataWithBytes:outbuf length:length];
                                        [_sendSocket writeData:data3 withTimeout:10 tag:0];
                                    }
                                    company.isRequest = true;
                                
                                }
                            }else if ([model.request_Type isEqualToString:@"transit"]){
                            //请求组档案
                                CTransitModel *transit = valueArr[i];
                                if (transit.isRequest == false) {
                                    for (int j = 0; j<transit.children.count; j++) {
                                        int length = [manager TSR376_GetACK_SetInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] Set_ID:[transit StringToUInt64:transit.children[j]] Usr_CheckID:single.user.check_ID OutBufData:outbuf];
                                        NSData *data = [NSData dataWithBytes:outbuf length:length];
                                        [_sendSocket writeData:data withTimeout:10 tag:0];
                                    }
                                    transit.isRequest = true;
                                
                                }
                            }else if ([model.request_Type isEqualToString:@"set"]){
                            //请求设备档案
                                CSetModel *set = valueArr[i];
                                if (set.isRequest == false) {
                                    for (int j = 0; j<set.children.count; j++) {
                                        int length = [manager TSR376_GetACK_MPPowerInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] MPPower_ID:[set StringToUInt64:set.children[j]] Usr_check_ID:single.user.check_ID OutBufData:outbuf];
                                        NSData *data = [NSData dataWithBytes:outbuf length:length];
                                        [_sendSocket writeData:data withTimeout:10 tag:0];
                                    }
                                    set.isRequest = true;
                                }
                            
                            }
                        }
                        break;
                    }
                    case 9:
                    //站线档案
                    
                        break;
                    case 10:
                    {
                    //终接收端档案
                        int iEnd;
                        CSetModel *model = [single.company.children[0] children][0];
                        [manager TSR376_Analysis_TerminalInf:dataBytes bufer_len:length Company_ID:single.company.strID Terminal_ID:model.strID iEnd:iEnd];
                        break;}
                    case 11:
                    {//组档案
                        int iEnd;
                        CSetModel *modle = [single.company.children[0] children][0];
                        [manager TSR376_Analysis_SetInf:dataBytes bufer_len:length Company_ID:single.company.strID Set_ID:modle.strID iEnd:iEnd];
                        unsigned char outbuf[1024];
                        Byte inbuf[5] = {0x00,0x00,0x00,0x00,0x00};
                    
                        NSArray *keyArr = [single.obj_dict allKeys];
                        NSArray *valueArr = [single.obj_dict allValues];
                        for (int i = 0; i<keyArr.count; i++) {
                        HYBaseModel *model = valueArr[i];
                        if ([model.request_Type isEqualToString:@"company"]) {
                            ////请求占线档案
                            CCompanyModel *company = valueArr[i];
                            if (company.isRequest == false) {
                                //占线
                                for (int j = 0; j<company.children.count; j++) {
                                    int length = [manager TSR376_GetACK_LineInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] Line_ID:[company StringToUInt64:company.children[j]] Usr_check_ID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data2 = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data2 withTimeout:10 tag:0];
                                }
                                //终端
                                for (int k = 0; k<company.children1.count; k++) {
                                    int length = [manager TSR376_GetACK_TerminalInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] Terminal_ID:[company StringToUInt64:company.children1[k]] Usr_checkID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data3 = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data3 withTimeout:10 tag:0];
                                }
                                company.isRequest = true;
                            }
                        }else if ([model.request_Type isEqualToString:@"transit"]){
                            //请求组档案
                            CTransitModel *transit = valueArr[i];
                            if (transit.isRequest == false) {
                                for (int j = 0; j<transit.children.count; j++) {
                                    int length = [manager TSR376_GetACK_SetInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] Set_ID:[transit StringToUInt64:transit.children[j]] Usr_CheckID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data withTimeout:10 tag:0];
                                }
                                transit.isRequest = true;
                                
                            }
                        }else if ([model.request_Type isEqualToString:@"set"]){
                            //请求设备档案
                            CSetModel *set = valueArr[i];
                            if (set.isRequest == false) {
                                for (int j = 0; j<set.children.count; j++) {
                                    int length = [manager TSR376_GetACK_MPPowerInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] MPPower_ID:[set StringToUInt64:set.children[j]] Usr_check_ID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data withTimeout:10 tag:0];
                                }
                                set.isRequest = true;
                            }
                        }
                    }
                    
                    break;
                }
                case 12:
                {//设备档案
                    if ([_tag isEqualToString: @"7"]) {
                        int iEnd;
//                        [manager TSR376_Analysis_FeeInf:dataBytes bufer_len:length Company_ID:single.company.strID MPPower_ID:single.company.strID iEnd:iEnd];
                        break;
                    }else{
                    int iEnd;
                    [manager TSR376_Analysis_MPPowerInf:dataBytes bufer_len:length Company_ID:single.company.strID MPPower_ID:single.company.strID iEnd:iEnd];
                    unsigned char outbuf[1024];
                    Byte inbuf[5] = {0x00,0x00,0x00,0x00,0x00};
                    NSArray *keyArr = [single.obj_dict allKeys];
                    NSArray *valueArr = [single.obj_dict allValues];
                    for (int i = 0; i<keyArr.count; i++) {
                        HYBaseModel *model = valueArr[i];
                        if ([model.request_Type isEqualToString:@"company"]) {
                            ////请求占线档案
                            CCompanyModel *company = valueArr[i];
                            if (company.isRequest == false) {
                                //占线
                                for (int j = 0; j<company.children.count; j++) {
                                    int length = [manager TSR376_GetACK_LineInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] Line_ID:[company StringToUInt64:company.children[j]] Usr_check_ID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data2 = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data2 withTimeout:10 tag:0];
                                }
                                //终端
                                for (int k = 0; k<company.children1.count; k++) {
                                    int length = [manager TSR376_GetACK_TerminalInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] Terminal_ID:[company StringToUInt64:company.children1[k]] Usr_checkID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data3 = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data3 withTimeout:10 tag:0];
                                }
                                company.isRequest = true;
                            }
                        }else if ([model.request_Type isEqualToString:@"transit"]){
                            //请求组档案
                            CTransitModel *transit = valueArr[i];
                            if (transit.isRequest == false) {
                                for (int j = 0; j<transit.children.count; j++) {
                                    int length = [manager TSR376_GetACK_SetInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] Set_ID:[transit StringToUInt64:transit.children[j]] Usr_CheckID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data withTimeout:10 tag:0];
                                }
                                transit.isRequest = true;
                            }
                        }else if ([model.request_Type isEqualToString:@"set"]){
                            //请求设备档案
                            CSetModel *set = valueArr[i];
                            if (set.isRequest == false) {
                                for (int j = 0; j<set.children.count; j++) {
                                    int length = [manager TSR376_GetACK_MPPowerInfFame:inbuf Company_ID:[model StringToUInt64:keyArr[i]] MPPower_ID:[set StringToUInt64:set.children[j]] Usr_check_ID:single.user.check_ID OutBufData:outbuf];
                                    NSData *data = [NSData dataWithBytes:outbuf length:length];
                                    [_sendSocket writeData:data withTimeout:10 tag:0];
                                }
                                set.isRequest = true;
                            }
                        }
                    }
                    
                    break;}
            }
                case 13:
                {//查询2类数据o
                    //socket断开连接
                int iEnd;
                if ([_tag intValue] == 2) {
                    if (isError == 1 ) {
                    //next请求，修正错误信息(useless)
                        [manager TSR376_Analysis_TableCodeForHourInfNextFame:dataBytes bufer_len:length iEnd:&iEnd With:end];
                    }else if(isError ==2){//请求数据超过六次
                        [manager TSR376_Analysis_TableCodeForHourInfNextFame:dataBytes bufer_len:length iEnd:&iEnd With:end];
                    
                    }else{
                        [manager TSR376_Analysis_TableCodeForHourInfFame:dataBytes bufer_len:length iEnd:&iEnd With:end];
                    }
                    }else if([_tag intValue] == 3){
                        //状态模块
                        [manager TSR376_Analysis_QueryInfFame:dataBytes bufer_len:length iEnd:&iEnd];
                    }else if ([_tag intValue] == 4){
                        //表吗
                        [manager TSR376_Analysis_TableCodeInf:dataBytes bufer_len:length iEnd:&iEnd];
                    }else if([_tag intValue] == 5){// 无用功
                        //无功模块
                        [manager TSR376_Analysis_QueryInfFame:dataBytes bufer_len:length iEnd:&iEnd];
                    }
                    break;
                }
                case 19://档案修改获取支付加密字符串
                {
                    int iEnd;

                    if (tag == 6) {
                        [manager TSR376_Anlysis_OrderInfo:dataBytes bufer_len:length iEnd:&iEnd];
                        //socket断开连接
                        [_sendSocket disconnect];
                    }
                    break;
                }
                default:
                    break;
            }
    }
    if ([_tag isEqualToString:@"1"]) {
        //判断所有的数据是否请求完
        if ([self JudgeAllFrameIsRequest] == YES) {
            //建立档案
            [self SetArchives];
        }

    }
}

#pragma mark --建立档案
- (void)SetArchives
{
    HYSingleManager *manager = [HYSingleManager sharedManager];
    HYUserModel *user = [[HYUserModel alloc]init];
    
    NSArray *allKeys = [manager.obj_dict allKeys];
    
    NSArray *allValues = [manager.obj_dict allValues];
    
    for (int i = 0; i<allKeys.count; i++) {
        
        HYBaseModel *baseModel = allValues[i];
        baseModel.archiveModel = [[HYBaseModel alloc]init];
        if ([baseModel.request_Type isEqualToString:@"user"]) {
            user = (HYUserModel *)baseModel;
        }
        if (![baseModel.request_Type isEqualToString:@"company"]) {
            for (int j = 0; j<baseModel.children.count; j++) {
                
                CCompanyModel* com = manager.obj_dict[baseModel.children[j]];
                com.nd_terminal_Parent = baseModel;
                [baseModel addChildren:com];
            }
        }else{
            for (int j = 0; j<baseModel.children.count; j++) {
                CTransitModel *model = manager.obj_dict[baseModel.children[j]];
                model.nd_parent = baseModel;
                [baseModel addChildren:model];
            }
            for (int j = 0; j<baseModel.children1.count; j++) {
                CSetModel *model = manager.obj_dict[baseModel.children1[j]];
                model.nd_parent = baseModel;
                [baseModel addChildren1:model];
            }
            
        }
        
    }
    
    manager.archiveUser = user;
//    [SVProgressHUD showSuccessWithStatus:@"Success"];
//    [SVProgressHUD dismiss];
    //通知侧滑页面去展示UI
    [[NSNotificationCenter defaultCenter] postNotificationName:@"downPayData" object:nil];
    [SVProgressHUD dismissInNow];
    
}



/*
usePower模块
*/
#pragma mark -- 进行组帧请求
- (void)writeDataToHostWithL:(NSString *)l
{
    _time = [l intValue];
    self.timeArray = [self returnTimeArray:[l intValue]];
    [self writeDataToHostWithTime:self.timeArray];
}

- (void)writeDataToHostWithMonth{
    
    _time = 1;
    self.timeArray = [self returnMonthTimeArray];
    [self.timeArray removeObjectAtIndex:0];
    [self writeDataToHostWithTime:self.timeArray];
}

-(void)writeDataToHostWithTime:(NSArray *)timeArray{
    isError = 0;
    HYExplainManager *expalin = [HYExplainManager shareManager];
    HYSingleManager *manager = [HYSingleManager sharedManager];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        for (int j = 0; j<company.child_obj1.count; j++) {
            CTerminalModel *terminal = company.child_obj1[j];
            unsigned int Pn[150];
            int len = 0;
            for (int k = 0; k<terminal.child_obj.count; k++,len++) {
                CMPModel *mp = terminal.child_obj[k];
                //目前只处理deviceID。conut>0 的情况
                int point = 0;
                if (self.deviceID.count>0) {
                    for (int m = 0;m<self.deviceID.count;m++) {
                        if ([self.deviceID[m] isEqualToString:[NSString stringWithFormat:@"%llu",mp.strID]]) {
                            point = mp.mp_point;
                        }else{
                            continue;
                        }
                    }
                    Pn[k] = point;
                }else{
                    Pn[k] = mp.mp_point;
                }
            }
            // ------没有设备.跳出本次循环
            if (len == 0) {
                continue;
            }
            unsigned char outbuf[1024];
            for (int l = 0; l<self.timeArray.count; l++) {
                expalin.sendUsePowerNextData =^(NSArray *data ,unsigned int pn ,NSString * terminal_adress){
                    [self writeDataToHost1WithTime:data andPn:pn andAddress:terminal_adress];
                };
                NSArray *time = self.timeArray[l];
                int length = [expalin TSR376_GetACK_TableCodeForHourInfFame:terminal.term_ID mp_pointArr:Pn mp_pointNum:len timeArr:time Usr_checkID:manager.user.check_ID OutBufData:outbuf];
                NSData *data = [NSData dataWithBytes:outbuf length:length];
                [_sendSocket writeData:data withTimeout:10 tag:0];
            }
        }
    }

}


#pragma mark --出错信息请求下一个时间

-(void)writeDataToHost1WithTime:(NSArray *)time andPn: (unsigned int)Pn andAddress:(NSString *) address{
    HYExplainManager *expalin = [HYExplainManager shareManager];
    HYSingleManager *manager = [HYSingleManager sharedManager];
    UInt64 checkID = 0 ;
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        checkID = manager.user.check_ID;
        for (int j = 0; j<company.child_obj1.count; j++)
        {
            CTerminalModel *terminal = company.child_obj1[j];
            int len = 0;
        }
    }
    
    unsigned char outbuf[1024];
    int length = [expalin TSR376_GetACK_TableCodeForHourInfFame:address mp_pointArr:&Pn mp_pointNum:1 timeArr:time Usr_checkID:checkID OutBufData:outbuf];
    NSData *data = [NSData dataWithBytes:outbuf length:length];
    [_sendSocket writeData:data withTimeout:10 tag:0];
    
}

//输入一个整型,返回一个时间戳数组(往前推几天,并且都是零点,再加上截止到现在的时间)
- (NSMutableArray *)returnTimeArray:(int)day
{
    NSMutableArray * record = [[NSMutableArray alloc] init];//日期数组record[1]存储第一天的数组
    NSDate * currentDate = [NSDate date];
    NSTimeInterval  oneSecond = 60*15;
    NSDate * My_date = [NSDate dateWithTimeIntervalSinceNow:-oneSecond];
    NSDateFormatter * dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YY/MM/dd/HH/mm"];
    NSTimeInterval  oneDay = 24*60*60*1;  //1天的长度
    for (int i = day -1; i>=0; i--) {
        NSDate *theDate1;
        theDate1 = [currentDate initWithTimeIntervalSinceNow: -oneDay*i];
        NSString *dateString1 = [dateFormatter stringFromDate:theDate1];
        NSArray *arr1 = [dateString1 componentsSeparatedByString:@"/"];// '/'分割日期字符串,得到一数组
        [record addObject:arr1];
    }
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i<record.count; i++) {
        NSMutableArray *arr = record[i];
        [arr replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"00"]];
        [arr replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"00"]];
        [array addObject:arr];
    }
    NSString *dataString = [dateFormatter stringFromDate:My_date];
    NSArray *arr = [dataString componentsSeparatedByString:@"/"];
    NSMutableArray *a = [NSMutableArray arrayWithArray:arr];
    [a replaceObjectAtIndex:4 withObject:[NSString stringWithFormat:@"00"]];
    [array addObject:a];
    return array;
}


//输入一个整型,返回一个时间戳数组(往前一个月天,并且都是零点,再加上截止到现在的时间)
- (NSMutableArray *)returnMonthTimeArray
{
    NSMutableArray * record = [[NSMutableArray alloc] init];//日期数组record[1]存储第一天的数组
    NSCalendar *calender = [NSCalendar currentCalendar];
     // 设置属性
    NSDateComponents *cmp = [calender components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[[NSDate alloc] init]];
    //设置上个月，即在现有的基础上减去一个月(2017年1月 减去一个月 会得到2016年12月)
    [cmp setMonth:[cmp month] - 1];
    //拿到上个月的NSDate，再用NSDateFormatter就可以拿到单独的年和月了。
    NSDate *lastMonDate = [calender dateFromComponents:cmp];
    
    //上月
    NSDateFormatter * dateFormatterM =[[NSDateFormatter alloc] init];
    [dateFormatterM setDateFormat:@"YY/MM/dd/HH/mm"];
    NSString * lastMonthString = [dateFormatterM stringFromDate:lastMonDate];
    NSMutableArray * lastMonthArr = (NSMutableArray *)[lastMonthString componentsSeparatedByString:@"/"];
    [lastMonthArr replaceObjectAtIndex:3 withObject:@"1"];
    [lastMonthArr replaceObjectAtIndex:4 withObject:@"00"];
    //上月一号
    [record addObject:lastMonthArr];
    
    
    NSDate * currentDate = [NSDate date];
    NSDateFormatter * dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YY/MM/dd/HH/mm"];
    NSString *dateString1 = [dateFormatter stringFromDate:currentDate];
    NSMutableArray *arr1 = (NSMutableArray *)[dateString1 componentsSeparatedByString:@"/"];// '/'分割日期字符串,得到一数组
    //本月1号
    NSMutableArray * curentArr = [[NSMutableArray alloc] initWithArray:arr1];
//时清零
    [curentArr replaceObjectAtIndex:4 withObject:@"00"];
    
    [arr1 replaceObjectAtIndex:3 withObject:@"1"];
    [arr1 replaceObjectAtIndex:4 withObject:@"00"];
    [record addObject:arr1];
    //当前时间
    [record addObject:curentArr];
//    [record addObject:arr1];
    
    return record;
}

//输入一个起始时间,返回一个时间戳数组
- (NSMutableArray *)compare:(int)a :(int)b :(int)day
{
    NSMutableArray * date = [[NSMutableArray alloc] init];
    for (int i = 0; i<day; i++) {
        date[i] = [[NSMutableArray alloc] init];
        for (int j=0; j<2; j++) {
            date[i][j] = [[NSMutableArray alloc] init];
        }
    }
    
    NSMutableArray * record = [[NSMutableArray alloc] init];//日期数组record[1]存储第一天的数组
    NSDate * currentDate = [NSDate date];
    NSDateFormatter * dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YY/MM/dd/HH/mm"];
    NSTimeInterval  oneDay = 24*60*60*1;  //1天的长度
    for (int i = day -1; i>=0; i--) {
        NSDate *theDate1;
        theDate1 = [currentDate initWithTimeIntervalSinceNow: -oneDay*i];
        NSString *dateString1 = [dateFormatter stringFromDate:theDate1];
        NSArray *arr1 = [dateString1 componentsSeparatedByString:@"/"];// '/'分割日期字符串,得到一数组
        [record addObject:arr1];
    }
    if (a>b) {
        for (int i=0 ; i<day; i++) {
            
            if (i == day -1) {
                if (a < [record[i][3] intValue]) {
                    //最后一天时间从开始到当前时间
                    for (int k = 0; k<5; k++) {
                        [date[i][0] addObject:record[i][k]];
                    }
                    [date[i][0] replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d",a] ];
                    
                    date[i][1] = record[i];
                }else{
                    //最后一天时间没到
                }
            }else{
                
                for (int k = 0; k<5; k++) {
                    [date[i][0] addObject:record[i][k]];
                }
                [date[i][0] replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d",a] ];
                
                //下面处理结束时间点
                if(i ==  day -2){
                    //处理倒数第二天的结束超过当前时间
                    if (b >= [record[i][3] intValue]) {
                        for (int k = 0; k<5; k++) {
                            [date[i][1] addObject:record[i+1][k]];
                        }
                        
                    }else{//正常情况
                        for (int k = 0; k<5; k++) {
                            [date[i][1] addObject:record[i+1][k]];
                        }
                        [date[i][1] replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d",b] ];
                    }
                    
                }else{  //除去倒数第一和倒数第二的处理
                    
                    for (int k = 0; k<5; k++) {
                        [date[i][1] addObject:record[i+1][k]];
                    }
                    [date[i][1] replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d",b] ];
                    
                }
                //结束
                
            }
            
        }
        
    }else{           //不隔天
        
        for (int i=0 ; i<day; i++) {
            
            if (i == day - 1) { //  最后一天
                if (a < [record[i][3] intValue]) {
                    //最后一天时间从开始到当前时间
                    for (int k = 0; k<5; k++) {
                        [date[i][0] addObject:record[i][k]];
                    }
                    [date[i][0] replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d",a] ];
                    
                    if (b <= [record[i][3] intValue]) {
                        for (int k = 0; k<5; k++) {
                            [date[i][1] addObject:record[i][k]];
                        }
                        [date[i][1] replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d",b] ];
                    }else{
                        for (int k = 0; k<5; k++) {
                            [date[i][1] addObject:record[i][k]];
                            
                        }
                        
                    }
                    
                }else{
                    //最后一天时间没到
                }
            }else{ //前两天
                
                for (int k = 0; k<5; k++) {
                    [date[i][0] addObject:record[i][k]];
                }
                [date[i][0] replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d",a] ];
                
                
                for (int k = 0; k<5; k++) {
                    [date[i][1] addObject:record[i][k]];
                }
                [date[i][1] replaceObjectAtIndex:3 withObject:[NSString stringWithFormat:@"%d",b] ];
                
            }
            
        }
        
    }
    NSMutableArray *sendArr = [NSMutableArray array];
    for (int i = 0; i<date.count; i++) {
        NSArray *arr = date[i];
        for (int i = 0; i<arr.count; i++) {
            if ([arr[i] count] != 0) {
                [sendArr addObject:arr[i]];
            }
        }
    }
    return sendArr;
}



#pragma mark -- 状态处理模块

- (void)writeDataToHostStatusWithTimeArr:(NSArray *)timeArr WithRequest_type:(int ) request_type
{
    HYExplainManager *expalin = [HYExplainManager shareManager];
    HYSingleManager *manager = [HYSingleManager sharedManager];
    manager.memory_Array = [[NSMutableArray alloc] init];
    _timeArr = timeArr;
    request_type = request_type;
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        for (int j = 0; j<company.child_obj1.count; j++) {
            CTerminalModel *terminal = company.child_obj1[j];
            unsigned int Pn[200];
            int len = 0;
            for (int k = 0; k<terminal.child_obj.count; k++,len++) {
                CMPModel *mp = terminal.child_obj[k];
                Pn[k] = mp.mp_point;
            }
            // ------没有设备.跳出本次循环
            if (len == 0) {
                continue;
            }
            unsigned char outbuf[1024];
            for (int l = 0; l<timeArr.count; l++) {
                NSArray *time = timeArr[l];
                int length = [expalin TSR376_GetACK_QueryInfFame:terminal.term_ID mp_pointArr:Pn mp_pointNum:len timeArr:time request_type:request_type Usr_checkID:manager.user.check_ID OutBufData:outbuf];
                NSData *data = [NSData dataWithBytes:outbuf length:length];
                [_sendSocket writeData:data withTimeout:10 tag:0];
            }
        }
    }
}

-(BOOL)isFinished1{
    HYSingleManager * manager = [HYSingleManager sharedManager];
    int mpNum = 0;
    for (int a = 0; a<manager.archiveUser.child_obj.count; a++) {
        CCompanyModel *company = manager.archiveUser.child_obj[a];
        for (int b = 0; b<company.child_obj1.count; b++) {
            CTerminalModel *terminal = company.child_obj1[b];
                for (int c = 0; c<terminal.child_obj.count; c++) {
                    mpNum ++;
                }
        }
    }
    if (manager.memory_Array.count == mpNum) {
        return  YES;
    }
    return NO;
}

@end

//
//  HYScoketManage.h
//  HYSEM
//
//  Created by 王一成 on 2017/2/24.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MessageModel.h"

@interface HYScoketManage : NSObject
//设备ID
@property (nonatomic,copy) NSArray * deviceID;

+(id)shareManager;

//登录，获取用户相关信息
-(void)getNetworkDatawithIP:(NSString *)ipv6Addr withTag:(NSString *)tag;
//用量
-(void)writeDataToHostWithL:(NSString *)l;

- (void)writeDataToHostWithMonth;

-(void)writeDataToHost1;
//分段
- (void)writeDataToHostWithTime:(NSArray *)time;

//状态
- (void)writeDataToHostStatusWithTimeArr:(NSArray *)timeArr WithRequest_type:(int ) request_type;

//validateSocket
- (BOOL)validateSocket;

- (void)writeDataToHostWithTag:(NSString *)tag;
// ------欠费提醒
- (void)writeMessageDataToHostWith:(MessageModel *)messageModel;
//-------注册
- (void)registToHostWithUser:(NSString *)user;

@property (nonatomic,weak) id delegate;

@property (nonatomic,assign) UInt64 mpID;//上传订单信息时传入

@property (nonatomic,copy) NSString * fee; //上传订单信息时传入 费用

@end

//
//  DateModel.h
//  HYSEM
//
//  Created by 王一成 on 2017/3/14.
//  Copyright © 2017年 WGM. All rights reserved.
//
/***
 **状态数据存储，day那一天的数据
 ** data 该day的数据
 **
 **
 */
#import <Foundation/Foundation.h>
#import "DataModel.h"
@interface DateModel : NSObject

@property (nonatomic,copy) NSString * day;

@property (nonatomic,copy) NSString * month;

@property (nonatomic,copy) NSString * year;

@property (nonatomic,strong) NSMutableArray * data;

@end

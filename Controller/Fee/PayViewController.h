//
//  PayViewController.h
//  HYSEM
//
//  Created by 王一成 on 2017/4/26.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "HYBaseViewController.h"
#import "Node.h"

@interface PayViewController : HYBaseViewController

@property (nonatomic,copy) NSString * total_amount;

@property (nonatomic,strong) NSMutableArray * dataArr; //node Node * node = [self.dataArr objectAtIndex:0];

@property (nonatomic,copy) void(^refreshFee)(NSString * fee);

@end

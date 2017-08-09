//
//  ArchieveModel.m
//  SEMPay
//
//  Created by 王一成 on 2017/4/17.
//  Copyright © 2017年 Yicheng.Wang. All rights reserved.
//

#import "ArchieveModel.h"

@implementation ArchieveModel

- (void) upDataCellWithData:(NSArray *) data
{
    self.name = data[0];
    self.company = data[1];
    self.group = data[2];
}
@end

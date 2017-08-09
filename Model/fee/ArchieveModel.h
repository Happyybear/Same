//
//  ArchieveModel.h
//  SEMPay
//
//  Created by 王一成 on 2017/4/17.
//  Copyright © 2017年 Yicheng.Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArchieveModel : NSObject

@property (nonatomic,copy) NSString * company;
@property (nonatomic,copy) NSString * group;
@property (nonatomic,copy) NSString * name;

- (void) upDataCellWithData:(NSArray *) data;
@end

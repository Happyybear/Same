//
//  PayView.h
//  PayView
//
//  Created by 王一成 on 2017/4/14.
//  Copyright © 2017年 Yicheng.Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayView : UIView
@property (nonatomic,strong) NSArray * nameArr;
@property (nonatomic,strong) NSMutableArray * dataArr;
@property (nonatomic,copy) void(^pay1)(NSString * price);
- (void)createLeabel;
@end

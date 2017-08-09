//
//  ShowView.m
//  HYSEM
//
//  Created by 王一成 on 2017/5/16.
//  Copyright © 2017年 WGM. All rights reserved.
//
/** 
 *
 *
 *
 **/
#import "ShowView.h"

@implementation ShowView
{
    /** 背景*/
    UIView * bgView;
    /** 剩余金额*/
    UILabel * fee;
    /** 本月消费*/
    UILabel * cost;
    /** 店标名称*/
    UILabel *name;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)init
{
    if (self = [super init]) {
        [self configUI];
    }
    return self;
}
#pragma mark - **************** UI
- (void)configUI
{
    // ------lazyLoad
    if (!bgView) {
        bgView  = [FactoryUI createViewWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H* 2/5)];
        [self addSubview:bgView];
    }
    if (!cost) {
        cost = [FactoryUI createLabelWithFrame:CGRectMake(15*ScreenMultiple, SCREEN_H*2/5 - 35 *ScreenMultiple, SCREEN_W/2, 15) text:nil textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15]];
        cost.text = @"12.77";
        cost.textAlignment = NSTextAlignmentCenter;
        [self addSubview:cost];
    }
    if (!name) {
        name = [FactoryUI createLabelWithFrame:CGRectMake(SCREEN_W/2 + 15*ScreenMultiple, SCREEN_H*2/5 - 35 *ScreenMultiple, SCREEN_W/2, 15) text:nil textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15]];
        name.text = @"asdasd";
        name.textAlignment = NSTextAlignmentCenter;
        [self addSubview:name];
    }
    if (!fee) {
        fee = [FactoryUI createLabelWithFrame:CGRectMake(0, SCREEN_H*2/5*2/5, SCREEN_W, 30*ScreenMultiple) text:nil textColor:[UIColor whiteColor] font:[UIFont boldSystemFontOfSize:40]];
        fee.text = @"67.90";
        fee.textAlignment = NSTextAlignmentCenter;
        [self addSubview:fee];

    }
    // ------当前剩余金额Label
    UILabel * currentFee = [FactoryUI createLabelWithFrame:CGRectMake(0, SCREEN_H*2/5*2/5 -25*ScreenMultiple, SCREEN_W, 15*ScreenMultiple) text:nil textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15]];
    currentFee.text = @"剩余金额(元)";
    currentFee.textAlignment = NSTextAlignmentCenter;
    [self addSubview:currentFee];
    
    // ------消费Label
    UILabel * staticCost = [FactoryUI createLabelWithFrame:CGRectMake(15*ScreenMultiple, SCREEN_H*2/5 - (23+20+15) *ScreenMultiple, SCREEN_W/2, 20) text:nil textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15]];
    staticCost.textAlignment = NSTextAlignmentCenter;
    staticCost.text = @"本月消费";
    [self addSubview:staticCost];
    
    // ------名称
    UILabel * statciName = [FactoryUI createLabelWithFrame:CGRectMake(SCREEN_W/2 + 15*ScreenMultiple, SCREEN_H*2/5 - (23+20+15)*ScreenMultiple, SCREEN_W/2, 20) text:nil textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15]];
    statciName.textAlignment = NSTextAlignmentCenter;
    statciName.text = @"名称";
    [self addSubview:statciName];
    
    UILabel * line = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_W/2, SCREEN_H*2/5 - 55 *ScreenMultiple, 2, 50*ScreenMultiple)];
    [self addSubview:line];
    line.backgroundColor = [UIColor whiteColor];
}

- (void)reloadData
{
    /** 剩余金额*/
    fee.text = self.data.ramain_Fee;
    /** 本月消费*/
    cost.text = @"---";
    /** 店标名称*/
    name.text = self.data.name;
}
@end

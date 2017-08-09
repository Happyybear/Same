//
//  PayOrederRecordView.m
//  HYSEM
//
//  Created by 王一成 on 2017/5/17.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "PayOrederRecordView.h"



@implementation PayOrederRecordView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

#pragma mark - **************** UI
- (void)reloadData
{
//    CGRectMake(10*ScreenMultiple, CGRectGetMaxY(tipAction.frame) + 15*ScreenMultiple, SCREEN_W - 20*ScreenMultiple, averageH)
    NSInteger count = [self.delegate numRowOfSection];
    CGFloat height = [self.delegate heightForRow];
    for (int i = 0; i<count; i++) {
        UIButton * btn = [FactoryUI createButtonWithFrame:CGRectMake(0,height*i + 15*ScreenMultiple*(i) , self.frame.size.width, height) title:nil titleColor:nil imageName:nil backgroundImageName:nil target:self selector:@selector(gotoAction:)];
        btn.tag = 7777 + i;
        btn.backgroundColor = [UIColor whiteColor];
        [self addSubview:btn];
        [self addLabelWithFrame:(btn.frame) plat:btn];
    }
    
}

- (void)addLabelWithFrame:(CGRect)frame plat:(UIView*)btn{
    UILabel * name = [FactoryUI createLabelWithFrame:CGRectMake(5*ScreenMultiple, 5*ScreenMultiple, SCREEN_W/2-5*ScreenMultiple, (frame.size.height - 10*ScreenMultiple)/2) text:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:15]];
    name.text = @"缴费人:316";
    [btn addSubview:name];
    
    UILabel * time = [FactoryUI createLabelWithFrame:CGRectMake(5*ScreenMultiple, frame.size.height/2 + 5*ScreenMultiple, SCREEN_W/2-5*ScreenMultiple, (frame.size.height - 10*ScreenMultiple)/2) text:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:15]];
    time.text = @"1993/11/20";
    [btn addSubview:time];
    
    UILabel * fee = [FactoryUI createLabelWithFrame:CGRectMake(frame.size.width/2+5*ScreenMultiple,  5*ScreenMultiple, SCREEN_W/2-15*ScreenMultiple, (frame.size.height - 10*ScreenMultiple)) text:nil textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:25]];
    fee.textAlignment = NSTextAlignmentRight;
    [btn addSubview:fee];
    fee.text = @"98.11";

    
}

-(void)gotoAction:(UIButton *)btn
{
    [self.delegate viewDidSelectedAtIndex:btn.tag - 7777];
}
@end

//
//  UIButton+flag.m
//  HYSEM
//
//  Created by 王一成 on 2017/3/20.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "UIButton+flag.h"

#import <objc/runtime.h>

@implementation UIButton (flag)

static NSString * _flagStr;
static int * _intFlag;

- (void)setFlag:(NSString *) flag{
    objc_setAssociatedObject(self, &_flagStr, flag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- ( NSString *)flagStr{
    return  objc_getAssociatedObject(self, &_flagStr);
}

-(void) setIntFlag:(long long)intFlag{
    NSNumber * t = @(intFlag);
    objc_setAssociatedObject(self, &_intFlag, t, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (long long)intFlag{
    NSNumber * t = objc_getAssociatedObject(self, &_intFlag);
    return [t longLongValue];
}

#pragma mark - **************** 扩大button响应区域
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds = self.bounds;
    //若原热区小于44x44，则放大热区，否则保持原大小不变
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}
@end

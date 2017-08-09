//
//  ArchieveTree.h
//  HYSEM
//
//  Created by 王一成 on 2017/6/2.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"

@interface ArchieveTree : UIView

@property (nonatomic,copy) void(^cotrolerSelected)(Node * node);

//点击回调,n--YES确认，n--NO取消
@property (nonatomic,copy) void(^clickAction)(NSString * n);

@property (nonatomic,copy) NSString * kind;

- (void)configUI;
- (id)initWithFrame:(CGRect)frame;
@end

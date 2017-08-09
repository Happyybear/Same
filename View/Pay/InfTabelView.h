//
//  InfTabelView.h
//  SEMPay
//
//  Created by 王一成 on 2017/4/19.
//  Copyright © 2017年 Yicheng.Wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"

@protocol infoTableView <NSObject>

- (void)cellClick:(Node *)node;

@end


@interface InfTabelView : UITableView
@property (nonatomic,weak) id infoDelegate;
- (id)initWithFrame:(CGRect)frame WithData:(NSMutableArray *) tempArray;
@end

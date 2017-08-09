//
//  SearchDisplayViewController.h
//  HYSEM
//
//  Created by 王一成 on 2017/4/27.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "HYBaseViewController.h"
#import "Node.h"
@interface SearchDisplayViewController : HYBaseViewController
@property (nonatomic,retain) NSMutableArray * dispalyData;
@property (nonatomic,copy) void(^gotoInfo)(Node * node);
- (void)reloadData;
@end

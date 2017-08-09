//
//  ArchieveTreeCell.h
//  HYSEM
//
//  Created by 王一成 on 2017/6/2.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"
#import "UIButton+flag.h"

@interface ArchieveTreeCell : UITableViewCell

@property (nonatomic,strong) UILabel *label;

@property (nonatomic,assign) NSInteger cellLevel;

@property (nonatomic,strong) UIView *view;

@property (nonatomic,assign) NSInteger isSelected;

@property (nonatomic,strong) NSMutableArray * btnArr;

-(void)refreshWithNode:(Node *)node;

@property (nonatomic,copy) void(^bthClick)();

@property (nonatomic,strong) NSMutableArray * tempData;

@property (nonatomic,strong) NSMutableArray * dataSource;

-(void)UI;

@end

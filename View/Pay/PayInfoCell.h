//
//  PayInfoCell.h
//  HYSEM
//
//  Created by 王一成 on 2017/5/4.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Node.h"

@interface PayInfoCell : UITableViewCell

- (void)upDataCellWithData:(Node *)data;

@property (nonatomic,strong) Node * node;

@property (nonatomic,copy) void(^startToPay)(NSString * mpID,NSString * fee,NSString * mpName);

@end

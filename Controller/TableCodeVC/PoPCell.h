//
//  PoPCell.h
//  HYSEM
//
//  Created by 王一成 on 2017/8/8.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^deleteCell)(NSString * mpID);

@interface PoPCell : UITableViewCell

@property (nonatomic,copy) NSString * name;

@property (nonatomic,strong) UILabel * device_name;

@property (nonatomic,strong) UIButton * deleteBtn;

@property (nonatomic,copy) deleteCell deleteBlock;

@property (nonatomic,copy) NSString * MpID;

@end

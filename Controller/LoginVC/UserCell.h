//
//  UserCell.h
//  HYSEM
//
//  Created by 王一成 on 2017/6/23.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageUser;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtb;

@property (nonatomic,copy) void (^deletUser)(NSString * name);

@end

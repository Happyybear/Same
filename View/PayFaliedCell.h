//
//  PayFaliedCell.h
//  HYSEM
//
//  Created by 王一成 on 2017/5/12.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayFaliedCell : UITableViewCell

@property (nonatomic,copy) NSString * m_name;

@property (nonatomic,copy) NSString * m_labelText;

- (void)reloadData;

@end

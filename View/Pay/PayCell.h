//
//  PayCell.h
//  HYSEM
//
//  Created by 王一成 on 2017/4/26.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayCell : UITableViewCell
@property (nonatomic,retain) UIImageView * image;
@property (nonatomic,retain) UILabel * label;
@property (nonatomic,retain) UIImageView * mark;
- (void)refreshMarkWithTag:(NSString *)tag;
- (void)refreshUIWithtag:(NSInteger)tag;

@end

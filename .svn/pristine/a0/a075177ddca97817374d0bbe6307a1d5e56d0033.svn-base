//
//  ArchieveTreeTableView.h
//  HYSEM
//
//  Created by 王一成 on 2017/6/2.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Node;

@protocol ArchieveTreeTableCellDelegate <NSObject>

- (void)cellClick:(Node *)node;

@end

@interface ArchieveTreeTableView : UITableView

@property (nonatomic,weak) id<ArchieveTreeTableCellDelegate> treeTableCellDelegate;

- (instancetype)initWithFrame:(CGRect)frame withData:(NSArray *)data;

//@property (nonatomic,strong) NSMutableArray * archieveData;

- (void )refreshTree:(NSMutableArray *)m_data;
@end

//
//  ArchieveTreeCell.m
//  HYSEM
//
//  Created by 王一成 on 2017/6/2.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "ArchieveTreeCell.h"
#import "CaTreeModel.h"

@implementation ArchieveTreeCell
{
    Node *node1;
}

static NSMutableArray * dataArrary;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _btnArr = [NSMutableArray new];
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)UI
{
    _view = [[UIView alloc]init];
    [self.contentView addSubview:_view];
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, SCREEN_W-40, 20)];
    //    [_view addSubview:self.btn];
    [_view addSubview:_label];
}

- (void)refreshWithNode:(Node *)node
{
    node1 = node;
    [_label setFont:[UIFont systemFontOfSize:14]];
    _label.textColor = [UIColor whiteColor];
    _label.text = node.name;
    _view.frame = CGRectMake(30 * node.depth,0,[[UIScreen mainScreen] bounds].size.width , 40);
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end



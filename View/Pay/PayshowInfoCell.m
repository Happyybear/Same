//
//  CaTreeCell.m
//  SEM
//
//  Created by xlc on 16/11/2.
//  Copyright © 2016年 王广明. All rights reserved.
//

#import "PayshowInfoCell.h"
#import "CaTreeModel.h"

@implementation PayshowInfoCell
{
    Node *node1;
    UIView * bView;
}

static NSMutableArray * dataArrary;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self UI];
    }
    return self;
}

- (void)UI
{
    _view = [[UIView alloc]init];
    _view.backgroundColor = [UIColor clearColor];
    bView = [[UIView alloc] initWithFrame:CGRectMake(2, 5, SCREEN_W - 10 , self.contentView.frame.size.height - 10)];
    bView.backgroundColor = RGB(211, 211, 211);
    //    bView.layer.cornerRadius = (self.contentView.frame.size.height -4)/4;
    [bView addSubview:_view];
    [self.contentView addSubview:bView];
    self.contentView.backgroundColor = RGB(240, 255, 255);
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, SCREEN_W-40, 20)];
    //    [_view addSubview:self.btn];
    [_view addSubview:_label];
    self.btn.frame = CGRectMake(10, 10, 20, 20);
}



- (void)refreshWithNode:(Node *)node
{
    
    node1 = node;
    [_label setFont:[UIFont systemFontOfSize:14]];
    _label.text = node.name;
    _view.frame = CGRectMake(30 * node.depth,0,[[UIScreen mainScreen] bounds].size.width -30 * node.depth , 40);
    
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end

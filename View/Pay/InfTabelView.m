
//
//  InfTabelView.m
//  SEMPay
//
//  Created by 王一成 on 2017/4/19.
//  Copyright © 2017年 Yicheng.Wang. All rights reserved.
//

#import "InfTabelView.h"
#import "InfoModel.h"
#import "PayshowInfoCell.h"
#import "InfoModel.h"
@interface InfTabelView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) NSMutableArray *tempData;//用于存储数据源（部分数据）

@end

@implementation InfTabelView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (id)initWithFrame:(CGRect)frame WithData:(NSMutableArray *) tempArray
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        _tempData = tempArray;
    }
    return self;
}

/**
 * 初始化数据源
 */
//-(NSMutableArray *)createTempData : (NSArray *)data{
//    NSMutableArray *tempArray = [NSMutableArray array];
//    for (int i=0; i<data.count; i++) {
//        Node *node = [_data objectAtIndex:i];
//        if (node.expand) {
//            [tempArray addObject:node];
//        }
//    }
//    return tempArray;
//}


#pragma mark - UITableViewDataSource

#pragma mark - Required


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tempData.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    InfoModel * model = _tempData[section];
    if (model.isHide == nil ) {
        return 0;
    }
    return model.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *NODE_CELL_ID = @"node_cell_id";
    PayshowInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NODE_CELL_ID];
    if (!cell) {
        cell = [[PayshowInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NODE_CELL_ID];
    }
    // cell有缩进的方法
    //cell.indentationLevel = node.depth; // 缩进级别
    //cell.indentationWidth = 30.f; // 每个缩进级别的距离
    cell.selectionStyle = UITableViewCellAccessoryNone;
    InfoModel * model = _tempData[indexPath.section];
    Node * node = model.data[indexPath.row];
    [cell refreshWithNode:node];
    DLog(@"--%@",node.name);
    return cell;
}


#pragma mark - Optional
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    InfoModel * model = _tempData[section];
    Node * node = model.node;
    UIView * view = [FactoryUI createViewWithFrame:CGRectMake(0, 0, SCREEN_W, 40)];
    UIButton * btn =[FactoryUI createButtonWithFrame:CGRectMake(5, 5, SCREEN_W - 10, 40 - 10) title:node.name titleColor:[UIColor blackColor] imageName:nil backgroundImageName:nil target:self selector:@selector(isCellShow:)];
    btn.tag = section + 9988;
    btn.backgroundColor = RGB(240, 248, 255);
    [view addSubview:btn];
    return view;
}

- (void)isCellShow:(UIButton *)btn
{
    NSInteger section = btn.tag - 9988;
    InfoModel * model = _tempData[section];
    if ([model.isHide isEqualToString:@"NO"]) {
        model.isHide = nil;
    }else{
        model.isHide = @"NO";
    }
    [self reloadSections:[NSIndexSet indexSetWithIndex:section]withRowAnimation:UITableViewRowAnimationFade];//有动画的刷新
    

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}


#pragma mark - UITableViewDelegate

#pragma mark - Optional
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    InfoModel * model = _tempData[indexPath.section];
    NSArray * a = model.data;
    Node * node = a[indexPath.row];
    if (_infoDelegate && [_infoDelegate respondsToSelector:@selector(cellClick:)]) {
        [_infoDelegate cellClick:node];
    }
}
@end

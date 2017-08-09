//
//  ArchieveTree.m
//  HYSEM
//
//  Created by 王一成 on 2017/6/2.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "ArchieveTree.h"
#import "ArchieveTreeTableView.h"
#import "Node.h"

@interface ArchieveTree()

@property (nonatomic,strong) ArchieveTreeTableView * tree;

@end

@implementation ArchieveTree
{
    UISegmentedControl       * _segment;
    NSMutableArray          * _dataSource;
    UISearchController       * _searchController;
    Node                  * _selectedNode;// ------选中的Node
    int                   op_type;//操作类型
    UILabel                * _op_tip;//操作标签
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)configUI
{

    if ([self.kind isEqualToString:@"concern"]) {//关注
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 6.0;
        self.layer.masksToBounds = YES;
//        self.layer.borderWidth = 1;
    }else{
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 6.0;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1;
    }
    self.alpha = 1;
//    [self addSegment];
    // ------安安书
    [self addTree];
    // ------确认取消按钮
    [self addBtn];
    // ------添加搜索条
    [self addSearchBar];
    
}

// ------搜索条
- (void)addSearchBar
{
    
}

- (void)addBtn{
    op_type = 0;//设备
    if ([self.kind isEqualToString:@"concern"]) {
        //关注
    }else{
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(_tree.frame) +10, 110*ScreenMultiple, 30*ScreenMultiple)];
        btn.selected = YES;
        [btn setTitle:@"终端" forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5;
        [self addSubview:btn];
        [btn setBackgroundColor:[UIColor colorWithRed:46/255.0 green:149/255.0 blue:250/255.0 alpha:1.0]];
        [btn addTarget:self action:@selector(changeData:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_W - 40*2*ScreenMultiple -20-110, 10+CGRectGetMaxY(_tree.frame), 110*ScreenMultiple, 30*ScreenMultiple)];
        [btn1 setTitle:@"取消" forState:UIControlStateNormal];
        btn1.layer.cornerRadius = 5;
        [btn1 setBackgroundColor:[UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
        [self addSubview:btn1];
        [btn1 addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
        
        _op_tip = [[UILabel alloc] initWithFrame:CGRectMake(0,69, SCREEN_W, 40*ScreenMultiple
                                                            )];
        _op_tip.textAlignment = NSTextAlignmentCenter;
        _op_tip.text = @"设备";
        _op_tip.textColor = [UIColor whiteColor];
        _op_tip.backgroundColor = [UIColor clearColor];
        [[UIApplication sharedApplication].keyWindow addSubview:_op_tip];
    }
}

- (void)changeData:(UIButton *)btn{
    if (btn.selected) {
        [self getTerData];
        btn.selected = NO;
        op_type = 1;//终端
        [btn setTitle:@"设备" forState:UIControlStateNormal];
        _op_tip.text = @"终端";

    }else if (!btn.selected){
        [self getData];
        btn.selected = YES;
        op_type = 0;//设备
        [btn setTitle:@"终端" forState:UIControlStateNormal];
        _op_tip.text = @"设备";
    }
}
//确认
- (void)sure{
    self.clickAction(@"YES");
    [_op_tip removeFromSuperview];
    _op_tip = nil;
}

#pragma mark - **************** segment(不再使用)
- (void)addSegment
{
    UIView * m_bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30*ScreenMultiple)];
    [self addSubview:m_bg];
    m_bg.backgroundColor = [UIColor grayColor];
    
    _segment = [[UISegmentedControl alloc] initWithItems:@[@"设备",@"终端"]];
    _segment.frame = CGRectMake(40*ScreenMultiple, 0, (SCREEN_W-160*ScreenMultiple), 30*ScreenMultiple);
    _segment.selectedSegmentIndex = 0;
    _segment.tintColor = RGB(1,127,105);
    _segment.backgroundColor = [UIColor whiteColor];
    [_segment addTarget:self action:@selector(selected:) forControlEvents:UIControlEventValueChanged];
    [m_bg addSubview:_segment];
}

- (void)selected:(UISegmentedControl *)seg
{
    if (seg.selectedSegmentIndex == 0) {//档案
        [self getData];
    }else if (seg.selectedSegmentIndex == 1){//监控
        [self getTerData];
    }
}


#pragma mark - **************** 档案树
- (void)addTree{
    [self getData];
    if ([self.kind isEqualToString:@"concern"]) {
       _tree = [[ArchieveTreeTableView alloc] initWithFrame:CGRectMake(40*ScreenMultiple, 40*ScreenMultiple+69, SCREEN_W-80*ScreenMultiple, SCREEN_H - 50*ScreenMultiple - 49) withData:_dataSource];
    }else{
    _tree = [[ArchieveTreeTableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 50 *ScreenMultiple) withData:_dataSource];
    }
    _tree.treeTableCellDelegate = self;
    _tree.separatorStyle = NO;
    [self addSubview:_tree];
}

#pragma mark - **************** 获取电表数据
- (void)getData
{
    HYSingleManager *manager = [HYSingleManager sharedManager];
    NSMutableArray *nodeArr = [[NSMutableArray alloc]init];
    _dataSource = [[NSMutableArray alloc] init];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        Node *node = [[Node alloc]initWithParentId:-1 nodeId:company.strID name:company.name depth:0 expand:YES mpID:[company UInt64ToString:company.strID] Fee:nil];
        [nodeArr addObject:node];
        for (int j = 0; j<company.child_obj.count; j++) {
            CTransitModel *transit = company.child_obj[j];
            Node *node = [[Node alloc]initWithParentId:company.strID nodeId:transit.strID name:transit.name depth:1 expand:YES mpID:[transit UInt64ToString:transit.strID] Fee:nil];
            [nodeArr addObject:node];
            for (int k = 0; k<transit.child_obj.count; k++) {
                CSetModel *set = transit.child_obj[k];
                Node *node = [[Node alloc]initWithParentId:transit.strID nodeId:set.strID name:set.name depth:2 expand:YES mpID:[set UInt64ToString:set.strID] Fee:nil];
                [nodeArr addObject:node];
                for (int m = 0; m<set.child_obj.count; m++) {
                    CMPModel *mp = set.child_obj[m];
                    Node *node = [[Node alloc]initWithParentId:set.strID nodeId:mp.strID name:mp.name depth:3 expand:YES mpID:[mp UInt64ToString:mp.strID] Fee:nil];
                    [nodeArr addObject:node];
                }
            }
        }
    }
    if (nodeArr.count>0) {
        _dataSource = nodeArr;
        [_tree refreshTree:_dataSource];
    }
    
}

#pragma mark - **************** 获取终端档案
- (void)getTerData
{
    HYSingleManager *manager = [HYSingleManager sharedManager];
    NSMutableArray *nodeArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        Node *node = [[Node alloc]initWithParentId:-1 nodeId:company.strID name:company.name depth:0 expand:YES mpID:[company UInt64ToString:company.strID] Fee:nil];
        [nodeArr addObject:node];
        for (int j = 0; j<company.child_obj1.count; j++) {
            CTransitModel *transit = company.child_obj1[j];
            Node *node = [[Node alloc]initWithParentId:company.strID nodeId:transit.strID name:transit.name depth:1 expand:YES mpID:[transit UInt64ToString:transit.strID] Fee:nil];
            [nodeArr addObject:node];
        }
    }
    if (nodeArr.count >0) {
        _dataSource = nodeArr;
        [_tree refreshTree:_dataSource];

    }
}
#pragma mark - **************** 点击选择
- (void)cellClick:(Node *)node
{
    if (op_type == 0) {
        //保存选择的设备
        if (node.depth == 3) {
            //关注
            if ([self.kind isEqualToString:@"concern"]) {
                NSMutableArray * concernArr = [[NSMutableArray alloc] init];
                NSArray * arr = [[NSArray alloc] init];
                if ([HY_NSusefDefaults objectForKey:@"concern"]) {
                    arr = (NSMutableArray *)[HY_NSusefDefaults objectForKey:@"concern"];
                    
                }
                if(arr.count < 5){
                    if (![arr containsObject:node.MpID]) {
                        for (NSString * obj in arr) {
                            [concernArr addObject:obj];
                        }
                        [concernArr addObject:node.MpID];
                    }else{
                        concernArr = arr;
                    }
                }else{
                    [UIView addMJNotifierWithText:@"最多只能关注5个设备" dismissAutomatically:YES];
                    return;
                }
                
                HYSingleManager * manager = [HYSingleManager sharedManager];
                [HY_NSusefDefaults setObject:[NSString stringWithFormat:@"%llu",manager.user.user_ID] forKey:@"concernID"];
                [HY_NSusefDefaults setObject:concernArr forKey:@"concern"];
            }else{
                //遥控
                [HY_NSusefDefaults setObject:@[[NSNumber numberWithInt:node.depth],node.MpID] forKey:@"controlSeletced"];
            }
            //遥控
            _selectedNode = node;
            self.cotrolerSelected(node);
         
            //synchronize
            [HY_NSusefDefaults synchronize];
            self.clickAction(@"YES");
        }
    }
    else if (op_type == 1){
        //保存选择的终端
        if (node.depth == 1) {
            _selectedNode = node;
            self.cotrolerSelected(node);
            [HY_NSusefDefaults setObject:@[[NSNumber numberWithInt:node.depth],node.MpID] forKey:@"controlSeletced"];
            [HY_NSusefDefaults synchronize];
            self.clickAction(@"YES");
        }
    }
    [_op_tip removeFromSuperview];
    _op_tip = nil;
    DLog(@"%@",node.name);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
   
    CGPoint point = [[touches anyObject] locationInView:self];
    if (point.x >= 40*ScreenMultiple &&point.x <= SCREEN_W-80*ScreenMultiple +40*ScreenMultiple && point.y >= 40*ScreenMultiple+69 && point.y <= SCREEN_H + 64 - 49 ) {
        
    }else{
        [UIView animateWithDuration:0.8 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
    

}
@end

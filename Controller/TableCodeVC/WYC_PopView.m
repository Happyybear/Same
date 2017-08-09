//
//  WYC_PopView.m
//  HYSEM
//
//  Created by 王一成 on 2017/8/4.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "WYC_PopView.h"

#import "PoPCell.h"

#import "ArchieveTree.h"

@interface WYC_PopView()<UITableViewDelegate,UITableViewDataSource>
{
    ArchieveTree * tree;
}
@property (nonatomic,retain) UITableView       * tableView;
@property (nonatomic,retain) UIView           * bgView;
@property (nonatomic,retain) NSMutableArray    * dataSource;
@property (nonatomic,strong) UIButton         * deleteBtn;
@property (nonatomic,retain) NSMutableArray    * showData;

@end

static const CGFloat everyW = 150;
static const CGFloat everyH = 50;
// tableView的最小高度为10，会随着cell个数的增加改变
@implementation WYC_PopView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self getData];
        [self createUIWithCount:_dataSource.count];
    }
    return self;
}
//-------判断用户是否发生改变
- (bool)userIDisChange{
    HYSingleManager * manager = [HYSingleManager sharedManager];
    NSString * m_id = [HY_NSusefDefaults objectForKey:@"concernID"];
    if ([m_id isEqualToString:[NSString stringWithFormat:@"%llu",manager.user.user_ID]]) {
        return NO;
    }else{
        return YES;
    }
}
//--------从userdefaults中获取数据源
- (void)getData{
    //判断ID是否变了
    if ([self userIDisChange]) {
        [HY_NSusefDefaults removeObjectForKey:@"concern"];
    }
    _showData = [[NSMutableArray alloc] init];
    HYSingleManager *manager = [HYSingleManager sharedManager];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        for (int j = 0; j<company.child_obj1.count; j++) {
            CTransitModel *transit = company.child_obj1[j];
            for (int m = 0 ;m < transit.child_obj.count; m++) {
                CMPModel * cm = transit.child_obj[m];
                for (NSString * mpID in self.dataSource) {
                    if ([mpID isEqualToString:[NSString stringWithFormat:@"%llu",cm.strID]]) {
                        //添加电表名称
                        [_showData addObject:cm.name];
                    }
                }
            }
        }
    }

}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
        if ([HY_NSusefDefaults objectForKey:@"concern"]) {
            _dataSource = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"concern"]];
        }
    }
    return _dataSource;
}
//UI
- (void)createUIWithCount:(NSInteger)count{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, 194, 302) style:UITableViewStyleGrouped];
    self.tableView.layer.cornerRadius = 10;
    self.tableView.rowHeight = everyH;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.userInteractionEnabled = YES;
    // 大于4项可以滚动
    self.tableView.scrollEnabled = count >4 ? YES : NO;
    //self.bgView.layer.masksToBounds = YES;
    self.tableView.backgroundColor = RGBA(37, 206, 184, 1);
    // 画三角形
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(everyW - 25, 10)];
    [path addLineToPoint:CGPointMake(everyW - 20, 2)];
    [path addLineToPoint:CGPointMake(everyW - 15, 10)];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    // 颜色设置和cell颜色一样
    layer.fillColor = RGBA(37, 206, 184, 1).CGColor;
    layer.strokeColor = RGBA(37, 206, 184, 1).CGColor;
    layer.path = path.CGPath;
    [self.bgView.layer addSublayer:layer];
    
    self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.bgView.userInteractionEnabled = YES;
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.tableView];
    UIButton * n= [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bgView addSubview:n];
}
//展示View
- (void)showInKeyWindow{
    _isShow = YES;
    self.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.transform = CGAffineTransformMakeScale(0.7, 0.7);
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformMakeScale(1, 1);
        self.alpha = 1;
    }];
}
//移除View
- (void)dismissFromKeyWindow{
    _isShow = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformMakeScale(0.7, 0.7);
        self.transform = CGAffineTransformTranslate(self.transform, 40, -64);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.transform = CGAffineTransformIdentity;
        [self removeFromSuperview];
    }];
}


#pragma mark - **************** tableView  delegate
//点击View之外的区域View移除
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    NSLog(@"进入A_View---hitTest withEvent ---");
    UIView * view = [super hitTest:point withEvent:event];
    NSLog(@"离开A_View--- hitTest withEvent ---hitTestView:%@",view);
    if (point.y < 0 || point.y > 320 || point.x < 0) {
        [self dismissFromKeyWindow];
        return view;
    }
    return view;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == _dataSource.count){
        [self addSelectedView];
    }
}

-(void)addSelectedView{
    // ------添加遮罩层
    [self addMaskView];
    // ------btn停止响应:CGRectMake(40*ScreenMultiple, 40*ScreenMultiple+69, SCREEN_W-80*ScreenMultiple, SCREEN_H - 60*ScreenMultiple)]
    tree = [[ArchieveTree alloc] initWithFrame:CGRectMake(0,0,SCREEN_W,SCREEN_H)];
    tree.layer.masksToBounds = YES;
    tree.layer.borderWidth = 0;
    tree.layer.cornerRadius = (SCREEN_W-80*ScreenMultiple)/20;
    tree.kind = @"concern";//关注
    [tree configUI];
    // ------block回调
    __weak typeof(self) weakSelf = self;
    tree.cotrolerSelected = ^(Node * node){
        if (node.depth == 3) {//逻辑树
            if([HY_NSusefDefaults objectForKey:@"concern"]){
                _dataSource = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"concern"]];
                [weakSelf getData];
                [weakSelf.tableView reloadData];
            }
        }else if(node.depth == 1){
//            tipLabel.text = [NSString stringWithFormat:@"选择终端：%@",node.name];
//            kind = 1;
        }
    };
    __weak typeof(tree) weakTree = tree;
    tree.clickAction = ^(NSString * n){// ------点击确认或者取消按钮的回调
        if ([n isEqualToString:@"YES"]) {
            //确认
        }else if ([n isEqualToString:@"NO"]){
            //否认
        }
        [UIView animateWithDuration:0.8 animations:^{
            weakTree.alpha = 0.0;
        } completion:^(BOOL finished) {
            [weakTree removeFromSuperview];
        }];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:tree];
}

- (void)addMaskView
{
    // ------遮罩层
//    if (!bgView) {
//        bgView = [[UIImageView alloc] initWithFrame:CGRectMake(-40*ScreenMultiple, -69-40*ScreenMultiple, SCREEN_W +40*ScreenMultiple, SCREEN_H*2)];
//        //    [self addSubview:bgView];
//        bgView.backgroundColor = [UIColor grayColor];
//        bgView.alpha = 0.8;
//        bgView.userInteractionEnabled = NO;
//        [[UIApplication sharedApplication].keyWindow addSubview:bgView];
//    }
}

- (void)concern{
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _dataSource.count) {
        UITableViewCell * cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"nouse"];
        cell.textLabel.text = @"添加关注";
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = RGBA(37, 206, 184, 1);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        NSString * cellID = @"Mycell";
        PoPCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell = [[PoPCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
            cell.backgroundColor = RGBA(37, 206, 184, 1);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.device_name.text = _showData[indexPath.row];
        cell.MpID = _dataSource[indexPath.row];
        cell.deleteBlock = ^(NSString *mpID){
            for (int m = 0; m<_dataSource.count; m++) {
                if ([_dataSource[m] isEqualToString:mpID]) {
                    //先在数据源删除
                    [_dataSource removeObjectAtIndex:m];
                    [_showData removeObjectAtIndex:m];
                    //在删除本地
                    [self concernDeletIndex:m];
                    //cell删除
                    NSArray * indexPaths = @[indexPath];
                    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        };
        return cell;

    }
}
//本地删除数据项
- (void)concernDeletIndex:(NSInteger)index{
    NSArray * arr = [HY_NSusefDefaults objectForKey:@"concern"];
    NSMutableArray  * mutableArr = [[NSMutableArray alloc]initWithArray:arr];
    [mutableArr removeObjectAtIndex:index];
    NSArray * memory = mutableArr;
    [HY_NSusefDefaults setObject:memory forKey:@"concern"];
}


@end

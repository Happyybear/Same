//
//  PayFailedOrderViewController.m
//  HYSEM
//
//  Created by 王一成 on 2017/5/11.
//  Copyright © 2017年 WGM. All rights reserved.
//
/**
 *处理支付失败，显示失败订单
 *
 *
 *
 *
 */
 
 
 
 

#import "PayFailedOrderViewController.h"
#import "PayFaliedCell.h"
#import "PaymentMethod.h"
#import "HYScoketManage.h"
#import "DataBaseManager.h"
#import "orderModel.h"
@interface PayFailedOrderViewController ()<UITableViewDelegate,UITableViewDataSource>

{
    NSString * order;
}
@property(nonatomic,strong) UITableView * tabelView;

@property(nonatomic,strong) NSArray * dataSource;

@property(nonatomic,strong) NSArray * textDataSource;

@property(nonatomic,strong) NSArray * feeArr;


@end

@implementation PayFailedOrderViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createNavigition];
    [self configTableview];
    [self addAction];
    [self initData];
    // Do any additional setup after loading the view from its nib.
}


- (void)createNavigition
{
    self.titleLabel.text = @"订单";
    [self.leftButton setImage:[UIImage imageNamed:@"icon_function"] forState:UIControlStateNormal];
    [self setLeftButtonClick:@selector(leftButtonClick)];
//    [self.rightButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
//    [self setRightButtonClick:@selector(rightButtonClick)];
//    
}

- (void)leftButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addAction{
    UIButton * btn = [FactoryUI createButtonWithFrame:CGRectMake(10, 50*5*ScreenMultiple +80*ScreenMultiple, SCREEN_W - 20, 40* ScreenMultiple) title:@"提交" titleColor:[UIColor whiteColor] imageName:nil backgroundImageName:nil target:self selector:@selector(pay)];
    btn.backgroundColor = RGB(1,127,105);
    btn.layer.cornerRadius = SCREEN_W/30;
    [self.tabelView addSubview:btn];
    
    UIButton * btn2 = [FactoryUI createButtonWithFrame:CGRectMake(10, 50*5*ScreenMultiple +80*ScreenMultiple +50*ScreenMultiple, SCREEN_W - 20, 40* ScreenMultiple) title:@"取消订单" titleColor:[UIColor whiteColor] imageName:nil backgroundImageName:nil target:self selector:@selector(canclepay)];
    btn2.backgroundColor = RGB(1,127,105);
    btn2.layer.cornerRadius = SCREEN_W/30;
    [self.tabelView addSubview:btn2];
    
}

#pragma mrak --支付

- (void)canclepay
{
    [HY_NSusefDefaults setObject:nil forKey:@"orderID"];//清楚订单
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - **************** 存数据库
- (void)saveToDB
{
    DataBaseManager * dbManager = [DataBaseManager sharedDataBaseManager];
    
    NSString * orderSting = [HY_NSusefDefaults objectForKey:@"orderID"];
    NSString * timeString = [HY_NSusefDefaults objectForKey:@"orderIDCreateTime"];//保存订单创建时间
    HYSingleManager * single = [HYSingleManager sharedManager];
    
    NSArray *arr = [NSArray array];
    if ([HY_NSusefDefaults objectForKey:@"payFee"]) {
        arr = [HY_NSusefDefaults objectForKey:@"payFee"];
    }
    NSString * nodeID = arr[0];
    NSString * fee = arr[1];
    orderModel * model = [[orderModel alloc] initWithOrderID:orderSting andUserID:[NSString stringWithFormat:@"%lld",single.user.user_ID] andFee:fee andDeviceID:nodeID andTag:0 andCommit:0 andCreateTime:timeString andPaySelecte:0];// ------0表示未处理状态
    [dbManager insertGoodsWithModel:model];
}

- (void)pay{
//    PaymentMethod *pay = [[PaymentMethod alloc] init];
//    NSDate *date = [NSDate date];
//    NSTimeInterval time = [date timeIntervalSince1970];
//    float sec = time - [[HY_NSusefDefaults objectForKey:@"orderIDCreateTime"] floatValue];
//    order = [NSString string];
//    if (sec < 29*60 ) {//29min后订单废弃
//        order = [HY_NSusefDefaults objectForKey:@"orderID"];
//    }else{
//        [UIView addMJNotifierWithText:@"订单超时，自动取消" dismissAutomatically:YES];
//        [self.navigationController popToRootViewControllerAnimated:YES];
//        return;
//    }
//    // ------支付之前存数据库
//    [self saveToDB];
//    // ------发起支付
//    [pay doAlipayPayWith:_feeArr[1] orderID:order];
//    pay.upLoadOrderToSrvice = ^(NSString * price){
//        [self.navigationController popViewControllerAnimated:YES];
//        [self upLoadOrderWith:(price)];
//    };
//    [self.navigationController popViewControllerAnimated:YES];
}

- (void)upLoadOrderWith:(NSString *)price
{
    NSArray *arr = [NSArray array];
    if ([HY_NSusefDefaults objectForKey:@"payFee"]) {
        arr = [HY_NSusefDefaults objectForKey:@"payFee"];
    }
    NSString * nodeID = arr[0];
    NSString * fee = arr[1];
    HYScoketManage * manegr = [HYScoketManage shareManager];
    manegr.mpID = (UInt64)[nodeID longLongValue];
    manegr.fee = fee;
    [manegr getNetworkDatawithIP:[HY_NSusefDefaults objectForKey:@"IP"] withTag:@"7"];
}

- (void)initData{
    self.dataSource = @[@[@"名称",@"订单号",@"创建时间",@"支付方式"],@[@"待支付金额"]];
    NSString *documentPath = DOCUMENTPATH;
    NSString * path = [documentPath stringByAppendingString:@"/flie.plist"];
    NSArray *newArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    self.textDataSource = newArray;
    
    if ([HY_NSusefDefaults objectForKey:@"payFee"]) {
        _feeArr = [HY_NSusefDefaults objectForKey:@"payFee"];
    }
    
}

- (void)configTableview
{
    self.tabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H) style:UITableViewStyleGrouped];
//    self.tabelView.separatorStyle = UITableViewCellAccessoryNone;
    self.tabelView.delegate = self;
    self.tabelView.dataSource = self;
    self.tabelView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.tabelView];
}

#pragma mark -- delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * arr = _dataSource[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50*ScreenMultiple;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PayFaliedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"faliedPay"];
    if (!cell) {
        cell = [[PayFaliedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"faliedPay"];
    }
    NSArray * a = _dataSource[indexPath.section];
    NSArray * aText = _textDataSource[indexPath.section];
    cell.m_name = a[indexPath.row];
    cell.m_labelText = aText[indexPath.row];
    if (indexPath.section == 0 &&indexPath.row == 0) {
        cell.m_labelText = _feeArr[2];
    }
    if (indexPath.section == 1) {
        cell.m_labelText = _feeArr[1];
    }
    [cell reloadData];
    return cell;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
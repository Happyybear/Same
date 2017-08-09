//
//  PayViewController.m
//  HYSEM
//
//  Created by 王一成 on 2017/4/26.
//  Copyright © 2017年 WGM. All rights reserved.
//
/**
 *本类是支付页面
 *支付选择和支付分别在两个不同cell上
 *本类又对于支付结果的观察者来检测支付结果，并作出刷新或者是跳入payFailed页面
 *
 *
 */
#import "PayViewController.h"
#import "PayCell.h"
#import "PaymentMethod.h"
#import "HYScoketManage.h"
#import "PayInfoCell.h"
#import "InfoModel.h"
#import "PayFailedOrderViewController.h"
#import "DataBaseManager.h"
#import "orderModel.h"
#import "NSObject+GetIP.h"
@interface PayViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView        * _tableView;
    UIButton          * doneInKeyboardButton;
    NSInteger         animationCurve;
    NSString          * MPID;
    NSString          * Fee;
    NSString          * MPName;
    NSString          * deviceName;
    //选择的支付方式
    NSInteger          selectPay;//0表示选择支付宝，1位微信支付
    
}
@end

@implementation PayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self createNavigition];
    //加载支付方式
    [self paySelect];
    //UI
    [self configUI];
}

-(void)paySelect
{
    NSArray * sel = [HY_NSusefDefaults objectForKey:@"paySelected"];
    if (sel) {
        if ([[sel firstObject] isEqualToString:@"1"]) {
            selectPay = 0;
        }else{
            selectPay = 1;
        }
    }else{
        [HY_NSusefDefaults setObject:@[@"1",@"0"] forKey:@"paySelected"];
        selectPay = 0;
    }
   
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    // ------上传成功，才会显示支付成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealPayResult:) name:@"payResult" object:nil];
    //获取支付相关信息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealPayOrderString:) name:@"getOrderString" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.rdv_tabBarController setTabBarHidden:NO animated:YES];
}

/**
 *处理服务器返回的支付结果
 *1.成功刷新cell，显示新的余额
 *2.失败，进入未支付订单页面，等待用户重新支付
 **/
- (void)dealPayResult:(NSNotification *)no
{
    
    NSString * status = [[no userInfo] objectForKey:@"status"];
    if ([status isEqualToString:@"Success"]) {
        // ------数据库清空
        DataBaseManager * manager = [DataBaseManager sharedDataBaseManager];
        [manager deleteAllGoods];
        
        // ------刷新数据之前先清空
        // ------得到确认信号，立即发送通知同时发起tag=1的档案请求，后面的判断会重新便利当前的旧的档案
        HYSingleManager * single = [HYSingleManager sharedManager];
        [single.obj_dict removeAllObjects];
        single.user = nil;
        // ------刷新数据之前先清空
        
        [UIView addMJNotifierWithText:@"支付成功" dismissAutomatically:YES];
        [self addObserver];
        // ------重新请求档案
        [[HYScoketManage shareManager] getNetworkDatawithIP:SocketHOST withTag:@"1"];
    }else if([status isEqualToString:@"Failed"]){
        
        // ------服务器查询结果为支付失败，数据库删除该条订单
        DataBaseManager * manager = [DataBaseManager sharedDataBaseManager];
        [manager deleteAllGoods];
        
        //进入未完成订单
        [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
    }
    
}

/**
 *处理服务器返回的加密字符串
 *发起支付
 *
 **/
- (void)dealPayOrderString:(NSNotification *)no
{
//    NSString * status = [[no userInfo] objectForKey:@"status"];
    orderModel * ordeModel =  [no.userInfo objectForKey:@"order"];
    if (ordeModel.orderID) {
        //开始支付
        [SVProgressHUD dismissInNow];
        [self startToPayWith:ordeModel];
    }else{
        [SVProgressHUD dismissInNow];
        [UIView addMJNotifierWithText:@"支付失败" dismissAutomatically:YES];
    }
}

#pragma mark - **************** 存数据库
//- (void)saveToDB
//{
//    DataBaseManager * dbManager = [DataBaseManager sharedDataBaseManager];
//    
//    NSString * orderSting = [HY_NSusefDefaults objectForKey:@"orderID"];
//    NSString * timeString = [HY_NSusefDefaults objectForKey:@"orderIDCreateTime"];//保存订单创建时间
//    HYSingleManager * single = [HYSingleManager sharedManager];
//    orderModel * model = [[orderModel alloc] initWithOrderID:orderSting andUserID:[NSString stringWithFormat:@"%lld",single.user.user_ID] andFee:Fee andDeviceID:MPID andTag:0 andCommit:0 andCreateTime:timeString andPaySelecte:0];// ------0表示未处理状态
//    [dbManager insertGoodsWithModel:model];
//}
/**
 *注册监听,监听档案请求
 *
 */
-(void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefresh) name:@"downPayData" object:nil];
}

/**
 *结束刷新
 *
 */
- (void)endRefresh
{
    NSString * fee;
    HYSingleManager *manager = [HYSingleManager sharedManager];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        for (int j = 0; j<company.child_obj.count; j++) {
            CTransitModel *transit = company.child_obj[j];
            for (int k = 0; k<transit.child_obj.count; k++) {
                CSetModel *set = transit.child_obj[k];
                for (int m = 0; m<set.child_obj.count; m++) {
                    CMPModel *mp = set.child_obj[m];
                    Node * node = self.dataArr[0];
                    if (node.nodeId == mp.strID) {
                        node.ramain_Fee = mp.remain_electricFee;
                        // ------刷新显示页面的余额信息
                        fee = node.ramain_Fee;
                        DLog(@"asdasdasdasdasdasdasasdasdasd%llu%@",mp.strID,mp.remain_electricFee);
                        // ------
                        [_dataArr removeAllObjects];
                        [_dataArr addObject:node];
                        //刷新cell
                        [_tableView reloadData];
                    }
                }
            }
        }
    }
    self.refreshFee(fee);
}

- (void)createNavigition
{
    self.titleLabel.text = @"支付";
    [self.leftButton setImage:[UIImage imageNamed:@"icon_function"] forState:UIControlStateNormal];
    [self setLeftButtonClick:@selector(leftButtonClick)];
    
}

/**
 *UIconfig
 *
 */
- (void)configUI
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    //初始化支付选择（从userdefaults取选择方式）
    if (![HY_NSusefDefaults objectForKey:@"paySelected"]) {
        NSMutableArray * pay = [[NSMutableArray alloc] init];
        [pay addObject:@"0"];
        [pay addObject:@"0"];
        [HY_NSusefDefaults setObject:pay forKey:@"paySelected"];
        [HY_NSusefDefaults synchronize];
    }
    
}

- (void)leftButtonClick{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - **************** 支付前检查是否有未完成的订单

-(BOOL)checkFaliedPayOrder
{
    DataBaseManager * manager = [DataBaseManager sharedDataBaseManager];
    NSArray * items = [manager selectAllGoods];
    if (items.count>0) {
        HYScoketManage * manegr = [HYScoketManage shareManager];
        [manegr getNetworkDatawithIP:[HY_NSusefDefaults objectForKey:@"IP"] withTag:@"7"];
        [SVProgressHUD showWithStatus:@"上传中..."];
        return YES;
    }
    return NO;
}

#pragma mark --pay
/**
 *点击支付按钮
 *
 */
- (void)pay{
    // ------支付前检查是否有未完成的订单
    BOOL exit = [self checkFaliedPayOrder];
    //    [self upLoadOrderWith:@"10"];
    if (!exit) {
        if ([self checkFeeWith:Fee]) {
            //从服务器获取签名字符串
            [self getOrder];
        }else{
            [UIView addMJNotifierWithText:@"请输入充值正确的金额" dismissAutomatically:YES];
        }

    }else{
        [UIView addMJNotifierWithText:@"有订单未提交" dismissAutomatically:YES];
    }
}

#pragma mark -- 判断输入金额是否符合要求
- (BOOL)checkFeeWith:(NSString *)m_fee{
    NSString * number = @"^[0-9]{1,6}.{0,1}[0-9]{0,2}$";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    BOOL res = [predicate evaluateWithObject:m_fee];
    return res;
}
#pragma mark --  获取支付app ID，key，order_id
- (void)getOrder{
    /*********测试获取ip地址88*******/
//    [self getIP];
    HYScoketManage * manegr = [HYScoketManage shareManager];
    manegr.mpID = (UInt64)[MPID longLongValue];
    manegr.fee = Fee;
    [manegr getNetworkDatawithIP:[HY_NSusefDefaults objectForKey:@"IP"] withTag:@"6"];
    [SVProgressHUD showWithStatus:@"loading..."];
}

/*********测试获取ip地址88*******/
- (void)getIP{
    NSString * IP = [NSObject deviceIPAdress];
    [UIView addMJNotifierWithText:IP dismissAutomatically:NO];
}
#pragma mark - **************** 开始发起支付
- (void)startToPayWith:(orderModel *)ordeStr{
    PaymentMethod * pay = [[PaymentMethod alloc] init];
    //发起支付
    NSString * deID = [NSString stringWithFormat:@"%llu",(UInt64)[MPID longLongValue]];
    //orderModel的Fee和设备ID赋值
    ordeStr.fee = Fee;
    ordeStr.deviceID = deID;
    ordeStr.deviceName = MPName;
    //缴费的fee存入寄存器
    NSArray * arrary = [[NSArray alloc] initWithObjects:MPID,Fee,MPName,ordeStr.orderID,nil];
    [HY_NSusefDefaults setObject:arrary forKey:@"payFee"];

    //发起支付
    if (selectPay == 1) {//微信
        [pay doWXPayWithOrder:ordeStr];
    }else if (selectPay == 0){// 支付宝
        [pay doAlipayPayWithOrder:ordeStr];
    }else{
        [UIView addMJNotifierWithText:@"请选择支付方式" dismissAutomatically:YES];
        return;
    }
    //block上传已完成的订单
    pay.upLoadOrderToSrvice = ^(NSString * price){
        [self upLoadOrderWith:(price)];
    };
    
}

- (void)upLoadOrderWith:(NSString *)price
{
    HYScoketManage * manegr = [HYScoketManage shareManager];
    manegr.mpID = (UInt64)[MPID longLongValue];
    manegr.fee = price;
    [manegr getNetworkDatawithIP:[HY_NSusefDefaults objectForKey:@"IP"] withTag:@"7"];
    [SVProgressHUD showWithStatus:@"上传中..."];
}

#pragma mark --delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return (40 * 2 * ScreenMultiple +35 *ScreenMultiple + 70*ScreenMultiple);
    }
    return 60 * ScreenMultiple;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.011;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        PayCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"paySelected"];
        if (!cell) {
            cell = [[PayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"paySelected"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        [cell refreshUIWithtag:indexPath.row];
        NSArray * sel = [HY_NSusefDefaults objectForKey:@"paySelected"];
        NSString * payS = sel[indexPath.row];
        [cell refreshMarkWithTag:payS];
        return cell;
    }else{
        PayInfoCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[PayInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:19];
        cell.backgroundColor = [UIColor clearColor];
        Node * node = [self.dataArr objectAtIndex:0];
        cell.node = node;
        cell.startToPay = ^(NSString * mpID,NSString * fee,NSString * mpName){
            MPID = mpID;
            Fee = fee;
            MPName = mpName;
            [self pay];
        };
        [cell upDataCellWithData:node];
        return cell;
    }
    return nil;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [FactoryUI createViewWithFrame:CGRectMake(0, 0, SCREEN_W, 30)];
    if (section == 0) {
        UILabel * label = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, SCREEN_W, 30) text:@"1.选择支付方式" textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:15]];
        [view addSubview:label];
    }else{
        UILabel * label = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, SCREEN_W, 30) text:@"2.充值的金额（元）" textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:15]];
        [view addSubview:label];
    }
    view.backgroundColor = RGB(240, 248, 255);
    return  view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
//            [UIView addMJNotifierWithText:@"微信支付近期开通" dismissAutomatically:YES];
            selectPay = 1;//1表示微信
//            return;
        }else if (indexPath.row == 0){
            selectPay = 0;// 0表示支付宝
        }
        NSMutableArray * pay = [[NSMutableArray alloc] init];
        [pay addObject:@"0"];
        [pay addObject:@"0"];
        for (int i = 0;i < pay.count;i++) {
            pay[i] = @"0";
            if (i == (int)indexPath.row) {
                pay[i] = @"1";
            }
        }
        [HY_NSusefDefaults setObject:pay forKey:@"paySelected"];
        [HY_NSusefDefaults synchronize];
        [_tableView reloadData];
    }
}



#pragma mark --处理键盘弹起
- (void)dealKeyBoard
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSValue *animationDurationValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        _tableView.contentOffset = CGPointMake(0,0);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSValue *animationDurationValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [self beginMoveAnimition:keyBoardFrame andAnimitionDurationValue:animationDurationValue];
    animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
}

-(void)beginMoveAnimition:(CGRect)keyBoardFrame andAnimitionDurationValue:(NSValue *)animationDurationValue
{
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView animateWithDuration:animationDuration animations:^{
        _tableView.contentOffset = CGPointMake(0, 45);
        } completion:^(BOOL finished) {
            
    }];
    
    // UIKeyboardAnimationCurveUserInfoKey 对应键盘弹出的动画类型
    
    //数字彩,数字键盘添加“完成”按钮
    if (doneInKeyboardButton){
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];//设置添加按钮的动画时间
        [UIView setAnimationCurve:(UIViewAnimationCurve)animationCurve];//设置添加按钮的动画类型
        
        //设置自定制按钮的添加位置(这里为数字键盘添加“完成”按钮)
        doneInKeyboardButton.transform=CGAffineTransformMakeTranslation(0, -53);
        
        [UIView commitAnimations];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self dealKeyBoard];
    [super viewWillAppear:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    //注销键盘显示通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewDidDisappear: YES];
}

//初始化，数字键盘“完成”按钮
- (void)configDoneInKeyBoardButton{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    //初始化
    if (doneInKeyboardButton == nil)
    {
        doneInKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [doneInKeyboardButton setTitle:@"完成" forState:UIControlStateNormal];
        [doneInKeyboardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        doneInKeyboardButton.frame = CGRectMake(0, screenHeight, 106, 53);
        
        doneInKeyboardButton.adjustsImageWhenHighlighted = NO;
        [doneInKeyboardButton addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
    }
    //每次必须从新设定“完成”按钮的初始化坐标位置
    doneInKeyboardButton.frame = CGRectMake(0, screenHeight, 106, 53);
    
    //由于ios8下，键盘所在的window视图还没有初始化完成，调用在下一次 runloop 下获得键盘所在的window视图
    [self performSelector:@selector(addDoneButton) withObject:nil afterDelay:0.0f];
    
}

- (void) addDoneButton{
    //获得键盘所在的window视图
    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
    [tempWindow addSubview:doneInKeyboardButton];    // 注意这里直接加到window上
    
}

//点击“完成”按钮事件，收起键盘
-(void)finishAction{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];//关闭键盘
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

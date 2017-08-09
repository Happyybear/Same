//
//  ShowPayInfoViewController.m
//  HYSEM
//
//  Created by 王一成 on 2017/5/16.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "ShowPayInfoViewController.h"
#import "ShowView.h"
#import "Node.h"
#import "PayViewController.h"
#import "PayOrederRecordView.h"
#import "HYScoketManage.h"
#import "SendMessageToWarningViewController.h"
@interface ShowPayInfoViewController ()<didSelected>

@property (nonatomic,strong) Node * node;

@end

@implementation ShowPayInfoViewController
{
    CGFloat  height;
    ShowView * show;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self createNavigition];
    [self configUI];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self.rdv_tabBarController setTabBarHidden:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];

}


- (void)initData{
    _node = [[Node alloc] init];
    _node = _dataArr[0];
}


- (void)createNavigition
{
    self.titleLabel.text = [HY_NSusefDefaults objectForKey:@"username"];
    [self.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self setLeftButtonClick:@selector(leftButtonClick)];
    [self.rightButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self setRightButtonClick:@selector(rightButtonClick)];
    
}
#pragma mark - **************** 返回上一级
- (void)leftButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - **************** 刷新
- (void)rightButtonClick
{
    [self getData];
}

-(void)getData{
    HYScoketManage * manage = [HYScoketManage shareManager];
    [manage getNetworkDatawithIP:nil withTag:@"1"];
    [SVProgressHUD showInfoWithStatus:@"加载中"];
    [self addObserver];
}

-(void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefresh) name:@"downPayData" object:nil];
}

- (void)endRefresh{
    HYSingleManager *manager = [HYSingleManager sharedManager];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        for (int j = 0; j<company.child_obj.count; j++) {
            CTransitModel *transit = company.child_obj[j];
            for (int k = 0; k<transit.child_obj.count; k++) {
                CSetModel *set = transit.child_obj[k];
                for (int m = 0; m<set.child_obj.count; m++) {
                    CMPModel *mp = set.child_obj[m];
                    if (_node.nodeId == mp.strID) {
                        _node.ramain_Fee = mp.remain_electricFee;
                        // ------刷新显示页面的余额信息
                        _node.name = mp.name;
                        _node.MpID = [NSString stringWithFormat:@"%llu",mp.strID];
                        show.data = _node;
                        [show reloadData];
                        // ------
                    }
                }
            }
        }
    }

}
#pragma mark - **************** UI
- (void)configUI
{
    UIImageView * view = [FactoryUI createImageViewWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H*2/5) imageName:@"PayBG.jpg"];
    [self.view addSubview:view];
    show = [[ShowView alloc] init];
    show.data = _node;
    
    [show reloadData];// ------更新view
    
    [self.view addSubview:show];
    self.view.backgroundColor = RGB(220, 220, 220);
    [self addPay];
    
    UILabel * tip = [FactoryUI createLabelWithFrame:CGRectMake(5*ScreenMultiple, CGRectGetMaxY(view.frame) + 5*ScreenMultiple, 100*ScreenMultiple, 20*ScreenMultiple) text:@"缴费记录" textColor:[UIColor grayColor] font:[UIFont boldSystemFontOfSize:15]];
    [self.view addSubview:tip];
    
    UIButton * tipAction = [FactoryUI createButtonWithFrame:CGRectMake(SCREEN_W - 45*ScreenMultiple, CGRectGetMaxY(view.frame) + 5*ScreenMultiple, 40*ScreenMultiple, 20*ScreenMultiple) title:@"更多" titleColor:[UIColor grayColor] imageName:nil backgroundImageName:nil target:self selector:@selector(moreTip)];
    [self.view addSubview:tipAction];
    CGFloat averageH = (SCREEN_H - 35*ScreenMultiple - 45*ScreenMultiple - CGRectGetMaxY(tipAction.frame))/4;// ------每个按钮的高度
    height = averageH;
    
    [self addPayOrderWithFrame:CGRectMake(10*ScreenMultiple, CGRectGetMaxY(tipAction.frame) + 15*ScreenMultiple, SCREEN_W - 20*ScreenMultiple, SCREEN_H -CGRectGetMaxY(tipAction.frame) - 50*ScreenMultiple )];// ------订单
    
    // ------展示电表信息,最上方的显示条
    UILabel * infoLabel = [[UILabel alloc] init];
    infoLabel.frame = CGRectMake(0, 0, SCREEN_W, 35*ScreenMultiple);
    infoLabel.backgroundColor = RGBA(248, 248, 255, 0.5);
    infoLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:infoLabel];
    [self serachRoadOnlabel:(infoLabel)];
    
}

#pragma mark - **************** 寻找路径
- (void)serachRoadOnlabel:(UILabel *)label{
    Node * node = self.dataArr[0];
    HYSingleManager * manager = [HYSingleManager sharedManager];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        for (int j = 0; j<company.child_obj.count; j++) {
            CTransitModel *transit = company.child_obj[j];
            for (int k = 0; k<transit.child_obj.count; k++) {
                CSetModel *set = transit.child_obj[k];
                for (int m = 0; m<set.child_obj.count; m++) {
                    CMPModel *mp = set.child_obj[m];
                    if (mp.strID == [node.MpID longLongValue] ) {
                        label.text = [NSString stringWithFormat:@"%@->%@->%@",transit.name,set.name,mp.name];
                    }
                }
            }
        }
    }
}

#pragma mark - **************** didsxelceted delegate
- (void)viewDidSelectedAtIndex:(NSInteger)index
{
    // ------点击事件
}

- (NSInteger)numRowOfSection
{
    return 0;
}

- (CGFloat)heightForRow
{
    return height;
}
#pragma mark - ****************缴费记录
- (void)addPayOrderWithFrame:(CGRect)frame
{
    PayOrederRecordView * reView = [[PayOrederRecordView alloc] initWithFrame:frame];
    reView.delegate = self;
    [reView reloadData];
    [self.view addSubview:reView];
}

#pragma mark - **************** 更多支付订单
-(void)moreTip{
    
}
#pragma mark - **************** 添加支付按钮
 -(void)addPay
{
    UIButton * warn = [FactoryUI createButtonWithFrame:CGRectMake(40*ScreenMultiple, SCREEN_H - 45*ScreenMultiple, (SCREEN_W - 160*ScreenMultiple)/2, 40*ScreenMultiple) title:@"欠费提醒" titleColor:RGB(255, 255, 255) imageName:nil backgroundImageName:nil target:self selector:@selector(toWarn)];
    warn.backgroundColor = RGB(255, 102, 105);
    warn.layer.cornerRadius = SCREEN_W/40;
    [self.view addSubview:warn];
        
    UIButton * pay = [FactoryUI createButtonWithFrame:CGRectMake(CGRectGetMaxX(warn.frame) + 80*ScreenMultiple, SCREEN_H - 45*ScreenMultiple, (SCREEN_W - 160*ScreenMultiple)/2, 40*ScreenMultiple) title:@"立即交费" titleColor:RGB(255, 255, 255) imageName:nil backgroundImageName:nil target:self selector:@selector(topay)];
    pay.backgroundColor = RGB(46, 149, 105);
    pay.layer.cornerRadius = SCREEN_W/40;
    [self.view addSubview:pay];


//     UIButton * pay = [FactoryUI createButtonWithFrame:CGRectMake(40*ScreenMultiple, SCREEN_H - 45*ScreenMultiple, (SCREEN_W - 80*ScreenMultiple), 40*ScreenMultiple) title:@"立即交费" titleColor:RGB(255, 255, 255) imageName:nil backgroundImageName:nil target:self selector:@selector(topay)];
//     pay.backgroundColor = RGB(46, 149, 105);
//     pay.layer.cornerRadius = SCREEN_W/40;
//     [self.view addSubview:pay];

//    }
}
#pragma mark -******告警
 -(void)toWarn
{
    HYSingleManager * manager = [HYSingleManager sharedManager];
    if ([manager.powerArray[5] isEqualToString:@"1"]) {
        
        SendMessageToWarningViewController * send = [[SendMessageToWarningViewController alloc] init];
        send.hidesBottomBarWhenPushed = YES;
        MessageModel * model = [self getMessageData];
        send.messageModel = model;
        send.node = self.dataArr[0];
        [self.navigationController pushViewController:send animated:YES];

    }else{
        [UIView addMJNotifierWithText:@"对不起，您没有该项权限" dismissAutomatically:NO];
    }
        
    
}


#pragma mark - **************** 寻找路径
- (MessageModel * )getMessageData{
    MessageModel * model = [[MessageModel alloc] init];
    Node * node = self.dataArr[0];
    HYSingleManager * manager = [HYSingleManager sharedManager];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        for (int j = 0; j<company.child_obj.count; j++) {
            CTransitModel *transit = company.child_obj[j];
            for (int k = 0; k<transit.child_obj.count; k++) {
                CSetModel *set = transit.child_obj[k];
                for (int m = 0; m<set.child_obj.count; m++) {
                    CMPModel *mp = set.child_obj[m];
                    if (mp.strID == [node.MpID longLongValue] ) {
                        model.userID = [NSString stringWithFormat:@"%llu",manager.user.user_ID];
                        model.companyID = [NSString stringWithFormat:@"%llu",company.strID];
                        model.deviceID = [NSString stringWithFormat:@"%llu",mp.strID];
                        model.messageArr = mp.messageNum;
                        return model;
                    }
                }
            }
        }
    }
    return nil;
    
}


#pragma mark - **************** 进入支付页面
- (void)topay{
    PayViewController * infVC = [[PayViewController alloc] init];
    infVC.hidesBottomBarWhenPushed = YES;
    infVC.refreshFee = ^(NSString * fee){
        _node.ramain_Fee = fee;
        show.data = _node;
        [show reloadData];
        DLog(@"%@",fee);
    };
    infVC.dataArr = self.dataArr;
    [self.navigationController pushViewController:infVC animated:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

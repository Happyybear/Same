//
//  HYRightViewController.m
//  HYSEM
//
//  Created by 王一成 on 2017/5/25.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "HYRightViewController.h"
#import "Node.h"
#import "TreeTableView.h"
#import "AppDelegate.h"
#import "HYScoketManage.h"

@interface HYRightViewController ()
{
    NSMutableData *mData;
    int isAppend;
    int appendLen;
    NSString *ipv6Addr;
}

@property (nonatomic,strong) TreeTableView *tableView;
@end

@implementation HYRightViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [HY_NSusefDefaults removeObjectForKey:@"selectBtn"];
    // Do any additional setup after loading the view.
    [self createUI];
    [self createBaseUI];
    mData = [NSMutableData data];
    appendLen = 0;
    isAppend = 0;
    ipv6Addr = [self convertHostToAddress:[HY_NSusefDefaults objectForKey:@"IP"]];
    //    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    
}

-(void)getData{
    HYScoketManage * manage = [HYScoketManage shareManager];
    [manage getNetworkDatawithIP:ipv6Addr withTag:@"1"];
    
    [self addObserver];
}

-(void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endRefresh) name:@"downPayData" object:nil];
}

-(void)endRefresh{
    [self.tableView.mj_header endRefreshing];
}
//每次进入页面之前刷新一下数据
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //马上进入刷新状态
    //    [self.tableView.mj_header beginRefreshing];
}

-(NSString *)convertHostToAddress:(NSString *)host {
    
    NSError *err = nil;
    
    NSMutableArray *addresses = [GCDAsyncSocket lookupHost:host port:0 error:&err];
    
    //    NSLog(@"address%@",addresses);
    
    NSData *address4 = nil;
    NSData *address6 = nil;
    
    for (NSData *address in addresses)
    {
        if (!address4 && [GCDAsyncSocket isIPv4Address:address])
        {
            address4 = address;
        }
        else if (!address6 && [GCDAsyncSocket isIPv6Address:address])
        {
            address6 = address;
        }
    }
    
    NSString *ip;
    
    if (address6) {
        //        NSLog(@"ipv6%@",[GCDAsyncSocket hostFromAddress:address6]);
        ip = [GCDAsyncSocket hostFromAddress:address6];
    }else {
        //        NSLog(@"ipv4%@",[GCDAsyncSocket hostFromAddress:address4]);
        ip = [GCDAsyncSocket hostFromAddress:address4];
    }
    
    return ip;
    
}






- (void)createUI
{
    [HY_NSusefDefaults removeObjectForKey:@"BTN"];
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
            for (int m = 0; m<transit.child_obj.count; m++) {
                    CMPModel *mp = transit.child_obj[m];
                    Node *node = [[Node alloc]initWithParentId:mp.strID nodeId:mp.strID name:mp.name depth:2 expand:YES mpID:[mp UInt64ToString:mp.strID] Fee:nil];
                    [nodeArr addObject:node];
            }
            
        }
    }
    
    _tableView = [[TreeTableView alloc]initWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-220) withData:nodeArr];
    _tableView.treeTableCellDelegate = self;
    _tableView.separatorStyle = NO;
    [self.view addSubview:_tableView];
}

- (void)createBaseUI
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    UIButton * back = [UIButton buttonWithType:UIButtonTypeCustom];
    back.frame = CGRectMake(30, 40, 50, 40);
    UILabel *nameLable = [[UILabel alloc]initWithFrame:CGRectMake(90,40, 120,20)];
    NSString *username = [[NSUserDefaults standardUserDefaults]objectForKey:@"username"];
    nameLable.text = [NSString stringWithFormat:@"用户名:%@",username];
    [nameLable setFont:[UIFont systemFontOfSize:12]];
    UILabel *stateLable = [[UILabel alloc]initWithFrame:CGRectMake(90, 60, 120, 20)];
    stateLable.text = @"登录状态:已登录";
    [stateLable setFont:[UIFont systemFontOfSize:12]];
    [view addSubview:nameLable];
    [view addSubview:stateLable];
    [back setBackgroundImage:[UIImage imageNamed:@"log_picture"] forState:UIControlStateNormal];
    [view addSubview:back];
    [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    view.backgroundColor = RGB(1,127,105);
    [self.view addSubview:view];
}

//退出登录
-(void)back{
    UIAlertController *alertControl = [UIAlertController alertControllerWithTitle:@"退出登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(alertControl)wAlert = alertControl;
    [wAlert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //        [defaults removeObjectForKey:@"username"];
        //        [defaults removeObjectForKey:@"password"];
        [defaults setObject:@"YES" forKey:@"Exit"];
        [defaults synchronize];
        
        //退出登录
        [self performSelector:@selector(logout) withObject:nil afterDelay:0.5];
    }]];
    
    [wAlert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    
    [self presentViewController:alertControl animated:YES completion:nil];
}

- (void)logout
{
    HYSingleManager *single = [HYSingleManager sharedManager];
    [single.obj_dict removeAllObjects];
    AppDelegate * appdelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    [appdelegate login];
}

- (void)cellClick:(Node *)node
{
    DLog(@"%@",node.name);
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

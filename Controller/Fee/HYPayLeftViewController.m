//
//  HYLeftViewController.m
//  HYSEM
//
//  Created by xlc on 16/11/15.
//  Copyright © 2016年 WGM. All rights reserved.
//

#import "HYPayLeftViewController.h"
#import "Node.h"
#import "AppDelegate.h"
#import "HYScoketManage.h"
#import "InfTabelView.h"
#import "InfoModel.h"
#import "SearchDisplayViewController.h"
#import "PayViewController.h"
#import "ShowPayInfoViewController.h"

@interface HYPayLeftViewController ()<infoTableView,UISearchResultsUpdating,UISearchControllerDelegate>
{
    NSMutableData               *mData;
    int                       isAppend;
    int                       appendLen;
    NSString                   *ipv6Addr;
    NSString                   * _company;
    NSMutableArray              * _infData;//z展示数据
    UISearchController           * search;
    NSMutableArray              * _searchData;//搜索数据
    NSMutableArray              * _searchdisplayData;//搜索展示数据
    SearchDisplayViewController    * _vc;
}

@property (nonatomic,strong) InfTabelView *tableView;


@end

@implementation HYPayLeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [HY_NSusefDefaults removeObjectForKey:@"selectBtn"];
    // Do any additional setup after loading the view.
    [self createUI];
    [self createNavigition];
    [self addObserver];
    mData = [NSMutableData data];
    appendLen = 0;
    isAppend = 0;
    ipv6Addr = [self convertHostToAddress:[HY_NSusefDefaults objectForKey:@"IP"]];
//    __weak typeof(self) weakSelf = self;
//    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [weakSelf getData];
//    }];
    
}

- (void)initData{
    _company = [NSString new];
    _infData = [NSMutableArray array];
    _searchData = [[NSMutableArray alloc] init];
    _searchdisplayData = [[NSMutableArray alloc] init];
}

- (void)createNavigition
{
    self.titleLabel.text = @"选择设备";
    [self.leftButton setImage:[UIImage imageNamed:@"icon_function"] forState:UIControlStateNormal];
    [self setLeftButtonClick:@selector(leftButtonClick)];
}

//返回
- (void)leftButtonClick
{
//    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        if (tempAppDelegate.LeftSlideVC.closed)
        {
            [tempAppDelegate.LeftSlideVC openLeftView];
        }
        else
        {
            [tempAppDelegate.LeftSlideVC closeLeftView];
        }

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
    [HY_NSusefDefaults removeObjectForKey:@"BTN"];
    NSString * com, *grou;
    _infData = [[NSMutableArray alloc] init];
    HYSingleManager *manager = [HYSingleManager sharedManager];
    //    NSMutableArray *nodeArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        _company = company.name;
        com = company.name;
        for (int j = 0; j<company.child_obj.count; j++) {
            CTransitModel *transit = company.child_obj[j];
            grou = transit.name;
            _infData = [NSMutableArray array];
            for (int k = 0; k<transit.child_obj.count; k++) {
                InfoModel * model = [[InfoModel alloc] init];
                if (model.data == nil) {
                    model.data = [[NSMutableArray alloc] init];
                }
                CSetModel *set = transit.child_obj[k];
                Node *node = [[Node alloc]initWithParentId:transit.strID nodeId:set.strID name:set.name depth:-1 expand:YES mpID:[set UInt64ToString:set.strID] Fee:nil];
                //                [nodeArr addObject:node];
                
                model.node = node;
                model.company = com;
                model.group = grou;
                
                NSMutableArray * dataArrary = [NSMutableArray array];
                for (int m = 0; m<set.child_obj.count; m++) {
                    CMPModel *mp = set.child_obj[m];
                    Node *node = [[Node alloc]initWithParentId:set.strID nodeId:mp.strID name:mp.name depth:0 expand:YES mpID:[mp UInt64ToString:mp.strID] Fee:mp.remain_electricFee];
                    //                    [nodeArr addObject:node];
                    [dataArrary addObject:node];
                }
                model.data  = dataArrary;
                [_infData addObject:model];
            }
        }
    }
    [_tableView removeFromSuperview];
    _tableView = [[InfTabelView alloc] initWithFrame:CGRectMake(0, 30, SCREEN_W,SCREEN_H-30-49) WithData:_infData];
    _tableView.infoDelegate = self;
    _tableView.backgroundColor = RGB(240, 255, 255);
    _tableView.separatorStyle = NO;
    self.tableView.tableHeaderView = search.searchBar;
    [self.view addSubview:_tableView];
}
//每次进入页面之前刷新一下数据
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.rdv_tabBarController setTabBarHidden:NO];
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
    NSString * com, *grou;
    HYSingleManager *manager = [HYSingleManager sharedManager];
//    NSMutableArray *nodeArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        _company = company.name;
        com = company.name;
        for (int j = 0; j<company.child_obj.count; j++) {
            CTransitModel *transit = company.child_obj[j];
            grou = transit.name;
            _infData = [NSMutableArray array];
            for (int k = 0; k<transit.child_obj.count; k++) {
                InfoModel * model = [[InfoModel alloc] init];
                if (model.data == nil) {
                    model.data = [[NSMutableArray alloc] init];
                }
                CSetModel *set = transit.child_obj[k];
                Node *node = [[Node alloc]initWithParentId:transit.strID nodeId:set.strID name:set.name depth:-1 expand:YES mpID:[set UInt64ToString:set.strID] Fee:nil];
//                [nodeArr addObject:node];
                
                model.node = node;
                model.company = com;
                model.group = grou;
                
                NSMutableArray * dataArrary = [NSMutableArray array];
                for (int m = 0; m<set.child_obj.count; m++) {
                    CMPModel *mp = set.child_obj[m];
                    Node *node = [[Node alloc]initWithParentId:set.strID nodeId:mp.strID name:mp.name depth:0 expand:YES mpID:[mp UInt64ToString:mp.strID] Fee:mp.remain_electricFee];
//                    [nodeArr addObject:node];
                    [dataArrary addObject:node];
                }
                model.data  = dataArrary;
                [_infData addObject:model];
            }
        }
    }
    
    _tableView = [[InfTabelView alloc] initWithFrame:CGRectMake(0, 30, SCREEN_W,SCREEN_H-30-49) WithData:_infData];
    _tableView.infoDelegate = self;
    _tableView.backgroundColor = RGB(240, 255, 255);
    _tableView.separatorStyle = NO;
    [self addTitle];
    [self addSearch];
    self.tableView.tableHeaderView = search.searchBar;
    [self.view addSubview:_tableView];
}

#pragma mark --搜索功能
- (void)addSearch
{
    _vc = [[SearchDisplayViewController alloc] init];
    __weak typeof(self) weakSelf = self;
    _vc.gotoInfo = ^(Node * node){
        __strong typeof(self) strongSelf = weakSelf;
        [strongSelf cellClick:node];
    };
    search = [[UISearchController alloc] initWithSearchResultsController:_vc];
    search.delegate = self;
    search.searchResultsUpdater = self;
    search.searchBar.placeholder = @"请输入搜索内容";
    search.dimsBackgroundDuringPresentation = NO;
//    search.hidesNavigationBarDuringPresentation = NO;
    search.searchBar.frame = CGRectMake(0, 0, SCREEN_W, 30.0);
    [search.searchBar sizeToFit];
    self.definesPresentationContext = YES;
//    search.obscuresBackgroundDuringPresentation = YES;
    //颜色设置
    search.searchBar.barTintColor = RGB(240, 255, 255);
}

//搜索协议方法
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = [search.searchBar text];
    
    NSString * com, *grou;
    HYSingleManager *manager = [HYSingleManager sharedManager];
    NSMutableArray *nodeArr = [[NSMutableArray alloc]init];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        _company = company.name;
        com = company.name;
        for (int j = 0; j<company.child_obj.count; j++) {
            CTransitModel *transit = company.child_obj[j];
            grou = transit.name;
            _infData = [NSMutableArray array];
            _searchData = [NSMutableArray array];
            for (int k = 0; k<transit.child_obj.count; k++) {
                InfoModel * model = [[InfoModel alloc] init];
                if (model.data == nil) {
                    model.data = [[NSMutableArray alloc] init];
                }
                CSetModel *set = transit.child_obj[k];
                Node *node = [[Node alloc]initWithParentId:transit.strID nodeId:set.strID name:set.name depth:-1 expand:YES mpID:[set UInt64ToString:set.strID] Fee:nil];
                [nodeArr addObject:node];
                model.node = node;
                model.company = com;
                model.group = grou;
                NSMutableArray * dataArrary = [NSMutableArray array];
                for (int m = 0; m<set.child_obj.count; m++) {
                    CMPModel *mp = set.child_obj[m];
                    Node *node = [[Node alloc]initWithParentId:set.strID nodeId:mp.strID name:mp.name depth:0 expand:YES mpID:[mp UInt64ToString:mp.strID] Fee:mp.remain_electricFee];
//                    [nodeArr addObject:node];
                    [dataArrary addObject:node];
                    if ([node.name containsString:searchString]) {
                        [_searchData addObject:node];
                    }
                }
            }
        }
    }
    if (_searchData.count>0) {
        _vc.dispalyData = _searchData;
        [_vc reloadData];
    }
}

- (void)addTitle
{
    UILabel * title = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, SCREEN_W, 30) text:_company textColor:RGB(119, 136, 153) font:[UIFont boldSystemFontOfSize:15]];
    title.textAlignment = NSTextAlignmentCenter;
    title.backgroundColor = RGB(152, 251, 152);
    [self.view addSubview:title];
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
//    view.backgroundColor = RGB(1,127,105);
    [self.view addSubview:view];
}
/**
 *cell点击
 */
- (void)cellClick:(Node *)node
{
    DLog(@"%@",node.name);
    if (node.depth == 0) {
//        HYSetInfViewController * infVC = [[HYSetInfViewController alloc] init];
        ShowPayInfoViewController * infVC = [[ShowPayInfoViewController alloc] init];
//        [infVC.rdv_tabBarController setTabBarHidden:YES animated:YES];
        NSMutableArray * data = [[NSMutableArray alloc] init];
        [data addObject:node];
//        data addObject:<#(nonnull id)#>
//        [data addObject:node.MpID];
//        [data addObject:[NSString stringWithFormat:@"20001122%d%d",arc4random()%9,arc4random()%9]];
//        [data addObject:[HY_NSusefDefaults objectForKey:@"username"]];
//        [data addObject:@"1.2"];
//        [data addObject:@"10020"];//起
//        [data addObject:@"10050"];//止
//        [data addObject:@"1.2"];//用电量
//        [data addObject:@"1067.34"];//上次剩余电量
//        [data addObject:@"1067.34"];//上次剩余电量
//        [data addObject:@"1067.34"];//上次剩余电量
//        [data addObject:@"1067.34"];//上次剩余电量
//        [data addObject:@"1067.34"];//上次剩余电量
        infVC.dataArr = data;
        [self.navigationController pushViewController:infVC animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

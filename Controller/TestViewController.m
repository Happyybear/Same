//
//  TestViewController.m
//  HYSEM
//
//  Created by 王一成 on 2017/8/2.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "TestViewController.h"

#import "CharView.h"

#import "HYScoketManage.h"

#import "DeviceModel.h"

#import <CoreMotion/CoreMotion.h>

#import "WYC_PopView.h"

static const CGFloat everyW = 150;
static const CGFloat everyH = 50;

@interface TestViewController ()

{
    TWLAlertView     *alertView;
    int            isAppend;
    int            appendLen;
    NSMutableData    *mData;
    NSMutableArray   *_nameArr;
    NSMutableArray   *_dataSource;
    NSMutableArray   * _data; //存储所有对象
    NSMutableArray   *_timeArr;
    int            request_type;//区分请求类型,全天查询还是分段查询 (0 全天  1 分段)
    NSString        *ipv6Addr;
    int            dayNum; //选择的天数
}

@property (nonatomic,retain) NSMutableArray * memory_data;
@property (nonatomic,retain) NSMutableArray * nameArr;
@property (nonatomic,retain) NSMutableArray * timeArr;
@property (nonatomic,retain) NSMutableArray * charData;
@property (nonatomic,retain) CharView * char1;//日用量图标
@property (nonatomic,retain) CharView * char2;//月用量
@property (strong, nonatomic) CMPedometer *pedometer;

@end

@implementation TestViewController

- (void)viewDidLoad {
    isAppend = 1;
    self.view.backgroundColor = [UIColor whiteColor];
    [super viewDidLoad];
    //设置支持晃动手势
    [[UIApplication sharedApplication]setApplicationSupportsShakeToEdit:YES];
    [self createNavigitionNoPower];
    //添加监听
    [self getData];
    [self createChartView];
    [self getRequest];
    [self run];

}
//计步器
-(void)run{
    _pedometer = [[CMPedometer alloc] init];
    //判断是否支持记步
    if (![CMPedometer isStepCountingAvailable]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的设备不支持记步" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:alertAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    NSDate *date = [NSDate date];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    NSInteger interval = [timeZone secondsFromGMTForDate:date];
    NSDate *localDate = [date dateByAddingTimeInterval:interval];
    [_pedometer queryPedometerDataFromDate:[NSDate dateWithTimeInterval:-24*60*60 sinceDate:localDate] toDate:localDate withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
        if (error) {
            NSLog(@"查询错误 %@", error);
            return ;
        }
        NSLog(@"%@", pedometerData);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController * alterC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"24小时内走了%@",pedometerData.numberOfSteps] message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * alterA = [UIAlertAction actionWithTitle:@"pop" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alterC addAction:alterA];
            [self presentViewController:alterC animated:YES completion:nil];
        });
    }];
    
    [_pedometer startPedometerUpdatesFromDate:[NSDate dateWithTimeInterval:-24*60*60 sinceDate:localDate] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
        if (error) {
            NSLog(@"更新错误 %@", error);
            return ;
        }
        NSLog(@"%@", pedometerData);
        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.stepLabel.text = [NSString stringWithFormat:@"%@", pedometerData];
        });
    }];

}
-(BOOL)canBecomeFirstResponder
{// 默认值是 NO
    return YES;
}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    [self getRequest];
}//开始晃动
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    
}//晃动结束
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event{//取{
    
}

- (void)createNavigitionNoPower
{
    self.titleLabel.text = @"表码分析";
    [self.leftButton setImage:[UIImage imageNamed:@"icon_function"] forState:UIControlStateNormal];
    [self setLeftButtonClick:@selector(leftButtonClick)];
    [self.rightButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self setRightButtonClick:@selector(rightButtonClick)];
}

-(void)leftButtonClick{
    [self getRequest];
    [self run];
}
//选择关注
- (void)rightButtonClick{
    WYC_PopView * popView = [[WYC_PopView alloc] initWithFrame:CGRectMake(kScreenWidth - everyW - 40 , 64, 194, 302)];
    [popView showInKeyWindow];
}


/** 创建柱状图*/
-(void)createChartView{
    _char1 = [[CharView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, 200)];
    [self.view addSubview:_char1];
    [_char1 darwStartWith:nil];
    
    _char2 = [[CharView alloc] initWithFrame:CGRectMake(0, 200, SCREEN_W, 200)];
    [self.view addSubview:_char2];
    [_char2 darwStartWith:nil];
}
/** 从服务器获取彪马,发起请求*/
-(void)getRequest{
    HYScoketManage * manager = [HYScoketManage shareManager];
    //请求之前清楚数据
    [HY_NSusefDefaults removeObjectForKey:@"usePowerData"];
    [HY_NSusefDefaults removeObjectForKey:@"NextData"];
    //2走用量请求请求通道
    NSMutableArray * arr = [self getDevice];
    if (arr.count <= 0) {
        return;
    }
    [manager getNetworkDatawithIP:nil withTag:@"2"];
    NSArray * array = arr;
    manager.deviceID = array;
    //3天包括今天，昨天和前天
    if (isAppend == 0) {
        [manager writeDataToHostWithMonth];
        isAppend = 1;
    }else{
        [manager writeDataToHostWithL:@"3"];
        isAppend = 0;
    }
    
    
//    [manager writeDataToHostWithMonth];
}
//判断是否更换ID
- (bool)userIDisChange{
    HYSingleManager * manager = [HYSingleManager sharedManager];
    NSString * m_id = [HY_NSusefDefaults objectForKey:@"concernID"];
    if ([m_id isEqualToString:[NSString stringWithFormat:@"%llu",manager.user.user_ID]]) {
        return NO;
    }else{
        return YES;
    }
}
//获取关注设备
- (NSArray *)getDevice{
    if ([self userIDisChange]) {
        //清楚关注
        [HY_NSusefDefaults removeObjectForKey:@"concern"];
        return nil;
    }
    _dataSource = [[NSMutableArray alloc] init];
    if ([HY_NSusefDefaults objectForKey:@"concern"]) {
        _dataSource = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"concern"]];
    }

    NSArray * arr = _dataSource;
    return arr;
}

-(void)getData{
        //全天
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createDataSource) name:@"getData" object:nil];
    
}

- (void)createDataSource{
    _memory_data = [NSMutableArray array];
    NSData * data = [HY_NSusefDefaults objectForKey:@"usePowerData"];
    NSArray * dataArr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    _memory_data = [NSMutableArray arrayWithArray:dataArr];
    [self analyDataWithData:dataArr];
}

- (void)initData{
    _nameArr = [NSMutableArray array];
    _timeArr = [NSMutableArray array];
}

- (void)analyDataWithData:(NSArray *)dataArr {
    [SVProgressHUD dismiss];
    [self initData];
    int min= 0,position =0;
    for (DeviceModel * model  in dataArr) {
        for (int i = 0; i < model.dataArr.count -1 ; i++) {
            DataModel * data = model.dataArr[i];
            min =  [data.day intValue] *24 + [data.Month intValue] * 30 * 24 +[data.hour intValue];
            position = i;
            for (int j = i + 1; j < model.dataArr.count; j++) {
                DataModel * data2 = model.dataArr[j];
                int num2 =  [data2.day intValue] *24 + [data2.Month intValue] * 30 * 24 +[data2.hour intValue];
                if (min > num2) {
                    min = num2;
                    position = j;
                }
            }
            if (position != i) {
                DataModel * temp = model.dataArr[i];
                model.dataArr[i] = model.dataArr[position];
                model.dataArr[position] = temp;
            }
        }
    }
    //设备id排序
    NSMutableArray * arr = [[NSMutableArray alloc] init];
    HYSingleManager *manager = [HYSingleManager sharedManager];
    NSMutableArray *deID = [[NSMutableArray alloc] init];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        for (int j = 0; j<company.child_obj1.count; j++) {
            CTerminalModel *terminal = company.child_obj1[j];
            for (int k = 0; k<terminal.child_obj.count; k++) {
                CMPModel *mp = terminal.child_obj[k];
                [deID addObject:[NSString stringWithFormat:@"%llu",mp.strID]];
            }
        }
    }
    
    for (int i = 0; i < deID.count; i++) {
        for (int j = 0; j<dataArr.count; j++) {
            DeviceModel * model = dataArr[j];
            DLog(@"%@",model.De_addr);
            if ([model.De_addr isEqualToString: deID[i]]) {
                [arr addObject:dataArr[j]];
            }
        }
    }
    
    dataArr = arr;
    /////////
    /////上面的方法将数据按档案中电表的顺序排序
    ///////
    _data = dataArr;
    //时间
    for (int j = 0; j<dataArr.count; j++) {
        for (int i = dayNum-1; i >= 0; i--) {
            NSDate * currentDate = [NSDate dateWithTimeIntervalSinceNow:-(60*60*24)*i];
            NSDateFormatter * dateFormatter =[[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd"];
            NSString * time = [dateFormatter stringFromDate:currentDate];
            [_timeArr addObject:time];
        }
    }
    //计算用量存入_dataSource
    _dataSource = [[NSMutableArray alloc] init];
    _charData = [[NSMutableArray alloc] init];
    for (int k = 0; k < _data.count; k++)
    {
        DeviceModel * de = _data[k];
        DeviceModel * charModel = [[DeviceModel alloc] init];
        charModel.dataArr = [[NSMutableArray alloc] init];
        charModel.De_addr = de.De_addr;
        for (int i = 0; i<de.dataArr.count - 1; i++)
        {
            DataModel * data = de.dataArr[i];
            int j = i +1;
            DataModel * data1 = de.dataArr[j];
            double count = 0;
            NSString * countString = [[NSString alloc] init];
            if ([self isFloatText:data1.data] && [self isFloatText:data.data]) {
                count = [data1.data doubleValue] * [data1.ct doubleValue] * [data1.pt doubleValue] - [data.data doubleValue] * [data.ct doubleValue] * [data.pt doubleValue];
                countString = [NSString stringWithFormat:@"%.4f",count];
            }else{
                countString = @"--------";
            }
            DLog(@"%@--%@--%@",countString,data1.ct,data.ct);
            [_dataSource addObject:countString];
            //获取图表model
            [charModel.dataArr addObject:countString];
        }
        [_charData addObject:charModel];
    }
    //更新数据
    [self uploadChart];
}

/** 更新图表*/
-(void)uploadChart
{
    [_char1 darwStartWith:_charData];
}

- (BOOL)isFloatText:(NSString *)str{
    NSString * regex        = @"^[0-9]*[.][0-9]*$";
    NSPredicate * pred      = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch            = [pred evaluateWithObject:str];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self getData];
    [self becomeFirstResponder];
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

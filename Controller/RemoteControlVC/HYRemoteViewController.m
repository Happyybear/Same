//
//  HYRemoteViewController.m
//  HYSEM
//
//  Created by xlc on 16/11/15.
//  Copyright © 2016年 WGM. All rights reserved.
//

#import "HYRemoteViewController.h"
#import "WGMSectorButton.h"
#import "ArchieveTree.h"
#import "YLProgressBar.h"
@interface HYRemoteViewController ()<TWlALertviewDelegate,GCDAsyncSocketDelegate>
{
    TWLAlertView *alertView;
    NSString *_mpID,*TermianalAd;
    GCDAsyncSocket *_sendSocket;
    NSString *ipv6Addr;
    int step;//第几部step 1,2,3
    int kind;//操作树 kind =0 设备 kind = 1终端
    int op_type;//操作类型 op_type 1，2，3，4 四种操作
    UILabel * tipLabel;/** 显示选择设备*/
    UILabel * tipLabel2;/** 显示选择设备（用于滚动）已弃用*/
    UIImageView * bgView;//选择层灰色背景
    CABasicAnimation * _caanimation;/** 滚动动画*/
    CABasicAnimation * _caanimation1;/** 滚动动画*/
    NSTimer *_timer;//计时器 用于加锁重新计时
    int request;//是否在控制操作过程内 request = 1正在请求
    UIButton *_btn;//进度条背景
    UILabel * _processLabel; //进度条信息
    
}
@property (nonatomic, weak) YLProgressBar *progressBar;
@property (strong, nonatomic) IBOutlet WGMSectorButton *offBtn;
@property (strong, nonatomic) IBOutlet WGMSectorButton *relieveBtn;
@property (strong, nonatomic) IBOutlet WGMSectorButton *warningBtn;
@property (strong, nonatomic) IBOutlet WGMSectorButton *onBtn;
@property (strong, nonatomic) IBOutlet WGMSectorButton *middleBtn;
@property (strong, nonatomic) IBOutlet UIImageView *middleImage;


@property (nonatomic, strong) IBOutlet YLProgressBar      *progressBarFlatRainbow;
@property (nonatomic, strong) IBOutlet YLProgressBar      *progressBarFlatWithIndicator;
@property (nonatomic, strong) IBOutlet YLProgressBar      *progressBarFlatAnimated;
@property (nonatomic, strong) IBOutlet YLProgressBar      *progressBarRoundedSlim;
@property (nonatomic, strong) IBOutlet YLProgressBar      *progressBarRoundedFat;

@end

@implementation HYRemoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = @"遥控器";
    [self.leftButton setImage:[UIImage imageNamed:@"icon_function"] forState:UIControlStateNormal];
    [self setLeftButtonClick:@selector(leftButtonClick)];
    
    [self.rightButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [self setRightButtonClick:@selector(RightButtonClick)];
    
    ipv6Addr = [self convertHostToAddress:SocketHOST];
    request = 0;
    step = 1;
    _middleImage.image = [UIImage imageNamed:@"image_lock"];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [self configUI];
    [self offButton];
}

#pragma mark - **************** 配置UI
- (void)configUI
{
    /** 添加信息展示label*/
    [self addTipView];
    /** 添加选择按钮*/
    [self addSelectBtn];
}

#pragma mark - **************** 添加选择View
/**
 *  @brief  在遥控页面弹出选择树页面，来选择操作的设备
 *
 *  @param  application
 *  @param  launchOptions   点击选择按钮，页面弹出选择树
 *
 *  @return
 
 */
-(void)addSelectedView{
    // ------添加遮罩层
    [self addMaskView];
    // ------btn停止响应
    self.rightButton.userInteractionEnabled = NO;
    ArchieveTree * tree = [[ArchieveTree alloc] initWithFrame:CGRectMake(40*ScreenMultiple, 40*ScreenMultiple+69, SCREEN_W-80*ScreenMultiple, SCREEN_H - 60*ScreenMultiple)];
    tree.layer.masksToBounds = YES;
    tree.layer.borderWidth = 0;
    tree.layer.cornerRadius = (SCREEN_W-80*ScreenMultiple)/20;
    [tree configUI];
    // ------block回调
    tree.cotrolerSelected = ^(Node * node){
        if (node.depth == 3) {//逻辑树
            NSMutableString * string1 = [[NSMutableString alloc] init];
            NSMutableString * string2 = [[NSMutableString alloc] init];
            NSMutableString * string3 = [[NSMutableString alloc] init];
            HYSingleManager *manager = [HYSingleManager sharedManager];
            for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
                CCompanyModel *company = manager.archiveUser.child_obj[i];
                for (int j = 0; j<company.child_obj.count; j++) {
                    CTransitModel *transit = company.child_obj[j];
                    [string1 appendFormat:@"%@",transit.name];
                    for (int k = 0; k<transit.child_obj.count; k++) {
                        CSetModel *set = transit.child_obj[k];
                        [string2 appendFormat:@"%@",set.name];
                        for (int m = 0; m<set.child_obj.count; m++) {
                            CMPModel *mp = set.child_obj[m];
                            if (mp.strID == node.nodeId) {
                                [string3 appendFormat:@"%@",mp.name];
                            }
                        }
                    }
                }
            }
            tipLabel.text = [NSString stringWithFormat:@"选择设备：%@->%@->%@",string1,string2,string3];
            kind = 0;
        }else if(node.depth == 1){
            tipLabel.text = [NSString stringWithFormat:@"选择终端：%@",node.name];
            kind = 1;
        }
    };
    __weak typeof(tree) weakTree = tree;
    __weak typeof(self) weakSelf = self;
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
            [bgView removeFromSuperview];
            bgView = nil;
        }];
        self.rightButton.userInteractionEnabled = YES;
        [weakSelf.rdv_tabBarController setTabBarHidden:NO animated:YES];
    };
    [[UIApplication sharedApplication].keyWindow addSubview:tree];
//    [self.view addSubview:tree];
}

- (void)addMaskView
{
    // ------遮罩层
    if (!bgView) {
        bgView = [[UIImageView alloc] initWithFrame:CGRectMake(-40*ScreenMultiple, -69-40*ScreenMultiple, SCREEN_W +40*ScreenMultiple, SCREEN_H*2)];
        //    [self addSubview:bgView];
        bgView.backgroundColor = [UIColor grayColor];
        bgView.alpha = 0.8;
        bgView.userInteractionEnabled = NO;
        [[UIApplication sharedApplication].keyWindow addSubview:bgView];
    }
}
#pragma mark - **************** 选择终端
- (void)addSelectBtn
{
   
}
#pragma mark - **************** 显示选择设备信息
- (void)addTipView
{
    tipLabel = [FactoryUI createLabelWithFrame:CGRectMake(0, 0, SCREEN_W, 40*ScreenMultiple) text:@"请选择要操作的设备" textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:14]];
    tipLabel.numberOfLines = 0;
    UIView * tipView = [FactoryUI createViewWithFrame:CGRectMake(0, 0, SCREEN_W, 40*ScreenMultiple)];
    [tipView addSubview:tipLabel];
    
    UIButton * tipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tipBtn.frame = CGRectMake(0, 0, SCREEN_W, 40*ScreenMultiple);
    [tipView addSubview:tipBtn];
    [tipBtn addTarget:self action:@selector(selet) forControlEvents:UIControlEventTouchUpInside];
    
//    tipLabel2 = [FactoryUI createLabelWithFrame:CGRectMake(tipLabel.frame.origin.x + tipLabel.frame.size.width, tipLabel.frame.origin.y, tipLabel.frame.size.width, tipLabel.frame.size.height) text:@"请选择要操作的设备" textColor:[UIColor grayColor] font:[UIFont systemFontOfSize:14]];
//    [tipView addSubview:tipLabel2];
    
    [tipView setBackgroundColor:RGBA(248, 248, 255, 0.5)];
    [self.view addSubview:tipView];
    
    // ------加入滚动动画
//    [self addAnimation];
}
#pragma mark - **************** 进入选择页面
-(void)selet
{
    if (!bgView) {
        [self addSelectedView];
        [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
    }
}
// ------动画效果
- (void)addAnimation
{
    _caanimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    _caanimation.duration = 6.0f;
    _caanimation.repeatCount = MAXFLOAT;
    _caanimation.removedOnCompletion = NO;
    _caanimation.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    _caanimation.fromValue = @(tipLabel.center.x);
    _caanimation.toValue= @(-tipLabel.frame.size.width);
    [tipLabel.layer addAnimation:_caanimation forKey:@"A"];
    
//    [UIView animateWithDuration:4 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//        tipLabel.frame = CGRectMake(-tipLabel.frame.size.width, tipLabel.frame.origin.y, tipLabel.frame.size.width, tipLabel.frame.size.height);
//        tipLabel2.frame = CGRectMake(0, tipLabel2.frame.origin.y, tipLabel2.frame.size.width, tipLabel2.frame.size.height);
//    } completion:^(BOOL finished) {
//        tipLabel.frame = firstFrame;
//        tipLabel2.frame = secondFrame;
//        [self addAnimation];
//    }];
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


- (void)initSocket
{
    if ([_sendSocket isConnected]) {
        [_sendSocket disconnect];
    }
    _sendSocket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_sendSocket connectToHost:ipv6Addr onPort:SocketonPort withTimeout:10 error:nil];
}

//告警
- (IBAction)warningClick:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"jiesuo"] == YES) {
        if ([self judgeMpBlank] == YES) {
            if ([self judgeMpCorrect]) {
                //组帧
                [self initSocket];
                if (kind == 0) {
                    [self writeDataToHost:2];
                }else if(kind == 1){
                    step = 1;
                    [self writeDataToHostT:2 WithStep:1];
                }
                
            }else{
                [UIView addMJNotifierWithText:@"请选择正确表" dismissAutomatically:NO];
            }
        }else{
            [UIView addMJNotifierWithText:@"请选择一块表" dismissAutomatically:NO];
        }
    }else{
        [UIView addMJNotifierWithText:@"请先解锁" dismissAutomatically:NO];
    }
}

//停电
- (IBAction)offPowerClick:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"jiesuo"] == YES) {
        if ([self judgeMpBlank] == YES) {
            if ([self judgeMpCorrect]) {
                //组帧
                [self initSocket];
                if (kind == 0) {
                    [self writeDataToHost:0];
                }else if(kind == 1){
                    step = 1;
                    [self writeDataToHostT:0 WithStep:1];
                }
            }else{
                [UIView addMJNotifierWithText:@"请选择正确表" dismissAutomatically:NO];
            }
        }else{
            [UIView addMJNotifierWithText:@"请选择一块表" dismissAutomatically:YES];
        }
        
    }else{
        [UIView addMJNotifierWithText:@"请先解锁" dismissAutomatically:NO];
    }
}

//送电
- (IBAction)onPowerClick:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"jiesuo"] == YES) {
        if ([self judgeMpBlank] == YES) {
            if ([self judgeMpCorrect]) {
                //组帧
                [self initSocket];
                if (kind == 0) {
                    [self writeDataToHost:1];
                }else if(kind == 1){
                    step = 1;
                    [self writeDataToHostT:1 WithStep:1];
                }
            }else{
                [UIView addMJNotifierWithText:@"请选择正确表" dismissAutomatically:NO];
            }
        }else{
            [UIView addMJNotifierWithText:@"请选择一块表" dismissAutomatically:YES];
        }
        
    }else{
        [UIView addMJNotifierWithText:@"请先解锁" dismissAutomatically:NO];
    }
}

//解除
- (IBAction)relieveClick:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"jiesuo"] == YES) {
        if ([self judgeMpBlank] == YES) {
            if ([self judgeMpCorrect]) {
                //组帧
                [self initSocket];
                if (kind == 0) {
                    [self writeDataToHost:3];
                }else if(kind == 1){
                    step = 1;
                    [self writeDataToHostT:3 WithStep:1];
                }
            }else{
                [UIView addMJNotifierWithText:@"请选择正确表" dismissAutomatically:NO];
            }
        }else{
            [UIView addMJNotifierWithText:@"请选择一块表" dismissAutomatically:YES];
        }
        
    }else{
        [UIView addMJNotifierWithText:@"请先解锁" dismissAutomatically:NO];
    }
}

#pragma mark --中间点击
- (IBAction)middleBtnClick:(id)sender {
    DLog(@"点击了中间");
//    self.waveView.progress += 0.2;
//    HYExplainManager * e=[HYExplainManager shareManager];
//    [e feeToBCD:126135 Buf:nil];
    HYSingleManager *manager = [HYSingleManager sharedManager];
    
//    [self writeDataToHostT:0 WithStep:2];
    if (![manager.functionPowerArray[9] isEqualToString:@"1"]) {
        [UIView addMJNotifierWithText:@"对不起,权限不足!" dismissAutomatically:NO];
    }else{
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"jiesuo"] == YES) {
            
        }else{
            [self loadAlertView:@"操作选项" contentStr:nil btnNum:2 btnStrArr:[NSArray arrayWithObjects:@"确定",@"取消",nil] type:17];
        }

    }
}

- (void)writeDataToHost:(int)type
{
    // ------重新开启计时器
    if (_timer.isValid){
        [_timer invalidate];
    }
    request = 1;
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(offButton) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
    NSString *terminal_ID;
    NSString *mp_add;
    NSArray * arr = [HY_NSusefDefaults objectForKey:@"controlSeletced"];
    if (arr.count > 0) {
        NSNumber * m_kind = arr[0];
        NSString * m_mp = arr[1];
        if ([m_kind intValue] == (kind +3)) {
            _mpID = m_mp;
            // ------添加进度条
            if (step == 1) {
                [self creatControl];
            }
        }else{
            DLog(@"获取操作设备有问题");
            [UIView addMJNotifierWithText:@"请选择要操作的设备" dismissAutomatically:YES];
            return;
        }
    }else{
        [UIView addMJNotifierWithText:@"请选择要操作的设备" dismissAutomatically:NO];
        return;
    }

    HYSingleManager *manager = [HYSingleManager sharedManager];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        for (int j = 0; j<company.child_obj1.count; j++) {
            CTerminalModel *terminal = company.child_obj1[j];
            for (int k = 0; k<terminal.child_obj.count; k++) {
                CMPModel *mp = terminal.child_obj[k];
                if ([_mpID isEqualToString:[NSString stringWithFormat:@"%llu",mp.strID]]) {
                    terminal_ID = terminal.term_ID;
                    mp_add = mp.mp_csAddr;
                }
            }
        }
    }
    HYExplainManager *explain = [HYExplainManager shareManager];
    NSData *data = [explain combinRemoteControlFrame:terminal_ID :mp_add :type :manager.user.check_ID];
    DLog(@"%@",data);
    [_sendSocket writeData:data withTimeout:10 tag:0];
}


#pragma mark - **************** 控制终端
/**
 *type表示操作类型
 *step表示操作步骤
 */
- (void)writeDataToHostT:(int)type WithStep:(int)m_step
{
    //    [self initSocket];
    // ------重新开启计时器
    if (_timer.isValid){
        [_timer invalidate];
    }
    
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(offButton) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    
    
    op_type = type;
    NSString *terminal_ID;
    NSArray * arr = [HY_NSusefDefaults objectForKey:@"controlSeletced"];
    if (arr.count > 0) {
        NSNumber * m_kind = arr[0];
        NSString * m_termianlID = arr[1];
        if ([m_kind intValue] == kind) {
            terminal_ID = m_termianlID;
            terminal_ID = TermianalAd;
            _mpID = terminal_ID;
            // ------进度条
            if (step == 1) {
                [self creatControl];
            }
            DLog(@"%@",terminal_ID);
        }else{
            DLog(@"获取操作设备有问题");
            [UIView addMJNotifierWithText:@"请选择要操作的设备" dismissAutomatically:YES];
            return;
        }
    }else{
        [UIView addMJNotifierWithText:@"请选择要操作的设备" dismissAutomatically:NO];
        return;
    }
    HYSingleManager *manager = [HYSingleManager sharedManager];
    HYExplainManager * explain = [HYExplainManager shareManager];
    NSData * data;
    //
//    [self creatControl];
    //
    switch (type) {
        case 1://送电
        {/**
          *1.终端保电解除
          *2.允许合闸
          *3.终端保电投入
          *- (NSData *)combinTermianlControlFrame:(NSString *)terminalAddress :(NSString *)mpAddress step:(int)type chekID:(UInt64)Usr_checkID;
          */
            request = 1;
            if (step == 1) {
                _processLabel.text = @"终端保电解除";
            }else if (step == 2){
                _processLabel.text = @"允许合闸";
            }else if (step == 3){
                _processLabel.text = @"终端保电投入";
            }
            data = [explain combinTermianlControlFrame:terminal_ID  step:m_step checkID:manager.user.check_ID];
            break;
        }
        case 0://断电
        {
          /**
             *1终端保电解除F33
             *2遥控跳闸 F1
             *3终端保电投入F25
             *
             */
            if (step == 1) {
                _processLabel.text = @"终端保电解除";
            }else if (step == 2){
                _processLabel.text = @"遥控跳闸";
            }else if (step == 3){
                _processLabel.text = @"终端保电投入";
            }
            request = 1;
            data = [explain combinTermianlOffControlFrame:terminal_ID step:m_step checkID:manager.user.check_ID];
            break;
        }
        case 2://告警
        {
            /**
             *1.终端声音允许投入F57
             *2.终端告警参数设置F23
             *3.催费告警投入 F26
             *
             */
            if (step == 1) {
                _processLabel.text = @"终端声音允许投入";
            }else if (step == 2){
                _processLabel.text = @"终端告警参数设置";
            }else if (step == 3){
                _processLabel.text = @"催费告警投入";
            }
            request = 1;
            data = [explain combinTermianlWaringControlFrame:terminal_ID step:m_step checkID:manager.user.check_ID];
            break;
        }
        case 3://解除
        {//终端解除 F34
            step = 3;
            _processLabel.text = @"解除警告";
            request = 1;
            data = [explain combinTermianlRemoveWaringControlFrame:terminal_ID step:m_step checkID:manager.user.check_ID];
            break;
        }
        default:
            break;
    }
    DLog(@"%@",data);
    [_sendSocket writeData:data withTimeout:10 tag:0];
}

// ------取消进度条
- (void)cancleProcess
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_btn removeFromSuperview];
        _btn = nil;
        [_processLabel removeFromSuperview];
        _processLabel = nil;
        [self.progressBarFlatRainbow removeFromSuperview];
        self.progressBarFlatRainbow = nil;
    });
}

// ------设置进度条的样式
- (void)initFlatRainbowProgressBar
{
    NSArray *tintColors = @[[UIColor colorWithRed:33/255.0f green:180/255.0f blue:162/255.0f alpha:1.0f],
                            [UIColor colorWithRed:3/255.0f green:137/255.0f blue:166/255.0f alpha:1.0f],
                            [UIColor colorWithRed:91/255.0f green:63/255.0f blue:150/255.0f alpha:1.0f],
                            [UIColor colorWithRed:87/255.0f green:26/255.0f blue:70/255.0f alpha:1.0f],
                            [UIColor colorWithRed:126/255.0f green:26/255.0f blue:36/255.0f alpha:1.0f],
                            [UIColor colorWithRed:149/255.0f green:37/255.0f blue:36/255.0f alpha:1.0f],
                            [UIColor colorWithRed:228/255.0f green:69/255.0f blue:39/255.0f alpha:1.0f],
                            [UIColor colorWithRed:245/255.0f green:166/255.0f blue:35/255.0f alpha:1.0f],
                            [UIColor colorWithRed:165/255.0f green:202/255.0f blue:60/255.0f alpha:1.0f],
                            [UIColor colorWithRed:202/255.0f green:217/255.0f blue:54/255.0f alpha:1.0f],
                            [UIColor colorWithRed:111/255.0f green:188/255.0f blue:84/255.0f alpha:1.0f]];
    
    _progressBarFlatRainbow.type               = YLProgressBarTypeFlat;
    _progressBarFlatRainbow.progressTintColors = tintColors;
    _progressBarFlatRainbow.hideStripes        = YES;
    _progressBarFlatRainbow.hideTrack          = YES;
    _progressBarFlatRainbow.behavior           = YLProgressBarBehaviorDefault;
//    _progressBarFlatRainbow.progressStretch = YES;
}
/**
 *  @brief  创建进度条
 *
 *  @param  application     <#application description#>
 *  @param  launchOptions   发起请求是吊起进度条
 *
 *  @return nil
 
 */

- (void)creatControl
{
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _btn.frame = self.view.frame;
    [[UIApplication sharedApplication].keyWindow addSubview:_btn];
    _btn.backgroundColor = [UIColor grayColor];
    _btn.alpha = 0.8;
    _processLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_W - 150)/2, SCREEN_H/2 - 60, 150, 50)];
    _processLabel.text = @"加载中..";
    _processLabel.font = [UIFont boldSystemFontOfSize:15];
    _processLabel.textAlignment = NSTextAlignmentCenter;
    [_btn addSubview:_processLabel];
    [self initFlatRainbowProgressBar];
    _progressBarFlatRainbow = [[YLProgressBar alloc]initWithFrame:CGRectMake(10*ScreenMultiple, SCREEN_H/2, SCREEN_W - 20*ScreenMultiple, 30*ScreenMultiple)];
    _progressBarFlatRainbow.progress = 0.1;
    [_btn addSubview:_progressBarFlatRainbow];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [sock readDataWithTimeout:10 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    DLog(@"%@",data);
    Byte *dataBytes = (Byte *)[data bytes];
    HYExplainManager *manager = [HYExplainManager shareManager];
    int nLen = (int)[data length];
    Byte dataByte[nLen];
    for (int i = 0; i<[data length]; i++) {
        dataByte[i] = dataBytes[i];
    }
    if (dataByte[6] == 0x49 && dataByte[15] == 0x00 && dataByte[16] == 0x08) {
        [self cancleProcess];
        [UIView addMJNotifierWithText:@"验证码过期" dismissAutomatically:YES];
        [_sendSocket disconnect];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        [delegate login];
        return;
    }
    if(kind == 0){
        int rValue = [manager GW09_AnalysisTripControl:dataByte :nLen];
        
        if (rValue == 0) {
            [self cancleProcess];
            [UIView addMJNotifierWithText:@"通讯异常" dismissAutomatically:YES];
            request = 0;//控制请求结束
        }else if (rValue == 1){
            self.progressBarFlatRainbow.progress = 1;
            [self cancleProcess];
            [UIView addMJNotifierWithText:@"通讯成功" dismissAutomatically:YES];
            request = 0;//控制请求结束
        }else if (rValue == 2){
            [UIView addMJNotifierWithText:@"通讯异常" dismissAutomatically:YES];
            [self cancleProcess];
            request = 0;//控制请求结束
        }

    }else if (kind == 1){
        int rValue = [manager GW09_AnalysisTerminalControl:dataByte :nLen];
        if (rValue == 0) {
            step = 1;
            [self cancleProcess];
            [UIView addMJNotifierWithText:@"通讯异常" dismissAutomatically:YES];
            request = 0;//控制请求结束
        }else if (rValue == 1){
            if (step<3) {
                self.progressBarFlatRainbow.progress = 0.3*step;
                step ++;
                [self writeDataToHostT:op_type WithStep:step];
            }else if (step == 3){
                self.progressBarFlatRainbow.progress = 1;
                [self cancleProcess];
                [UIView addMJNotifierWithText:@"通讯成功" dismissAutomatically:YES];
                request = 0;//控制请求结束
                step = 1;
            }
        }else if (rValue == 2){
            step = 1;
            [UIView addMJNotifierWithText:@"通讯失败" dismissAutomatically:YES];
            [self cancleProcess];
            request = 0;//控制请求结束
        }
    }
    [sock readDataWithTimeout:10 tag:0];
}

- (void)TSR376_Analysis_All_Frame:(unsigned char*)dataBytes :(unsigned int)length
{
    HYExplainManager *manager = [HYExplainManager shareManager];
    unsigned int val = [manager GW09_Checkout:dataBytes :length];
    unsigned int AFN = [manager TSR376_Get_AFN_Frame:dataBytes];
    switch (val) {
        case 0:
            //错误帧
            [SVProgressHUD showErrorWithStatus:@"错误帧"];
            break;
        case 1:
            switch (AFN) {
                case 0:
                    //全部确认
                    break;
                case 1:
                    //全部否认
                    [SVProgressHUD showErrorWithStatus:@"错误帧"];
                    break;
                case 2:
                    //数据单元标识确认和否认:对收到报文中的全部数据单元标识进行逐个确认/否认
                    break;
                case 3:
                    //验证码过期否认
                {
                    [SVProgressHUD showErrorWithStatus:@"验证码过期,请重新登录"];
                    [_sendSocket disconnect];
                    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                    [delegate login];
                    break;
                }
                case 4:
                    //用户验证ID,登录帧
                    
                    break;
                case 5:
                {//接收到用户档案
                    
                    break;}
                case 6:
                    //群档案
                    
                    break;
                case 7:
                {//接收单位档案
                    
                    
                    break;}
                case 8:
                {//接收线路档案
                    
                    break;}
                case 9:
                    //站线档案
                    
                    break;
                case 10:
                {
                    //终接收端档案
                    
                    break;}
                case 11:
                {//组档案
                    
                    break;}
                case 12:
                {//设备档案
                    
                    break;}
                case 13:
                {//查询2类数据
                    int iEnd;
                    [manager TSR376_Analysis_QueryInfFame:dataBytes bufer_len:length iEnd:&iEnd];
                    break;
                }
                default:
                    break;
            }
            
        default:
            break;
    }
}


//判断所选表是否为空
- (BOOL)judgeMpBlank
{
    NSArray * arr = [HY_NSusefDefaults objectForKey:@"controlSeletced"];
    if (arr.count > 0) {
        NSString * m_termianlID = arr[1];
        _mpID = m_termianlID;
    }
    HYSingleManager * manager = [HYSingleManager sharedManager];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        for (int j = 0; j<company.child_obj1.count; j++) {
            CTerminalModel *terminal = company.child_obj1[j];
            if (terminal.strID == [_mpID longLongValue]) {
                TermianalAd = terminal.term_ID;
            }
        }
    }

    if ([self isBlankString:_mpID] == NO) {
        return YES;
    }
    return NO;
}

//判断字符串是否为空
- (BOOL) isBlankString:(NSString *)string {
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

//判断所选表是否正确
- (BOOL)judgeMpCorrect
{
    NSMutableArray *mp_IDArr = [NSMutableArray array];
    HYSingleManager *manager = [HYSingleManager sharedManager];
    for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
        CCompanyModel *company = manager.archiveUser.child_obj[i];
        for (int j = 0; j<company.child_obj1.count; j++) {
            CTerminalModel *terminal = company.child_obj1[j];
            [mp_IDArr addObject:[NSString stringWithFormat:@"%llu",terminal.strID]];
            for (int k = 0; k<terminal.child_obj.count; k++) {
                CMPModel *mp = terminal.child_obj[k];
                [mp_IDArr addObject:[NSString stringWithFormat:@"%llu",mp.strID]];
            }
        }
    }
    
    for (int i = 0; i<mp_IDArr.count; i++) {
        if ([_mpID isEqualToString:mp_IDArr[i]]) {
            return YES;
        }
    }
    return NO;
}

//判断密码是否正确
- (void)judgePassWord
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    UITextField *textField = (UITextField *)[alertView viewWithTag:8888];
    UITextField *textField1 = (UITextField *)[alertView viewWithTag:8889];
    NSString *string = textField.text;
    NSString *string1 = textField1.text;
    if ([string isEqualToString:[defaults objectForKey:@"password"]]) {
        if ([string1 isEqualToString:@"000000"]) {
            [_middleImage setImage:[UIImage imageNamed:@"image_unlock"]];
            [self cancleView];
            [defaults setBool:YES forKey:@"jiesuo"];
            [defaults synchronize];
            if (_timer.isValid){
                [_timer invalidate];
            }
            _timer = nil;
            _timer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(offButton) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        }else{
            [UIView addMJNotifierWithText:@"设备密码错误,请重新输入" dismissAutomatically:NO];
        }
    }else{
        [UIView addMJNotifierWithText:@"操作员密码错误,请重新输入" dismissAutomatically:NO];
    }
}

- (void)loadAlertView:(NSString *)title contentStr:(NSString *)content btnNum:(NSInteger)num btnStrArr:(NSArray *)array type:(NSInteger)typeStr
{
    alertView = [[TWLAlertView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
    [alertView initWithTitle:title contentStr:content type:typeStr btnNum:num btntitleArr:array];
    alertView.delegate = self;
    UIView *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:alertView];
}

-(void)didClickButtonAtIndex:(NSUInteger)index password:(NSString *)password{
    switch (index) {
        case 101:
            [self cancleView];
            break;
        case 100:
            //判断管理员密码是否正确
            [self judgePassWord];
            break;
        default:
            break;
    }
}

#pragma mark - **************** 终端送电
- (IBAction)onPowerClick1:(id)sender {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"jiesuo"] == YES) {
        if ([self judgeMpBlank] == YES) {
            if ([self judgeMpCorrect] == YES) {
                //组帧
                [self initSocket];
                [self writeDataToHost:1];
            }else{
                [UIView addMJNotifierWithText:@"请选择正确表" dismissAutomatically:NO];
            }
        }else{
            [UIView addMJNotifierWithText:@"请选择一块表" dismissAutomatically:YES];
        }
        
    }else{
        [UIView addMJNotifierWithText:@"请先解锁" dismissAutomatically:NO];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error
{
    
    DLog(@"66%ld--%@",error.code,error.userInfo);
    if (error.code == 3) {
        [SVProgressHUD dismissInNow];
        [self cancleProcess];

        [UIView addMJNotifierWithText:@"连接服务器超时" dismissAutomatically:YES];
        
    }else if(error.code == 51){
        [SVProgressHUD dismissInNow];
        [self cancleProcess];

        [UIView addMJNotifierWithText:@"网络无连接" dismissAutomatically:YES];
    }else if(error.code == 0){
        if (error.userInfo) {
            [SVProgressHUD dismissInNow];
            [self cancleProcess];
            [UIView addMJNotifierWithText:@"网络无连接" dismissAutomatically:YES];
        }
    }else if(error.code == 4){
        [SVProgressHUD dismissInNow];
        [self cancleProcess];

        if(request == 1){//控制请求没回应
            [UIView addMJNotifierWithText:@"通讯失败" dismissAutomatically:YES];
            request = 0;
        }
        DLog(@"Socket 断开链接%d",[_sendSocket isConnected]);
    }else if(error.code == 61){
        [SVProgressHUD dismissInNow];
        [self cancleProcess];

        [UIView addMJNotifierWithText:@"无法连接到服务器" dismissAutomatically:YES];
    }else if(error.code == 2){
        [SVProgressHUD dismissInNow];
        [self cancleProcess];

        [UIView addMJNotifierWithText:@"连接失败" dismissAutomatically:YES];
    }else{
        [self cancleProcess];
        [SVProgressHUD dismissInNow];
        //        [UIView addMJNotifierWithText:@"获取数据失败" dismissAutomatically:YES];
    }
    
    
}

//关闭按钮
- (void)offButton
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"jiesuo"];
    [_middleImage setImage:[UIImage imageNamed:@"image_lock"]];
}

- (void)cancleView
{
    [UIView animateWithDuration:0.3 animations:^{
        alertView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [alertView removeFromSuperview];
        alertView = nil;
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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

// ------点击开始选择操作的设备
- (void)RightButtonClick
{
    // ------弹出选择树
    [self addSelectedView];
    [self.rdv_tabBarController setTabBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

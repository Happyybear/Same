//
//  CharView.m
//  HYSEM
//
//  Created by 王一成 on 2017/8/3.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "CharView.h"

#import "HYSEM-Bridging-Header.h"

#import "DeviceModel.h"

@interface CharView ()<ChartViewDelegate,IChartAxisValueFormatter>

@property (nonatomic,strong) LineChartView *LineChartView;
@property (nonatomic,strong) BarChartView  *barChartView;
@property (nonatomic,strong) BarChartData  *data;
@property (nonatomic,strong) NSMutableArray *showData;
@property (nonatomic,strong) NSMutableArray *dataSource;
@end

@implementation CharView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.barChartView = [[BarChartView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width
                                                                    , frame.size.height)];
        
        [self addView];
    }
    return self;
}
//添加视图
-(void)addView{
    [self initChartView];
    [self setCharViewStyle];
    [self setCharViewStyle];
    [self setChartViewInterface];
    [self setXStyle];
    [self setYStyle];
    [self darwStartWith:nil];
    

}
/************开始加载数据图表样式***************/
-(void)darwStartWith:(NSMutableArray *)data{
     //为柱形图提供数据
    self.data = [self setDataWithData:data];
    self.barChartView.data = self.data;
    //设置动画效果，可以设置X轴和Y轴的动画效果
    [self.barChartView animateWithYAxisDuration:1.0f];
    self.barChartView.legend.enabled = YES;//不显示图例说明
    self.barChartView.descriptionText = @"三天数据，按顺序分别为当天昨天前天";//不显示，就设为空字符串即可
}
/************初始化图表***************/
- (void)initChartView
{
//    self.barChartView = [[BarChartView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_W)];
    self.barChartView.delegate = self;//设置代理
    [self addSubview:self.barChartView];
    
}
/************设置图表样式***************/
-(void)setCharViewStyle{
    self.barChartView.backgroundColor = [UIColor colorWithRed:230/255.0f green:253/255.0f blue:253/255.0f alpha:1];
    self.barChartView.noDataText = @"暂无数据";//没有数据时的文字提示
    self.barChartView.drawValueAboveBarEnabled = YES;//数值显示在柱形的上面还是下面
    self.barChartView.highlightFullBarEnabled = YES;//点击柱形图是否显示箭头
    self.barChartView.drawBarShadowEnabled = NO;//是否绘制柱形的阴影背景
}

/************设置图表交互***************/
- (void)setChartViewInterface{
    self.barChartView.scaleYEnabled = NO;//取消Y轴缩放
    self.barChartView.doubleTapToZoomEnabled = NO;//取消双击缩放
    self.barChartView.dragEnabled = YES;//启用拖拽图表
    self.barChartView.dragDecelerationEnabled = YES;//拖拽后是否有惯性效果
    self.barChartView.dragDecelerationFrictionCoef = 0.9;//拖拽后惯性效果的摩擦系数(0~1)，数值越小，惯性越不明显
}

/************设置X轴Style**************/
- (void)setXStyle{
    //获取图表X轴
    ChartXAxis *xAxis = self.barChartView.xAxis;
    xAxis.axisLineWidth = 0.5;//设置X轴线宽
    //    xAxis.spaceMin = 10;
    xAxis.labelPosition = XAxisLabelPositionBottom;//X轴的显示位置，默认是显示在上面的
    xAxis.drawGridLinesEnabled = NO;//不绘制网格线
    //    xAxis.spaceBetweenLabels = 4;//设置label间隔，若设置为1，则如果能全部显示，则每个柱形下面都会显示label
    xAxis.labelTextColor = [UIColor brownColor];//label文字颜色
    xAxis.drawLabelsEnabled = YES;
    xAxis.gridLineWidth = 1;
    xAxis.valueFormatter = self;
}
/************设置Y轴样式***************/
-(void)setYStyle{
    //    barChartView默认样式中会绘制左右两侧的Y轴，首先需要先隐藏右侧的Y轴，代码如下：
    
    self.barChartView.rightAxis.enabled = NO;//不绘制右边轴
    ChartYAxis *leftAxis = self.barChartView.rightAxis;//获取Y轴
    leftAxis.forceLabelsEnabled = NO;//不强制绘制制定数量的label
    //    leftAxis.showOnlyMinMaxEnabled = NO;//是否只显示最大值和最小值
    leftAxis.axisMinValue = 0;//设置Y轴的最小值
    leftAxis.drawZeroLineEnabled = YES;//从0开始绘制
    leftAxis.axisMaxValue = 105;//设置Y轴的最大值
    leftAxis.inverted = NO;//是否将Y轴进行上下翻转
    leftAxis.axisLineWidth = 0.5;//Y轴线宽
    leftAxis.axisLineColor = [UIColor blackColor];//Y轴颜色
    
    //    在这里要说明一下，设置的labelCount的值不一定就是Y轴要均分的数量，这还要取决于forceLabelsEnabled属性，如果forceLabelsEnabled等于YES, 则强制绘制指定数量的label, 但是可能不是均分的.代码如下：
    
    leftAxis.labelCount = 5;
    leftAxis.forceLabelsEnabled = NO;
    //    设置Y轴上标签的样式，代码如下：
    
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;//label位置
    leftAxis.labelTextColor = [UIColor brownColor];//文字颜色
    leftAxis.labelFont = [UIFont systemFontOfSize:10.0f];//文字字体
    //    设置Y轴上标签显示数字的格式，代码如下：
    
    leftAxis.valueFormatter = [[ChartIndexAxisValueFormatter alloc] init];//自定义格式
    //    leftAxis.valueFormatter.positiveSuffix = @" $";//数字后缀单位
    //    设置Y轴上网格线的样式，代码如下：
    
    leftAxis.gridLineDashLengths = @[@3.0f, @3.0f];//设置虚线样式的网格线
    leftAxis.gridColor = [UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1];//网格线颜色
    leftAxis.gridAntialiasEnabled = YES;//开启抗锯齿
    //    在Y轴上添加限制线，代码如下：
    
    ChartLimitLine *limitLine = [[ChartLimitLine alloc] initWithLimit:80 label:@"限制线"];
    limitLine.lineWidth = 2;
    limitLine.lineColor = [UIColor greenColor];
    limitLine.lineDashLengths = @[@5.0f, @5.0f];//虚线样式
    limitLine.labelPosition = ChartLimitLabelPositionRightTop;//位置
    [leftAxis addLimitLine:limitLine];//添加到Y轴上
    leftAxis.drawLimitLinesBehindDataEnabled = YES;//设置限制线绘制在柱形图的后面
}

/**********************为barChartView的提供数据********************/

//为柱形图设置数据
- (BarChartData *)setDataWithData:(NSMutableArray *)recieveData{
    //拿出数据进行处理
    self.dataSource = [[NSMutableArray alloc] init];
    self.dataSource = recieveData;
    [self getData];
    
    
    int xVals_count = 3;//X轴上要显示多少条数据
    double maxYVal = 100;//Y轴的最大值
    
    //X轴上面需要显示的数据
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    for (int i = 0; i < xVals_count; i++) {
        [xVals addObject:[NSString stringWithFormat:@"%d月", i+1]];
    }
    
    //对应Y轴上面需要显示的数据
//    for (int i = 0; i < recieveData.count; i++) {
//        DeviceModel * deviceModel = recieveData[i];
//        for (int j = 0; j<deviceModel.dataArr.count; j++) {
//            NSString * dataString = deviceModel.dataArr[j];
//            if ([dataString floatValue]) {
//                //
//            }else{
//                dataString = @"0";
//            }
//            BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithX:j+i*4 y:[dataString floatValue]];
//            //        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithValue:val xIndex:i];
//            [yVals addObject:entry];
//        }
//    }
//    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
//    for (int i = 0; i < xVals_count; i++) {
//        double mult = maxYVal + 1;
//        double val = (double)(arc4random_uniform(mult));
//        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithX:i+4 y:val];
//        //        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithValue:val xIndex:i];
//        [yVals1 addObject:entry];
//    }
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    for (int i = 0; i < recieveData.count; i++) {
        NSMutableArray *yVals = [[NSMutableArray alloc] init];
        DeviceModel * deviceModel = recieveData[i];
        for (int j = 0; j<deviceModel.dataArr.count; j++) {
            NSString * dataString = deviceModel.dataArr[j];
            if ([dataString floatValue]) {
                //
            }else{
                dataString = @"0";
            }
            BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithX:j+i*4 y:[dataString floatValue]];
            //        BarChartDataEntry *entry = [[BarChartDataEntry alloc] initWithValue:val xIndex:i];
            [yVals addObject:entry];

        }
        //创建BarChartDataSet对象，其中包含有Y轴数据信息，以及可以设置柱形样式
        BarChartDataSet *set = [[BarChartDataSet alloc] initWithValues:yVals label:_showData[i]];
        set.barBorderWidth = 0.4;//柱形之间的间隙占整个柱形(柱形+间隙)的比例
        set.drawValuesEnabled = YES;//是否在柱形图上面显示数值
        set.highlightEnabled = NO;//点击选中柱形图是否有高亮效果，（双击空白处取消选中）
        [set setColors:ChartColorTemplates.material];//设置柱形图颜色
        
        //将BarChartDataSet对象放入数组中
        [dataSets addObject:set];


    }
//    BarChartDataSet *set2 = [[BarChartDataSet alloc] initWithValues:yVals1 label:nil];
//    
//    set2.barBorderWidth = 0.6;//柱形之间的间隙占整个柱形(柱形+间隙)的比例
//    //    set2.BARS = 50;
//    set2.drawValuesEnabled = YES;//是否在柱形图上面显示数值
//    set2.highlightEnabled = NO;//点击选中柱形图是否有高亮效果，（双击空白处取消选中）
//    [set2 setColors:ChartColorTemplates.material];//设置柱形图颜色
//    set2.label = @"222";
//    //将BarChartDataSet对象放入数组中
//    //    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
//    [dataSets addObject:set2];
//    
    
    //创建BarChartData对象, 此对象就是barChartView需要最终数据对象
    //    BarChartData *data = [[BarChartData alloc] initWithXVals:xVals dataSets:dataSets];
    BarChartData *data = [[BarChartData alloc] initWithDataSets:dataSets];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.f]];//文字字体
    [data setValueTextColor:[UIColor orangeColor]];//文字颜色
//    ChartIndexAxisValueFormatter *formatter = [[ChartIndexAxisValueFormatter alloc] init];
    //自定义数据显示格式
    
    //    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    //    [formatter setPositiveFormat:@"#0.0"];
    //    [data setValueFormatter:formatter];
    
    return data;
}
#pragma mark - **************** delegate
//1.点击选中柱形图时的代理方法，代码如下：

- (void)chartValueSelected:(ChartViewBase * _Nonnull)chartView entry:(ChartDataEntry * _Nonnull)entry dataSetIndex:(NSInteger)dataSetIndex highlight:(ChartHighlight * _Nonnull)highlight{
    //    NSLog(@"---chartValueSelected---value: %g", entry.value);
}
//2.没有选中柱形图时的代理方法，代码如下：

- (void)chartValueNothingSelected:(ChartViewBase * _Nonnull)chartView{
    NSLog(@"---chartValueNothingSelected---");
}
//当选中一个柱形图后，在空白处双击，就可以取消选择，此时会回调此方法.

//3.捏合放大或缩小柱形图时的代理方法，代码如下：

- (void)chartScaled:(ChartViewBase * _Nonnull)chartView scaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY{
    NSLog(@"---chartScaled---scaleX:%g, scaleY:%g", scaleX, scaleY);
}
//4.拖拽图表时的代理方法

- (void)chartTranslated:(ChartViewBase * _Nonnull)chartView dX:(CGFloat)dX dY:(CGFloat)dY{
    NSLog(@"---chartTranslated---dX:%g, dY:%g", dX, dY);
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
    DLog(@"%f",value);
    //获取图表X轴
    ChartXAxis *xAxis = self.barChartView.xAxis;
    switch (self.dataSource.count) {
        case 1:{
            xAxis.labelCount = 6;
            if (value == 1) {
                return _showData[0];
            }
            break;
        }
        case 2:
        {
            xAxis.labelCount = 6;
            if (value == 1) {
                return _showData[0];
            }else if (value == 5) {
                return _showData[1];
            }
            break;
        }
        case 3:
        {
            xAxis.labelCount = 8;
            if (value == 1) {
                return _showData[0];
            }else if (value == 5) {
                return _showData[1];
            }else if (value == 9) {
                return _showData[2];
            }
            
            break;
        }
        case 4:
        {
            xAxis.labelCount = 14;
            if (value == 1) {
                return _showData[0];
            }else if (value == 4+1) {
                return _showData[1];
            }else if (value == 8+1) {
                return _showData[2];
            }else if (value == 12+1) {
                return _showData[3];
            }
            break;
        }
        case 5:
        {
            xAxis.labelCount = 15;
            if (value == 0+1) {
                return _showData[0];
            }else if (value == 4+1) {
                return _showData[1];
            }else if (value == 8+1) {
                return _showData[2];
            }else if (value == 12+1) {
                return _showData[3];
            }else if (value == 16+1) {
                return _showData[4];
            }
//            return @"0";
            break;
        }
            
        default:
            break;
    }
    return nil;
//    if (value == 0||value == 2) {
//        return _showData[0];
//    }else if (value == 4||value == 5||value == 6) {
//        return _showData[1];
//    }else if (value == 8||value == 9||value == 10) {
//        return _showData[2];
//    }else if (value == 12||value == 13||value == 14) {
//        return _showData[3];
//    }else if (value == 16||value == 17||value == 18) {
//        return _showData[4];
//    }
//  return @" 完全 302动力";
//    }
}
//获取关注的设备
- (void)getData{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if ([HY_NSusefDefaults objectForKey:@"concern"]) {
        arr = [HY_NSusefDefaults objectForKey:@"concern"];
        _showData = [[NSMutableArray alloc] init];
        HYSingleManager *manager = [HYSingleManager sharedManager];
        for (int i = 0; i<manager.archiveUser.child_obj.count; i++) {
            CCompanyModel *company = manager.archiveUser.child_obj[i];
            for (int j = 0; j<company.child_obj1.count; j++) {
                CTransitModel *transit = company.child_obj1[j];
                for (int m = 0 ;m < transit.child_obj.count; m++) {
                    CMPModel * cm = transit.child_obj[m];
                    for (NSString * mpID in arr) {
                        if ([mpID isEqualToString:[NSString stringWithFormat:@"%llu",cm.strID]]) {
                            //添加电表名称
                            [_showData addObject:cm.name];
                        }
                    }
                }
            }
        }
    }
    
}


@end

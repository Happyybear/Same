//
//  PayInfoCell.m
//  HYSEM
//
//  Created by 王一成 on 2017/5/4.
//  Copyright © 2017年 WGM. All rights reserved.
//
#import "PayInfoCell.h"
#import "FactoryUI.h"
#import "HYScoketManage.h"
#import "Node.h"
#import "InfoModel.h"
@interface PayInfoCell()<UITextFieldDelegate>
{
    UITextField * _activeTextField;
    UIView * bgView;
    NSString * order;
}
@end

@implementation PayInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
//        self.contentView.backgroundColor = RGB(240, 248, 255);
//        self.contentView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void)createUI
{
    bgView = [FactoryUI createViewWithFrame:CGRectMake(0, 0, SCREEN_W, 40 * 2 * ScreenMultiple +35 *ScreenMultiple)];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:bgView];
    [self addView];
}

- (void)addView{
    NSArray * nameArr = @[@"设备名称",@"剩余金额",@"支付金额"];
    
    for (int i = 0; i < nameArr.count; i++) {
        UILabel * label = [FactoryUI createLabelWithFrame:CGRectMake(10*ScreenMultiple,  i*40*ScreenMultiple, 130*ScreenMultiple, 30*ScreenMultiple) text:nameArr[i] textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:15]];
        label.textColor = [UIColor blackColor];
        //        [sel addSubview:label];
        
        UILabel * line = [[UILabel alloc] initWithFrame:CGRectMake(0, i*40*ScreenMultiple+35*ScreenMultiple, SCREEN_W, 1)];
        line.backgroundColor = RGB(240, 248, 255);
        
        UITextField * textField = [FactoryUI createTextFieldWithFrame:CGRectMake(CGRectGetMaxX(label.frame) + 10,i*40*ScreenMultiple, 160*ScreenMultiple, 30*ScreenMultiple) text:nameArr[i] placeHolder:nil tag:(2012 +i) ];
        textField.backgroundColor = [UIColor whiteColor];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.tintColor = RGB(210, 180, 140);
        textField.textColor = RGB(210, 180, 140);
        textField.enabled = NO;
        if (i == 2) {
            textField.enabled = YES;
            textField.placeholder = @"充值金额";
            textField.text = @"";
        }
        textField.delegate = self;
//        textField.keyboardType = UIKeyboardTypeNumberPad;
        [bgView addSubview:label];
        [bgView addSubview:textField];
        [bgView addSubview:line];
    }
    
    UIButton * btn = [FactoryUI createButtonWithFrame:CGRectMake(10, 40*2*ScreenMultiple +35*ScreenMultiple + 30*ScreenMultiple, SCREEN_W - 20, 40* ScreenMultiple) title:@"支付" titleColor:[UIColor whiteColor] imageName:nil backgroundImageName:nil target:self selector:@selector(pay)];
    btn.backgroundColor = RGB(1,127,105);
    btn.layer.cornerRadius = SCREEN_W/30;
    [self.contentView addSubview:btn];
    
}


- (void)pay{
    [_activeTextField resignFirstResponder];
    self.startToPay(_node.MpID,_activeTextField.text,_node.name);
}

- (void)getConfirm{
    HYScoketManage * manegr = [HYScoketManage shareManager];
    manegr.mpID = (UInt64)[_node.MpID longLongValue];
    [manegr getNetworkDatawithIP:[HY_NSusefDefaults objectForKey:@"IP"] withTag:@"6"];
}




- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    UITextField * text = (UITextField *)[self.contentView viewWithTag:(2012 +2)];
    _activeTextField = textField;
}

- (void)upDataCellWithData:(Node *)data
{
    UITextField * text1 = (UITextField *)[self.contentView viewWithTag:(2012 +0)];
    UITextField * text2 = (UITextField *)[self.contentView viewWithTag:(2012 +1)];
    text1.text = data.name;
    text2.text = data.ramain_Fee;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_activeTextField resignFirstResponder];
}
#pragma mark -- 动画效果


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextField = textField;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end

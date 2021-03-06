//
//  PayView.m
//  PayView
//
//  Created by 王一成 on 2017/4/14.
//  Copyright © 2017年 Yicheng.Wang. All rights reserved.
//

#import "PayView.h"
#import "FactoryUI.h"
#define masnory SCREEN_W / 375
#import "PaymentMethod.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "PayViewController.h"
@interface PayView ()<UITextFieldDelegate>
{
    UIScrollView * _scrolleView;
    UITextField * _activeTextField;
    UITextField * _text1;
    UITextField * _text2;
    
}

@end
@implementation PayView

- (id)initWithFrame:(CGRect)frame
{
    
    if (self == [super initWithFrame:frame]) {
        [self configUI];
        [self dealKeyBoard];
    }
    return self;
    
}
- (void)configUI
{
    _scrolleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
    _scrolleView.bounces = YES;
    _scrolleView.showsVerticalScrollIndicator = NO;
    _scrolleView.showsHorizontalScrollIndicator = NO;
    _scrolleView.contentSize = CGSizeMake(0, SCREEN_H*2);
    _scrolleView.backgroundColor = [UIColor grayColor];
    [self createLeabel];
    [self addSubview:_scrolleView];
}

-(void) createLeabel
{
    self.nameArr = @[@"设备名称",@"表号",@"单号",@"用户名",@"倍率",@"单价",@"起码",@"止码",@"用电量",@"上次剩余电量",@"本次冲入电量",@"总电量",@"本次冲入金额"];
    for (int i = 0; i < _nameArr.count; i++) {
        UILabel * label = [FactoryUI createLabelWithFrame:CGRectMake(30*masnory, 10*masnory + i*40, 130*masnory, 30*masnory) text:self.nameArr[i] textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15]];
        label.textColor = [UIColor whiteColor];
        [_scrolleView addSubview:label];
        
        UITextField * textField = [FactoryUI createTextFieldWithFrame:CGRectMake(CGRectGetMaxX(label.frame) + 10, 10*masnory + i*40, 160*masnory, 30*masnory) text:self.nameArr[i] placeHolder:nil tag:(2012 +i) ];
        textField.backgroundColor = [UIColor whiteColor];
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.enabled = NO;
        textField.delegate = self;
        textField.text = _dataArr[i];
        if (i == _nameArr.count -1) {
            textField.enabled = YES;
            textField.text = @"";
            textField.placeholder = @"本次冲入金额";
//            textField.keyboardType = UIKeyboardTypeNumberPad;
        }
        if (i == _nameArr.count -3) {
//            textField.enabled = YES;
            textField.text = @"";
            _text1 = textField;
//            textField.placeholder = @"0";
        }
        if (i == _nameArr.count -2) {
//            textField.enabled = YES;
            _text2 = textField;
            textField.text = @"";
//            textField.placeholder = @"0";
        }
        [_scrolleView addSubview:textField];
    }
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, 10*masnory + _nameArr.count * 40 + 30 * masnory +20, SCREEN_W - 20, 30*masnory);
    btn.layer.cornerRadius = 30/4 * masnory ;
    [btn setTitle:@"立即支付" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = RGB(1,127,105);
    [_scrolleView addSubview:btn];
    _scrolleView.contentSize = CGSizeMake(0, btn.frame.origin.y + 50*masnory + 30);
}

- (void)pay{
//    PaymentMethod * pay = [PaymentMethod sharedInstance];
//    [pay doAlipayPayWith:[_activeTextField.text floatValue]];
    self.pay1(_activeTextField.text);
    [_activeTextField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITextField * text = (UITextField *)[_scrolleView viewWithTag:(2012 + _nameArr.count -3)];
    _activeTextField = textField;
    _text1.text = [NSString stringWithFormat:@"%.2f",[textField.text floatValue] / 1.2];
//    _text1.text =@"adasda";
//    UITextField * text2 = [_scrolleView viewWithTag:2012 + _nameArr.count -2];
    _text2.text = [NSString stringWithFormat:@"%.2f",1067.34 + [text.text floatValue]];
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextField = textField;
//        text.text = textField.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [ _activeTextField resignFirstResponder];
    return YES;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_activeTextField resignFirstResponder];
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
        _scrolleView.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H );
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyBoardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSValue *animationDurationValue = [[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [self beginMoveAnimition:keyBoardFrame andAnimitionDurationValue:animationDurationValue];
}

-(void)beginMoveAnimition:(CGRect)keyBoardFrame andAnimitionDurationValue:(NSValue *)animationDurationValue
{
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    if ([[self getCurrentDeviceModel] isEqualToString:@"iPhone4"] || [[self getCurrentDeviceModel] isEqualToString:@"iPhone4s"] || [[self getCurrentDeviceModel] isEqualToString:@"iPhone5"] || [[self getCurrentDeviceModel] isEqualToString:@"iPhone5s"] ||[[self getCurrentDeviceModel] isEqualToString:@"iPhone5c"]) {
        [UIView animateWithDuration:animationDuration animations:^{
            _scrolleView.frame = CGRectMake(0, -140, SCREEN_W, SCREEN_H );
        } completion:^(BOOL finished) {
            
        }];
        
    }else{
        [UIView animateWithDuration:animationDuration animations:^{
            _scrolleView.frame = CGRectMake(0, -220, SCREEN_W, SCREEN_H );
        } completion:^(BOOL finished) {
            
        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

//获得设备型号
- (NSString *)getCurrentDeviceModel
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"]) return @"iPhone2G";
    if ([platform isEqualToString:@"iPhone1,2"]) return @"iPhone3G";
    if ([platform isEqualToString:@"iPhone2,1"]) return @"iPhone3GS";
    if ([platform isEqualToString:@"iPhone3,1"]) return @"iPhone4";
    if ([platform isEqualToString:@"iPhone3,2"]) return @"iPhone4";
    if ([platform isEqualToString:@"iPhone3,3"]) return @"iPhone4";
    if ([platform isEqualToString:@"iPhone4,1"]) return @"iPhone4S";
    if ([platform isEqualToString:@"iPhone5,1"]) return @"iPhone5";
    if ([platform isEqualToString:@"iPhone5,2"]) return @"iPhone5";
    if ([platform isEqualToString:@"iPhone5,3"]) return @"iPhone5c";
    if ([platform isEqualToString:@"iPhone5,4"]) return @"iPhone5c";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone5s";
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone5s";
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone6";
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone6Plus";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone6sPlus";
    if ([platform isEqualToString:@"iPhone8,3"]) return @"iPhoneSE";
    if ([platform isEqualToString:@"iPhone8,4"]) return @"iPhoneSE";
    if ([platform isEqualToString:@"iPhone9,1"]) return @"iPhone7";
    if ([platform isEqualToString:@"iPhone9,2"]) return @"iPhone7Plus";
    
    //iPod Touch
    if ([platform isEqualToString:@"iPod1,1"])   return @"iPodTouch";
    if ([platform isEqualToString:@"iPod2,1"])   return @"iPodTouch2G";
    if ([platform isEqualToString:@"iPod3,1"])   return @"iPodTouch3G";
    if ([platform isEqualToString:@"iPod4,1"])   return @"iPodTouch4G";
    if ([platform isEqualToString:@"iPod5,1"])   return @"iPodTouch5G";
    if ([platform isEqualToString:@"iPod7,1"])   return @"iPodTouch6G";
    
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])   return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])   return @"iPad2";
    if ([platform isEqualToString:@"iPad2,2"])   return @"iPad2";
    if ([platform isEqualToString:@"iPad2,3"])   return @"iPad2";
    if ([platform isEqualToString:@"iPad2,4"])   return @"iPad2";
    if ([platform isEqualToString:@"iPad3,1"])   return @"iPad3";
    if ([platform isEqualToString:@"iPad3,2"])   return @"iPad3";
    if ([platform isEqualToString:@"iPad3,3"])   return @"iPad3";
    if ([platform isEqualToString:@"iPad3,4"])   return @"iPad4";
    if ([platform isEqualToString:@"iPad3,5"])   return @"iPad4";
    if ([platform isEqualToString:@"iPad3,6"])   return @"iPad4";
    
    //iPad Air
    if ([platform isEqualToString:@"iPad4,1"])   return @"iPadAir";
    if ([platform isEqualToString:@"iPad4,2"])   return @"iPadAir";
    if ([platform isEqualToString:@"iPad4,3"])   return @"iPadAir";
    if ([platform isEqualToString:@"iPad5,3"])   return @"iPadAir2";
    if ([platform isEqualToString:@"iPad5,4"])   return @"iPadAir2";
    
    //iPad mini
    if ([platform isEqualToString:@"iPad2,5"])   return @"iPadmini1G";
    if ([platform isEqualToString:@"iPad2,6"])   return @"iPadmini1G";
    if ([platform isEqualToString:@"iPad2,7"])   return @"iPadmini1G";
    if ([platform isEqualToString:@"iPad4,4"])   return @"iPadmini2";
    if ([platform isEqualToString:@"iPad4,5"])   return @"iPadmini2";
    if ([platform isEqualToString:@"iPad4,6"])   return @"iPadmini2";
    if ([platform isEqualToString:@"iPad4,7"])   return @"iPadmini3";
    if ([platform isEqualToString:@"iPad4,8"])   return @"iPadmini3";
    if ([platform isEqualToString:@"iPad4,9"])   return @"iPadmini3";
    if ([platform isEqualToString:@"iPad5,1"])   return @"iPadmini4";
    if ([platform isEqualToString:@"iPad5,2"])   return @"iPadmini4";
    
    if ([platform isEqualToString:@"i386"])      return @"iPhoneSimulator";
    if ([platform isEqualToString:@"x86_64"])    return @"iPhoneSimulator";
    return platform;
}

@end

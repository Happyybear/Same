//
//  SendMessageToWarningViewController.m
//  HYSEM
// 主动发送短信告警
//  Created by 王一成 on 2017/6/20.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "SendMessageToWarningViewController.h"
#import <ContactsUI/ContactsUI.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "HYScoketManage.h"

@interface SendMessageToWarningViewController()<UITextViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,CNContactPickerDelegate,ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic,strong) UITextView        * textView;
@property (nonatomic,strong) UILabel          * placeLabel;
@property (nonatomic,strong) UILabel          * personLabel;
@property (nonatomic,strong) UITextField       * personText;
@property (nonatomic,strong) NSMutableArray     * messPerson;
@property (nonatomic,copy) NSString           * phoneNum;

@end

@implementation SendMessageToWarningViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createNavigition];
    [self configUI];
    self.view.backgroundColor = [UIColor whiteColor];
}


- (void)createNavigition
{
    self.titleLabel.text = @"短信提醒";
    [self.leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self setLeftButtonClick:@selector(leftButtonClick)];
    
}

#pragma mark - **************** 返回上一级
- (void)leftButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)configUI
{
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(5*ScreenMultiple, 5*ScreenMultiple, SCREEN_W-10*ScreenMultiple, 200*ScreenMultiple)];
    self.textView.delegate = self;
    self.textView.textColor = [UIColor blackColor];
    self.textView.textContainerInset = UIEdgeInsetsMake(25*ScreenMultiple, 25*ScreenMultiple, 25*ScreenMultiple, 25*ScreenMultiple);
    self.textView.font = [UIFont systemFontOfSize:18.f];
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.textView.layer.borderWidth = 1;
    
    NSString * text = [[NSString alloc] initWithFormat:@"尊敬的用户，您好!您的设备%@，剩余金额为%@元，请及时处理。",_node.name,_node.ramain_Fee];
    self.textView.text = text;
    self.textView.contentInset = UIEdgeInsetsMake(20*ScreenMultiple, 0, 0, 0);
    //占位label
    self.placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20*ScreenMultiple, 20*ScreenMultiple, SCREEN_W-10*ScreenMultiple, 40*ScreenMultiple)];
    self.placeLabel.text = @"输入相关信息";
//    [self.textView addSubview:self.placeLabel];
    [self.view addSubview:self.textView];
    [self addMessageP];
    [self addMessgeText];
    [self addBtn];
}

#pragma mark - **************** delegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self.textView becomeFirstResponder];
    self.placeLabel.alpha = 0;
}
-(void)textViewDidChange:(UITextView *)textView
{
    self.placeLabel.alpha = 0;
}
#pragma mark - **************** 联系人
- (void)addMessageP{
    _personLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, SCREEN_W, 40*ScreenMultiple)];
    _personLabel.backgroundColor = RGB(248, 248, 248);
    _personLabel.textColor = [UIColor blackColor];
    NSDictionary *attributeDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont systemFontOfSize:15.0],NSFontAttributeName,
                                    RGB(172, 172, 175),NSForegroundColorAttributeName,
                                    nil];
    NSString * string = [NSString stringWithFormat:@" 联系人: "];
    NSMutableAttributedString * AttString = [[NSMutableAttributedString alloc] initWithString:string];
    [AttString setAttributes:attributeDict range:NSMakeRange(0, 4)];
    _personLabel.attributedText = AttString;

    _personLabel.textAlignment = NSTextAlignmentLeft;
    [self.textView addSubview:_personLabel];
}

- (void)addMessgeText
{
    _personText = [[UITextField alloc] initWithFrame:CGRectMake(60, 5*ScreenMultiple, SCREEN_W - 44*3*ScreenMultiple, 40*ScreenMultiple)];
//    _personText.backgroundColor = [UIColor whiteColor];
    _personText.delegate = self;
    _personText.layer.borderWidth = 0.3;
    _personText.layer.borderColor = [RGB(248, 248, 248) CGColor];
    _personText.keyboardType = UIKeyboardTypeNumberPad;
    [_personText becomeFirstResponder];
    [_personText addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];

    [self.view addSubview:_personText];
    if (self.messageModel.messageArr.count>0) {
        _personText.text = self.messageModel.messageArr[0];
    }else{
        _personText.placeholder = @"请输入联系信息";
    }
    //通讯录按钮
    UIButton * addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addBtn.frame = CGRectMake(SCREEN_W - 44, 5*ScreenMultiple, 44*ScreenMultiple, 44*ScreenMultiple);
    [addBtn addTarget:self action:@selector(address) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
}
//text值改变
-(void)textFieldDidChange :(UITextField *)theTextField{
    if(_phoneNum){
        _personText.text = @"";
        _phoneNum = nil;
    }else{
        NSLog(@"正在删除字符");
    }
}
//同叙录
- (void)address{
    if ([[UIDevice currentDevice].systemVersion floatValue]< 9.0) {
        ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
        peoplePicker.peoplePickerDelegate = self;
        [self presentViewController:peoplePicker animated:YES completion:nil];
    }else{
        CNContactPickerViewController * contactVc = [CNContactPickerViewController new];
        contactVc.delegate = self;
        [self presentViewController:contactVc animated:YES completion:^{
        }];
    }

}
#pragma mark - **************** iOS8回调
#pragma mark -- ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    NSString *firstName = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    if (firstName==nil) {
        firstName = @" ";
    }
    NSString *lastName=(__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (lastName==nil) {
        lastName = @" ";
    }
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person,
                                                     
                                                     kABPersonPhoneProperty);
    
    NSMutableArray *phones = [NSMutableArray arrayWithCapacity:0];
    NSString * phone = [[NSString alloc]init];
    if (ABMultiValueGetCount(phoneNumbers) > 0) {
        phone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    }
    else {
        phone = @"[None]";
        
    }
    NSString * value = [[NSString alloc] init];
    NSArray * valueArr = [phone componentsSeparatedByString:@"-"];
    if (valueArr.count > 0) {
        NSString * newString = [[NSString alloc] init];
        for (int v = 0; v < valueArr.count; v++) {
            newString = [newString stringByAppendingString:valueArr[v]];
        }
        value = newString;
    }
    _personText.text = [NSString stringWithFormat:@"%@%@--%@",lastName,firstName,phone];
    
    //通讯录获取的手机号
    _phoneNum = value;
}

//选择完成代理回调

-(void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact{
    NSLog(@"name:%@%@",contact.familyName,contact.givenName);
    CNLabeledValue * labValue = [contact.phoneNumbers lastObject];
    NSLog(@"phone:%@",[labValue.value stringValue]);
//    _messPerson = [[NSMutableArray alloc] init];
//    [_messPerson addObject:contact.familyName];
//    [_messPerson addObject:[labValue.value stringValue]];
    NSString * value = [labValue.value stringValue];
    NSArray * valueArr = [value componentsSeparatedByString:@"-"];
    if (valueArr.count > 0) {
        NSString * newString = [[NSString alloc] init];
        for (int v = 0; v < valueArr.count; v++) {
            newString = [newString stringByAppendingString:valueArr[v]];
        }
        value = newString;
    }
    _personText.text = [NSString stringWithFormat:@"%@%@--%@",contact.familyName,contact.givenName,[labValue.value stringValue]];
    
    //通讯录获取的手机号
    _phoneNum = value;
    
}
//取消选择回调

- (void)contactPickerDidCancel:(CNContactPickerViewController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}


#pragma mark -8**********取消确认
-(void)addBtn{
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(20*ScreenMultiple, CGRectGetMaxY(self.textView.frame) +10*ScreenMultiple, 110*ScreenMultiple, 30*ScreenMultiple)];
    btn.selected = YES;
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    btn.layer.cornerRadius = 5;
    [self.view addSubview:btn];
    [btn setBackgroundColor:[UIColor colorWithRed:255/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
    [btn addTarget:self action:@selector(cancle:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn1 = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_W - 20*ScreenMultiple-110*ScreenMultiple, 10*ScreenMultiple+CGRectGetMaxY(self.textView.frame), 110*ScreenMultiple, 30*ScreenMultiple)];
    [btn1 setTitle:@"确认" forState:UIControlStateNormal];
    btn1.layer.cornerRadius = 5;
    [btn1 setBackgroundColor:[UIColor colorWithRed:46/255.0 green:149/255.0 blue:250/255.0 alpha:1.0]];
    [self.view addSubview:btn1];
    [btn1 addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - **************** commit
- (void)commit
{
    if (_phoneNum) {
        NSArray * mess = [NSArray arrayWithObject:_phoneNum];
        self.messageModel.messageArr = mess;
    }else{
        if (_personText.text) {
            NSArray * mess = [NSArray arrayWithObject:_personText.text];
            self.messageModel.messageArr = mess;
        }
    }
    
    if (_textView.text.length <= 0) {
        [UIView addMJNotifierWithText:@"信息不能为空" dismissAutomatically:YES];
        return;
    }
    if (self.messageModel.messageArr.count >0) {
        NSString * phoneNum = self.messageModel.messageArr[0];
        if ([self checkOutPhoneNum:phoneNum]) {
            NSString * phoneDetail = [NSString stringWithFormat:@"%@:%@",[self checkOutPhoneNumKind:phoneNum],phoneNum];
            UIAlertView * alter = [[UIAlertView alloc] initWithTitle:@"确认发送" message:phoneDetail delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送",nil];
            [alter show];

        }else{
            [UIView addMJNotifierWithText:@"短信号码格式不对" dismissAutomatically:YES];
        }
    }else{
        [UIView addMJNotifierWithText:@"没有联系方式" dismissAutomatically:YES];
    }

}

//选择是否发送短信
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //取消
    }else if (buttonIndex == 1){
        //确认
        self.messageModel.messageLen = (int)_textView.text.length;
        self.messageModel.message = _textView.text;
//        if (self.messageModel.messageArr.count > 0) {
//            NSString * num = self.messageModel.messageArr[0];
//            NSArray * numArr = [num componentsSeparatedByString:@":"];
//            if (numArr.count > 1) {
//                self.messageModel.messageArr[0] = numArr[1];
//            }
//
//        }
        HYScoketManage * manager = [HYScoketManage shareManager];
        [manager getNetworkDatawithIP:SocketHOST withTag:@"message"];
        [manager writeMessageDataToHostWith:self.messageModel];
        
    }
}

#pragma mark - **************** 验证手机号类型
- (NSString *)checkOutPhoneNumKind:(NSString*)objc
{
    /**
     * 移动号段正则表达式
     */
    NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(178)|(18[2-4,7-8]))\\d{8}|(1705)\\d{7}$";
    /**
     * 联通号段正则表达式
     */
    NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(176)|(18[5,6]))\\d{8}|(1709)\\d{7}$";
    /**
     * 电信号段正则表达式
     */
    NSString *CT_NUM = @"^((133)|(153)|(177)|(18[0,1,9]))\\d{8}$";
    NSArray *pre = @[CM_NUM,CU_NUM,CT_NUM];
    for (int i = 0; i<3; i++) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pre[i]];
        BOOL isMtach = [predicate evaluateWithObject:objc];
        if (isMtach) {
            switch (i) {
                case 0:
                    return @"移动";
                    break;
                case 1:
                    return @"联通";
                    break;
                    
                case 2:
                    return @"电信";
                    break;
                default:
                    break;
            }
        }
    }
    return nil;
}


#pragma mark - **************** 验证手机号是否合法
- (BOOL)checkOutPhoneNum:(NSString*)objc
{
    NSString * phonePre = @"^1\\d{10}$";
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phonePre];
    BOOL isMtach = [predicate evaluateWithObject:objc];
    return isMtach;
}

-(void)cancle:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}
@end

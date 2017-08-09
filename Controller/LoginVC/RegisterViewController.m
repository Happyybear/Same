//
//  RegisterViewController.m
//  HYSEM
//
//  Created by 王一成 on 2017/7/19.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "RegisterViewController.h"
#import "HYScoketManage.h"
@interface RegisterViewController ()
{
    NSString *run;//是否可以允许注册
}
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = RGB(230, 230, 250);
    //登陆
    [self login];
    [self configButton];
    [self registNotice];
    // Do any additional setup after loading the view from its nib.
}

-(void)registNotice
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(confim) name:@"userExit" object:nil];
    [self.passWordConfirm addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

//监听输入框变化
-(void)textFieldDidChange:(UITextField *)textField
{
    if ([self.passWordConfirm.text isEqualToString:self.passwordTF.text]) {
        self.passConfirmLabel.alpha = 0;
        run = @"YES";
    }else{
        //两次输入的密码不一致
        self.passConfirmLabel.alpha = 1;
        run = @"wrong";
    }

}
//确认
- (void)confim{
    self.userLabel.alpha = 1;
    run = @"wrong";
}

//取消
-(void)cancle
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)login{
    HYScoketManage * manager = [HYScoketManage shareManager];
    [manager getNetworkDatawithIP:@"" withTag:@"1"];
//    [manager registToHostWithUser:self.userNameTF.text];
}

-(void)configButton{
    [self.registBtn  addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];
    [self.cancleBtn  addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
}

-(void)regist
{
    if (![run isEqualToString:@"wrong"]) {
        if (self.passwordTF.text.length <=0) {
            [UIView addMJNotifierWithText:@"输入密码" dismissAutomatically:YES];
        }else{
            HYScoketManage * manager = [HYScoketManage shareManager];
            [manager getNetworkDatawithIP:@"" withTag:@"10"];
            [manager registToHostWithUser:self.userNameTF.text];
            //发起注册请求
        }
    }
}
#pragma mark ----textfield delegate
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.userNameTF) {
        //查询用户名是否重复
        HYScoketManage * manager = [HYScoketManage shareManager];
        [manager getNetworkDatawithIP:@"" withTag:@"9"];
        [manager registToHostWithUser:self.userNameTF.text];
        
    }else if (textField == self.passwordTF){
    
    }else if (textField == self.passWordConfirm){
        if ([self.passWordConfirm.text isEqualToString:self.passwordTF.text]) {
        }else{
            //两次输入的密码不一致
            self.passConfirmLabel.alpha = 1;
            run = @"wrong";
        }
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.userNameTF) {
        //查询用户名是否重复
        self.userLabel.alpha = 0;
        run = @"YES";
    }else if (textField == self.passwordTF){
        
    }else if (textField == self.passWordConfirm){
        if ([self.passWordConfirm.text isEqualToString:self.passwordTF.text]) {
            self.passConfirmLabel.alpha = 0;
            run = @"YES";
        }else{
            //两次输入的密码不一致
            self.passConfirmLabel.alpha = 1;
            run = @"wrong";
        }

    }

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

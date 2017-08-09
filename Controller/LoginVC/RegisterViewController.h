//
//  RegisterViewController.h
//  HYSEM
//
//  Created by 王一成 on 2017/7/19.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *passWordConfirm;
@property (weak, nonatomic) IBOutlet UILabel *passConfirmLabel;
@property (weak, nonatomic) IBOutlet UIButton *registBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;

@end

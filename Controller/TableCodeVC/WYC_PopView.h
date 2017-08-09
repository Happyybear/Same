//
//  WYC_PopView.h
//  HYSEM
//
//  Created by 王一成 on 2017/8/4.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WYC_PopView : UIView
@property (nonatomic, assign) BOOL isShow;
//@property (nonatomic, copy) FuncBlock myFuncBlock;

//// 功能模型数组
//+ (instancetype)popViewWithFuncModels:(NSArray *)funcModels;
//// 功能字典数组
//+ (instancetype)popViewWithFuncDicts:(NSArray *)funcDicts;
- (void)showInKeyWindow;
- (void)dismissFromKeyWindow;
@end

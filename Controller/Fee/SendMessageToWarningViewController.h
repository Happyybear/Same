//
//  SendMessageToWarningViewController.h
//  HYSEM
//
//  Created by 王一成 on 2017/6/20.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "HYBaseViewController.h"

#import "MessageModel.h"

#import "Node.h"

@interface SendMessageToWarningViewController : HYBaseViewController

@property (nonatomic,strong)MessageModel * messageModel;

@property (nonatomic,strong)Node * node;
@end

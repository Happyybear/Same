//
//  PoPCell.m
//  HYSEM
//
//  Created by 王一成 on 2017/8/8.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "PoPCell.h"

@interface PoPCell()


@end

@implementation PoPCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configUI];
    }
    return self;
}

- (void)configUI{
    //因为使用hittest所以所有的frame全是固定不变的
    self.device_name = [FactoryUI createLabelWithFrame:CGRectMake(10, 0, 192 -40, self.frame.size.height) text:nil textColor:[UIColor whiteColor] font:[UIFont systemFontOfSize:15]];
    [self.contentView addSubview:self.device_name];
    DLog(@"%f",self.frame.size.width);
    self.deleteBtn = [FactoryUI createButtonWithFrame:CGRectMake(162, 0, 30, self.frame.size.height) title:nil titleColor:nil imageName:@"clear@2x" backgroundImageName:nil target:self selector:@selector(delete2:)];
    [self.contentView addSubview:self.deleteBtn];
}

- (void)delete2:(UIButton *)btn{
    self.deleteBlock(self.MpID);
}

- (void)setName:(NSString *)name
{
    self.device_name.text = name;
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    NSLog(@"进入A_View---hitTest withEvent ---");
//    UIView * view = [super hitTest:point withEvent:event];
//    NSLog(@"离开A_View--- hitTest withEvent ---hitTestView:%@",view);
//    if (point.y >=0 && point.y <= 220 && point.x >= 165) {
//        if (self.MpID) {
//            self.deleteBlock(self.MpID);
//        }
//    }
//    return view;
//}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

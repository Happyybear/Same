//
//  PayCell.m
//  HYSEM
//
//  Created by 王一成 on 2017/4/26.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "PayCell.h"

@implementation PayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self == [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configUI];
    }
    return self;
}

- (void)configUI
{
    UIView * backView = [FactoryUI createViewWithFrame:self.contentView.frame];
    backView.backgroundColor = [UIColor whiteColor];
    _image = [FactoryUI createImageViewWithFrame:CGRectMake(10, 10 * ScreenMultiple, 40 * ScreenMultiple, 40 * ScreenMultiple) imageName:nil];
    _image.image = [UIImage imageNamed:@"alipay.png"];
    _image.userInteractionEnabled = YES;
    _label = [FactoryUI createLabelWithFrame:CGRectMake(CGRectGetMaxX(_image.frame) +5, 10 * ScreenMultiple, 150, 40) text:@"支付宝" textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:19]];
//    UIButton * btn = [FactoryUI createButtonWithFrame:self.contentView.frame title:nil titleColor:nil imageName:nil backgroundImageName:nil target:self selector:@selector(paySelected:)];
//    btn.backgroundColor = [UIColor clearColor];
    _mark = [FactoryUI createImageViewWithFrame:CGRectMake(SCREEN_W - 50 *ScreenMultiple, 10*ScreenMultiple, 40*ScreenMultiple, 40*ScreenMultiple) imageName:@"mark.jpg"];
    _mark.userInteractionEnabled = YES;
    
    [backView addSubview:_mark];
//    [backView addSubview:btn];
    [backView addSubview:_image];
    [backView addSubview:_label];
    [self.contentView addSubview:backView];
    
    [self addLine];
    
}

- (void)addLine
{
    UILabel * line = [[UILabel alloc] initWithFrame:CGRectMake(0, 60*ScreenMultiple -1, SCREEN_W, 1)];
    line.backgroundColor = RGB(240, 248, 255);
    [self.contentView addSubview:line];
}

- (void)refreshMarkWithTag:(NSString *)tag
{
    if ([tag isEqualToString:@"0"]) {
        _mark.hidden = YES;
    }else{
        _mark.hidden = NO;
    }
    
    
}
- (void)paySelected:(UIButton *)btn
{
//    if (btn.selected) {
//        btn.selected = NO;
//        _mark.hidden = YES;
//    }else{
//        btn.selected = YES;
//        _mark.hidden = NO;
//    }
}
- (void)refreshUIWithtag:(NSInteger)tag
{
    if (tag == 1) {
        _image.image = [UIImage imageNamed:@"wx.jpg"];
        _label.text = @"微信支付";
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

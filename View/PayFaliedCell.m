
//
//  PayFaliedCell.m
//  HYSEM
//
//  Created by 王一成 on 2017/5/12.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "PayFaliedCell.h"

@interface PayFaliedCell()

@property (nonatomic,strong)UILabel * name;
@property (nonatomic,strong)UILabel * labelText;
@end

@implementation PayFaliedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self UI];
    }
    return self;
}

- (void)UI{
    if (_name == nil) {
        _name = [FactoryUI createLabelWithFrame:CGRectMake(10*ScreenMultiple, 5, 80, 40) text:_m_name textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:15]];
        [self.contentView addSubview:_name];
    }
    if (_labelText == nil) {
         _labelText = [FactoryUI createLabelWithFrame:CGRectMake(SCREEN_W - 10*ScreenMultiple - 240, 5, 240, 40) text:_m_labelText textColor:[UIColor blackColor] font:[UIFont systemFontOfSize:15]];
        _labelText.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_labelText];
    }
}

- (void)reloadData
{
    _name.text = _m_name;
    _labelText.text = _m_labelText;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

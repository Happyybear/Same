//
//  UserCell.m
//  HYSEM
//
//  Created by 王一成 on 2017/6/23.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell



- (void)awakeFromNib {
    [super awakeFromNib];
    [self addDeletAction];
    [self addGesture];
    // Initialization code
}

- (void)addGesture{
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteAction)];
//    longPress.numberOfTapsRequired = 1;
    longPress.minimumPressDuration = 1.5;
    [self addGestureRecognizer:longPress];
}

- (void)deleteAction
{
    [self BeginWobble];
    self.deleteBtb.hidden = NO;
//    self.deletUser(self.userNameLabel.text);
    
}

-(void)BeginWobble
{
    
    srand([[NSDate date] timeIntervalSince1970]);
    float rand=(float)random();
    CFTimeInterval t=rand*0.0000000001;
    
    [UIView animateWithDuration:0.1 delay:t options:0  animations:^
     {
         self.imageUser.transform=CGAffineTransformMakeRotation(-0.10);
     } completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse|UIViewAnimationOptionAllowUserInteraction  animations:^
          {
              self.imageUser.transform=CGAffineTransformMakeRotation(0.1);
          } completion:^(BOOL finished) {}];
     }];
}

-(void)EndWobble
{
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState animations:^
     {
//         要抖动的视图.transform=CGAffineTransformIdentity;
     } completion:^(BOOL finished) {}];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
#pragma mark - **************** 添加删除动作
- (void)addDeletAction
{
    [self.deleteBtb addTarget:self action:@selector(deleteBtnAction) forControlEvents:UIControlEventTouchUpInside];
}
//- (IBAction)delete:(id)sender {
//    self.deletUser(self.userNameLabel.text);
//}
- (void)deleteBtnAction
{
    self.deletUser(self.userNameLabel.text);
}

@end

//
//  PayOrederRecordView.h
//  HYSEM
//
//  Created by 王一成 on 2017/5/17.
//  Copyright © 2017年 WGM. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol didSelected <NSObject>
- (NSInteger)numRowOfSection;
- (void)viewDidSelectedAtIndex:(NSInteger)index;
- (CGFloat)heightForRow;
@end

@interface PayOrederRecordView : UIView

@property (nonatomic,weak)id <didSelected>delegate;

- (void)reloadData;

@end

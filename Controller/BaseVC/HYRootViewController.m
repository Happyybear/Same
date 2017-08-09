//
//  HYRootViewController.m
//  HYSEM
//
//  Created by xlc on 16/11/15.
//  Copyright © 2016年 WGM. All rights reserved.
//

#import "HYRootViewController.h"
#import "HYPayLeftViewController.h"
#import "TestViewController.h"
@interface HYRootViewController ()

@end

@implementation HYRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addChildViewControlles];
    [self checkSelect];
}

- (void)checkSelect{
    if([HY_NSusefDefaults objectForKey:@"TabBarSelect"])
    {
        self.selectedIndex = [[HY_NSusefDefaults objectForKey:@"TabBarSelect"] integerValue];
    }
}


- (BOOL)shouldAutorotate
{
    return NO;
    //return [self.viewControllers.lastObject shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return  UIInterfaceOrientationPortrait ;
}


- (void)addChildViewControlles
{
    HYTableCodeViewController *firstVC = [[HYTableCodeViewController alloc]init];
    MyNavigationController *una1 = [[MyNavigationController alloc]initWithRootViewController:firstVC];
    
    HYUsePowerViewController *secondVC = [[HYUsePowerViewController alloc]init];
    MyNavigationController *una2 = [[MyNavigationController alloc]initWithRootViewController:secondVC];
    
    HYStateViewController *thirdVC = [[HYStateViewController alloc]init];
    MyNavigationController *una3 = [[MyNavigationController alloc]initWithRootViewController:thirdVC];
    
    HYRemoteViewController *fourthVC = [[HYRemoteViewController alloc]init];
    MyNavigationController *una4 = [[MyNavigationController alloc]initWithRootViewController:fourthVC];
    
    HYReactiveViewController *fithVC = [[HYReactiveViewController alloc]init];
    MyNavigationController *una5 = [[MyNavigationController alloc]initWithRootViewController:fithVC];
    
    HYPayLeftViewController * payL = [[HYPayLeftViewController alloc] init];
    MyNavigationController * una7 = [[MyNavigationController alloc] initWithRootViewController:payL];
    
    TestViewController * testL = [[TestViewController alloc] init];
    MyNavigationController * una8 = [[MyNavigationController alloc] initWithRootViewController:testL];
    
    self.viewControllers = @[una1,una2,una5,una3,una4,una7,una8];
    
    [self customizeTabBarForController:self];
}

- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController
{
    NSInteger index = 0;
    NSArray *titles = @[@"表码",@"用量",@"无功",@"状态",@"遥控",@"Pay",@"test"];
    NSArray *itemImages = @[@"tabbar_ammeter@2x",@"tabbar_dostage@2x",@"tabbar_wastage@2x",@"tabbar_state@2x",@"tabbar_remote@2x",@"tabbar_calculate@2x",@"tabbar_remote@2x",@"tabbar_ammeter@2x"];
    NSArray *itemSelected = @[@"tabbar_ammeter1@2x",@"tabbar_dostage1@2x",@"tabbar_wastage1@2x",@"tabbar_state1@2x",@"tabbar_remote1@2x",@"tabbar_calculate1@2x",@"tabbar_remote1@2x",@"tabbar_ammeter@2x"];
    
    NSDictionary *unselectedTitleAttributes=nil;
    NSDictionary *selectedTitleAttributes=nil;
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) {
        unselectedTitleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName: RGB(255,255,255)};
        
        selectedTitleAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:RGB(69, 192, 26)};
        
    }
    
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        item.title=titles[index];
        
        NSString *normalImageName=[NSString stringWithFormat:@"%@.png",itemImages[index]];
        
        NSString *selectedImageName=[NSString stringWithFormat:@"%@.png",itemSelected[index]];
        
        UIImage *normalImage=[UIImage imageNamed:normalImageName];
        
        UIImage *selectedImage=[UIImage imageNamed:selectedImageName];
        
        [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:normalImage];
        
        //设置title字体大小与颜色
        
        [item setBackgroundColor:RGB(1, 127, 105)];
        
        item.unselectedTitleAttributes=unselectedTitleAttributes;
        
        item.selectedTitleAttributes=selectedTitleAttributes;
        
        item.layer.cornerRadius = SCREEN_W / titles.count/2 ;
        
//        item.layer.masksToBounds = SCREEN_W/titles.count/2.0;
        
        index++;
    }
    
    
}

- (void)tabBar:(RDVTabBar *)tabBar didSelectItemAtIndex:(NSInteger)index
{
    self.selectedIndex = index;
    [HY_NSusefDefaults setObject:[NSNumber numberWithInteger:index] forKey:@"TabBarSelect"];
    [self animationWithIndex:index];
}
// 动画
- (void)animationWithIndex:(NSInteger) index {
    NSMutableArray * tabbarbuttonArray = [NSMutableArray array];
    for (UIView *tabBarButton in self.tabBar.subviews) {
        if ([tabBarButton isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            [tabbarbuttonArray addObject:tabBarButton];
        }
    }
    CABasicAnimation*pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulse.duration = 0.07;
    pulse.repeatCount= 1;
    pulse.autoreverses= YES;
    pulse.fromValue= [NSNumber numberWithFloat:1];
    pulse.toValue= [NSNumber numberWithFloat:1.5];
    NSArray * arr = [[self tabBar] items];
    RDVTabBarItem *item =  arr[index];
    [item.layer addAnimation:pulse forKey:nil];
//    self.indexFlag = index;
    
}

// xcoude7.1之后的方法，使navigationBar上的字体颜色为白色
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

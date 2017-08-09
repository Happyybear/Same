//
//  SearchDisplayViewController.m
//  HYSEM
//
//  Created by 王一成 on 2017/4/27.
//  Copyright © 2017年 WGM. All rights reserved.
//
/**
 *本类是搜索页面
 *展示搜索不同的电表
 *
 *
 *
 */


#import "SearchDisplayViewController.h"
#import "Node.h"
@interface SearchDisplayViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,retain) UITableView * tableview;

@end

@implementation SearchDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setup];
    // Do any additional setup after loading the view.
}


- (void)setup{
    self.automaticallyAdjustsScrollViewInsets = NO ;
    self.tableview = [[UITableView alloc] initWithFrame:CGRectMake(0,0, SCREEN_W, SCREEN_H) style:UITableViewStylePlain];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableview];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dispalyData.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"cellID1";
    UITableViewCell * cell = [_tableview dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    Node * node = self.dispalyData[indexPath.row];
    cell.textLabel.text = node.name;
    return cell;
    
}

- (void)reloadData
{
    [self.tableview reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    Node * node = self.dispalyData[indexPath.row];
    self.gotoInfo(node);
    

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

//
//  GSTableViewController.m
//  UICollectionViewLayout
//
//  Created by 管章鹏 on 2018/7/4.
//  Copyright © 2018年 管章鹏. All rights reserved.
//

#import "GSTableViewController.h"
#import "GSWaterFlowVC.h"
#import "GSCustomLayoutVC.h"
#import "GSDateVC.h"
static NSString * const cellID = @"cell";
@interface GSTableViewController ()

@end

@implementation GSTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"CollectionView的使用";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.rowHeight = 88;
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"流水布局";
    }
    else  if (indexPath.row == 1) {
        cell.textLabel.text = @"自定义布局";
    }
    else{
         cell.textLabel.text = @"日历";
    }
    return cell;
}
#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        GSWaterFlowVC *vc = [[GSWaterFlowVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else  if (indexPath.row == 1){
        GSCustomLayoutVC *vc = [[GSCustomLayoutVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        GSDateVC *vc = [[GSDateVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end

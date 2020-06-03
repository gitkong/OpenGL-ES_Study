//
//  MainViewController.m
//  OpenGL ES_Study
//
//  Created by gitKong on 2020/6/2.
//  Copyright © 2020 whatever. All rights reserved.
//

#import "MainViewController.h"
#import "ViewController.h"
#import "MetalViewController.h"
#import "MetalCaptureViewController.h"

static NSString *kGKUITableViewCellIdentifier = @"kGKUITableViewCellIdentifier";

@interface MainViewController ()<UITableViewDataSource, UITableViewDelegate>

/// 数据源
@property (nonatomic, strong) NSArray *dataSources;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kGKUITableViewCellIdentifier];
    [self.view addSubview:tableView];
    
    self.dataSources = @[
        @"三角形",
        @"加载图片",
        @"摄像头采集",
        @"Test"
    ];
    
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource Method - Begin

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kGKUITableViewCellIdentifier];
    cell.textLabel.text = self.dataSources[indexPath.row];
    return cell;
}

#pragma mark UITableViewDataSource Method - End

#pragma mark - UITableViewDelegate Method - Begin

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ViewController *vc = [[ViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 1) {
        MetalViewController *vc = [[MetalViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 2) {
        MetalCaptureViewController *vc = [[MetalCaptureViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark UITableViewDelegate Method - End

@end

//
//  ViewController.m
//  RacOne
//
//  Created by chuang Hao on 2017/4/11.
//  Copyright © 2017年 Mr.Hao. All rights reserved.
//

#import "ViewController.h"
#import "FirstViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)jumpToRacVC:(UIButton *)sender {
    FirstViewController *firstVC = [[FirstViewController alloc] init];
    [self.navigationController pushViewController:firstVC animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

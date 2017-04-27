//
//  FirstViewController.m
//  RacOne
//
//  Created by chuang Hao on 2017/4/26.
//  Copyright © 2017年 Mr.Hao. All rights reserved.
//

#import "FirstViewController.h"
#import "MBProgressHUD.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "SecondViewController.h"
@interface FirstViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;
@property (weak, nonatomic) IBOutlet UILabel *remindLabel;

@property (nonatomic, strong) RACSignal *accountSignal;
@property (nonatomic, strong) RACSignal *passwordSignal;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"RACDemo";
    self.remindLabel.hidden = YES;
    
    [self deailAccountTextField]; //账号
    [self deailPasswordTextField];//密码
    [self deailCommitButton];     //提交按钮
}

- (void)deailAccountTextField {
    //创建account的signal
    self.accountSignal = [self.accountTextField.rac_textSignal map:^id(NSString *text) {
        return @([self isValidAccount:text]);
    }];
    //用宏定义来控制控件的backgroundColor，成立时是红色
    RAC(self.accountTextField, backgroundColor) = [self.accountSignal map:^id(NSNumber *accountValid) {
        return [accountValid boolValue] ? [UIColor redColor]:[UIColor clearColor];
    }];
}

- (void)deailPasswordTextField {
    //创建password的signal
    self.passwordSignal = [self.passwordTextField.rac_textSignal map:^id(NSString *text) {
        return @([self isValidPassword:text]);
    }];
    RAC(self.passwordTextField, backgroundColor) = [self.passwordSignal map:^id(NSNumber *passwordValid) {
        return [passwordValid boolValue] ? [UIColor redColor]:[UIColor clearColor];
    }];
}

- (void)deailCommitButton {
    //创建一个signal用来控制是否可以commit，当两者都成立的时候为true
    RACSignal *commitEnableSignal = [RACSignal combineLatest:@[self.accountSignal, self.passwordSignal] reduce:^id(NSNumber *accountValid, NSNumber *passwordValid){
        return @([accountValid boolValue] && [passwordValid boolValue]);
    }];
    @weakify(self);
    RAC(self.commitButton, enabled) = [commitEnableSignal map:^id(NSNumber *commitValid) {
        @strongify(self);
        if ([commitValid boolValue]) {
            [self.commitButton setBackgroundColor:[UIColor redColor]];
        }
        else {
            [self.commitButton setBackgroundColor:[UIColor lightGrayColor]];
        }
        return @([commitValid boolValue]);
    }];
    
    //提交按钮点击事件
    [[[[self.commitButton rac_signalForControlEvents:UIControlEventTouchUpInside]
       doNext:^(id x) {
           @strongify(self);
           [self.view endEditing:YES];
           self.remindLabel.hidden = YES;
       }]
      //按钮信号转化为提交登录信号
      flattenMap:^RACStream *(id value) {
          @strongify(self);
          [MBProgressHUD showHUDAddedTo:self.view animated:YES];
          return [self commitSignal];
      }]
     //获得数据流
     subscribeNext:^(NSNumber *x) {
         @strongify(self);
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         BOOL success = [x boolValue];
         self.remindLabel.hidden = success;
         if (success) {
             SecondViewController *secondVC = [[SecondViewController alloc] init];
             [self.navigationController pushViewController:secondVC animated:YES];
         }
         else {
             NSLog(@"登录错误");
         }
     }];
}

//可以在此处添加正则等逻辑判断
- (BOOL)isValidAccount:(NSString *)accunt {
    //最多输入11位
    if (accunt.length > 11) {
        self.accountTextField.text = [accunt substringToIndex:11];
    }
    return accunt.length >= 11;
}

- (BOOL)isValidPassword:(NSString *)password {
    return password.length >= 6;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (RACSignal *)commitSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self loginWithAccount:self.accountTextField.text password:self.passwordTextField.text complete:^(BOOL success) {
            [subscriber sendNext:@(success)];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

//模拟请求登录接口
- (void)loginWithAccount:(NSString *)account password:(NSString *)password complete:(void (^)(BOOL))loginResult {
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        BOOL success = [account isEqualToString:@"11111111111"] && [password isEqualToString:@"123456"];
        loginResult(success);
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

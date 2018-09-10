//
//  TwoViewController.m
//  TimerRetainCycle
//
//  Created by bfd on 2018/9/9.
//  Copyright © 2018年 GJ. All rights reserved.
//

#import "TwoViewController.h"
#import "NSTimer+block.h"

@interface TwoViewController ()
@property (nonatomic, weak) UILabel *label;

@property (nonatomic, weak) NSTimer *timer;
@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(100, 100, 200, 100)];
    label.backgroundColor = [UIColor orangeColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    self.label = label;

    [self timerUsage3];
}

- (void)timerUsage1 {
    NSTimer *timer = [NSTimer scheduledWeakTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    self.timer = timer;
}

- (void)timerUsage2 {
    __weak typeof(self) weakSelf = self;
    NSTimer *timer = [NSTimer timerScheduled:1 done:^(id vlaue) {
        NSLog(@"currentThread:%@",[NSThread currentThread]);
        static int initialNum = 1;
        weakSelf.label.text = [NSString stringWithFormat:@"%d",initialNum];
        initialNum++;
    }];
    self.timer = timer;
}

- (void)timerUsage3 {
    __weak typeof(self) weakSelf = self;
    NSInteger maxNum = 10;
    NSTimer *timer = [NSTimer timerExecuteCountPerSecond:maxNum done:^(NSInteger value) {
        if (value == 0) {
            weakSelf.label.text = @"已结束";
            return ;
        }
        NSLog(@"currentThread:%@",[NSThread currentThread]);
        weakSelf.label.text = [NSString stringWithFormat:@"距离结束还有%lds",value];
    }];
    self.timer = timer;
}


- (void)timerAction:(NSTimer *)timer {
    NSLog(@"currentThread:%@",[NSThread currentThread]);
    static int initialNum = 1;
    self.label.text = [NSString stringWithFormat:@"%d",initialNum];
    initialNum++;
}

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
    
    NSLog(@"%s",__func__);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

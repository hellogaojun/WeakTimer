//
//  TwoViewController.m
//  TimerRetainCycle
//
//  Created by bfd on 2018/9/9.
//  Copyright © 2018年 GJ. All rights reserved.
//

#import "TwoViewController.h"
#import "NSTimer+block.h"
#import "GJTimerProxy.h"
#import "GJTimerProxy1.h"
#import "GJTimer.h"

@interface TwoViewController ()
@property (nonatomic, weak) UILabel *label;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, weak) CADisplayLink *displayLink;

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, assign) NSTimeInterval lastTime;

@property (nonatomic, copy) NSString *timerId;

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

    [self timerUsage6];
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

#pragma mark - NSTimer,CADisplayLink依赖于runloop,如果runloop的任务过于繁重,可能导致timer不准确！！！
//========================================================================//
- (void)timerUsage4 {
    //NSTimer会对target产生强引用，如果target又对它们产生强引用，那么就会引发循环引用

    GJTimerProxy *proxy = [GJTimerProxy proxyWithTarget:self];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:proxy selector:@selector(timerAction:) userInfo:nil repeats:YES];
    self.timer = timer;
}

- (void)timerUsage5 {
    //CADisplayLink会对target产生强引用，如果target又对它们产生强引用，那么就会引发循环引用
    GJTimerProxy1 *proxy = [GJTimerProxy1 proxyWithTarget:self];
    CADisplayLink *timer = [CADisplayLink displayLinkWithTarget:proxy selector:@selector(displayLinkTimer:)];
    [timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink = timer;
}
//========================================================================//

- (void)displayLinkTimer:(CADisplayLink *)link {
    NSLog(@"displayLink");
    if (_lastTime == 0) {
           _lastTime = link.timestamp;
           return;
       }
       
   _count++;
   NSTimeInterval delta = link.timestamp - _lastTime;
   if (delta < 1) return;
   _lastTime = link.timestamp;
    //计算刷帧率
   float fps = _count / delta;
   _count = 0;
   self.label.text = [NSString stringWithFormat:@"fps:%f",fps];
}

- (void)timerUsage6 {
    NSLog(@"%s",__func__);
    __weak typeof(self) weakSelf = self;
    NSString *timerId = [GJTimer timerWithTask:^{
        NSLog(@"currentThread:%@",[NSThread currentThread]);
        static int initialNum = 1;
        weakSelf.label.text = [NSString stringWithFormat:@"%d",initialNum];
        initialNum++;
    } start:2 interval:1 repeats:YES async:NO];
    
//    NSString *timerId = [GJTimer timerWithTarget:self selector:@selector(gcdTimer) start:2 interval:1 repeats:YES async:NO];
    self.timerId = timerId;
}

- (void)gcdTimer {
    NSLog(@"currentThread:%@",[NSThread currentThread]);
    static int initialNum = 1;
    self.label.text = [NSString stringWithFormat:@"%d",initialNum];
    initialNum++;
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
    
    [self.displayLink invalidate];
    
    [GJTimer cancerTimerTaskWithId:self.timerId];
    
    NSLog(@"%s",__func__);
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end

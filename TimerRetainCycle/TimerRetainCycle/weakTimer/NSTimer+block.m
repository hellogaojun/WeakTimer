//
//  NSTimer+block.m
//  qtyd
//
//  Created by bfd on 2017/3/15.
//  Copyright © 2017年 GJ. All rights reserved.
//

#import "NSTimer+block.h"
#import <objc/runtime.h>

///中间对象[用于破除NSTimer的循环引用]
@interface WeakTimerObject: NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) SEL sel;

- (void)fire:(NSTimer *)timer;

@end

@implementation WeakTimerObject
- (void)fire:(NSTimer *)timer {
    if (self.target) {
        if ([self.target respondsToSelector:self.sel]) {
            [self.target performSelector:self.sel withObject:timer.userInfo];
        }
    } else {
        //TODO:invalidate的作用：1.The NSRunLoop object removes its strong reference to the timer
        //2.the timer removes its strong references to those objects as well.
        [self.timer invalidate];
    }
}

@end

@implementation NSTimer (block)

+ (NSTimer *)scheduledWeakTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    WeakTimerObject *weakObj = [[WeakTimerObject alloc]init];
    weakObj.target = aTarget;
    weakObj.sel = aSelector;
    weakObj.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:weakObj selector:@selector(fire:) userInfo:userInfo repeats:yesOrNo];
    return weakObj.timer;
}

- (NSInteger)executeCount {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setExecuteCount:(NSInteger)setExecuteCount {
    objc_setAssociatedObject(self, @selector(executeCount), @(setExecuteCount), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (instancetype)timerScheduled:(NSInteger)time done:(timeBlock)block {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(jdExecuteSimpleBlock:) userInfo:block repeats:YES];

    [NSRunLoop.currentRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
    return timer;
}

+ (void)jdExecuteSimpleBlock:(NSTimer *)inTimer;
{
    if ([inTimer userInfo]) {
        timeBlock block = [inTimer userInfo];
        block(inTimer);
    }
}

+ (instancetype)timerExecuteCountPerSecond:(NSInteger)offstime done:(offTimeBlock)block;
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(executeoffTimeBlock:) userInfo:block repeats:YES];

    timer.executeCount = offstime;

    [NSRunLoop.currentRunLoop addTimer:timer forMode:NSRunLoopCommonModes];
    return timer;
}

+ (void)executeoffTimeBlock:(NSTimer *)inTimer;
{
    if ([inTimer userInfo]) {
        if (inTimer.executeCount < 0) {
            inTimer.executeCount = 0;
        }

        offTimeBlock block = [inTimer userInfo];
        block(inTimer.executeCount);

        inTimer.executeCount--;

        if (inTimer.executeCount < 0) {
            [inTimer invalidate];
        }
    }
}
@end

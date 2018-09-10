//
//  NSTimer+weakTimer.m
//  TimerRetainCycle
//
//  Created by bfd on 2018/9/9.
//  Copyright © 2018年 GJ. All rights reserved.
//

#import "NSTimer+weakTimer.h"

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


@implementation NSTimer (weakTimer)

+ (NSTimer *)scheduledWeakTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    WeakTimerObject *weakObj = [[WeakTimerObject alloc]init];
    weakObj.target = aTarget;
    weakObj.sel = aSelector;
    weakObj.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:weakObj selector:@selector(fire:) userInfo:userInfo repeats:yesOrNo];
    return weakObj.timer;
}

@end

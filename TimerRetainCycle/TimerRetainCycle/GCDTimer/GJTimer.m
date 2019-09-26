//
//  GJTimer.m
//  TimerRetainCycle
//
//  Created by bfd on 2018/9/26.
//  Copyright © 2018 GJ. All rights reserved.
//

#import "GJTimer.h"

@implementation GJTimer
static NSMutableDictionary *timers_;
dispatch_semaphore_t semaphore_;

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timers_ = [NSMutableDictionary dictionary];
        semaphore_ = dispatch_semaphore_create(1);
    });
}

+ (NSString *)timerWithTask:(void (^)(void))task start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async {
    if (!task || start < 0 || (interval <= 0 && repeats)) {
        return nil;
    }
    
    dispatch_queue_t queue = async ? dispatch_get_global_queue(0, 0) : dispatch_get_main_queue() ;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, start * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0);
    
    //加锁访问存放timer的容器
    dispatch_semaphore_wait(semaphore_,DISPATCH_TIME_FOREVER);
    NSString *timerId = [NSString stringWithFormat:@"%zd",timers_.count];
    [timers_ setObject:timer forKey:timerId];
    dispatch_semaphore_signal(semaphore_);
    
    dispatch_source_set_event_handler(timer, ^{
        task();
        
        if (!repeats) {
            [self cancerTimerTaskWithId:timerId];
        }
    });
    dispatch_resume(timer);
    
    return timerId;
}

+ (NSString *)timerWithTarget:(id)target selector:(SEL)selector start:(NSTimeInterval)start interval:(NSTimeInterval)interval repeats:(BOOL)repeats async:(BOOL)async {
    if (!target || !selector) {
        return nil;
    }
    __weak typeof(target) weakTarget = target;
    return [self timerWithTask:^{
        __strong typeof(weakTarget) strongTarget = weakTarget;
        if ([strongTarget respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
             [strongTarget performSelector:selector];
#pragma clang diagnostic pop
        }
    } start:start interval:interval repeats:repeats async:async];
}

+ (void)cancerTimerTaskWithId:(NSString *)timerId {
    if (!timerId || timerId.length == 0) {
        return;
    }
    
    dispatch_semaphore_wait(semaphore_, DISPATCH_TIME_FOREVER);
    dispatch_source_t timer = timers_[timerId];
    if (timer) {
        dispatch_source_cancel(timer);
        [timers_ removeObjectForKey:timerId];
    }
    
    dispatch_semaphore_signal(semaphore_);
}

@end

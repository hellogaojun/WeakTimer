//
//  GJTimer.h
//  TimerRetainCycle
//
//  Created by bfd on 2018/9/26.
//  Copyright © 2018 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GJTimer : NSObject

/// Create Timer Based On GCD
/// @param task 定时器任务(implicitly be retained)
/// @param start 几秒后开启任务
/// @param interval 定时器间隔
/// @param repeats 是否重复
/// @param async 是否异步开启
/// @return 定时器标识id
+ (NSString *)timerWithTask:(void (^)(void))task
                      start:(NSTimeInterval)start
                    interval:(NSTimeInterval)interval
                     repeats:(BOOL)repeats
                      async:(BOOL)async;

/// Create Timer Based On GCD
/// @param target 定时器任务宿主
/// @param selector 定时器任务
/// @param start 几秒后开启任务
/// @param interval 定时器间隔
/// @param repeats 是否重复
/// @param async 是否异步开启
/// @return 定时器标识id
+ (NSString *)timerWithTarget:(id)target
                     selector:(SEL)selector
                        start:(NSTimeInterval)start
                     interval:(NSTimeInterval)interval
                      repeats:(BOOL)repeats
                        async:(BOOL)async;

/// 取消定时器
/// @param timerId 定时器标识id
+ (void)cancerTimerTaskWithId:(NSString *)timerId;

@end

NS_ASSUME_NONNULL_END

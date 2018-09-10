//
//  NSTimer+block.h
//  qtyd
//
//  Created by bfd on 2017/3/15.
//  Copyright © 2017年 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^timeBlock)(id vlaue);

typedef void (^offTimeBlock)(NSInteger value);

///add self to target,break retain cycle
@interface NSTimer (block)

/**
 倒计时剩余的时间
 */
@property (nonatomic, assign) NSInteger executeCount;

/**
 创建一个timer

 @param ti 定时器间隔
 @param aTarget 定时器target对象
 @param aSelector 定时器回调
 @param userInfo userInfo of the timer
 @param yesOrNo 是否重复
 @return timer
 */
+ (NSTimer *)scheduledWeakTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

/**
 创建一个timer

 @param time 定时器间隔
 @param block 定时器回调
 @return timer
 */
+ (instancetype)timerScheduled:(NSInteger)time done:(timeBlock)block;


/**
 创建一个timer[按1s倒计时]

 @param num 剩余的时间
 @param block 定时器回调
 @return timer
 */
+ (instancetype)timerExecuteCountPerSecond:(NSInteger)num done:(offTimeBlock)block;

@end

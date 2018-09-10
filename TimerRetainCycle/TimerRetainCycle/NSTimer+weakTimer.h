//
//  NSTimer+weakTimer.h
//  TimerRetainCycle
//
//  Created by bfd on 2018/9/9.
//  Copyright © 2018年 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>
///NSTimer(break retain cycle)
@interface NSTimer (weakTimer)

+ (NSTimer *)scheduledWeakTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

@end

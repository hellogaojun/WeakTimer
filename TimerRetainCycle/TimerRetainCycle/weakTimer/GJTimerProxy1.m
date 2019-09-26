//
//  GJTimerProxy1.m
//  TimerRetainCycle
//
//  Created by bfd on 2018/9/26.
//  Copyright © 2018 GJ. All rights reserved.
//

#import "GJTimerProxy1.h"

@interface GJTimerProxy1 ()
@property (nonatomic, weak) id target;
@end
@implementation GJTimerProxy1

+ (instancetype)proxyWithTarget:(id)target {
    GJTimerProxy1 *proxy = [self alloc];
    proxy.target = target;
    return proxy;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.target;
}

@end

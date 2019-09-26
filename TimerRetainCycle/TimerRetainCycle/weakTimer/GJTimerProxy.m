//
//  GJTimerProxy.m
//  TimerRetainCycle
//
//  Created by bfd on 2018/8/26.
//  Copyright © 2018 GJ. All rights reserved.
//

#import "GJTimerProxy.h"

@interface GJTimerProxy ()
@property (nonatomic, weak) id target;
@end

@implementation GJTimerProxy
+ (instancetype)proxyWithTarget:(id)target {
    GJTimerProxy *proxy = [self alloc];
    proxy.target = target;
    return proxy;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
}

@end

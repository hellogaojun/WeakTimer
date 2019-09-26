//
//  GJTimerProxy.h
//  TimerRetainCycle
//
//  Created by bfd on 2018/8/26.
//  Copyright © 2018 GJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GJTimerProxy : NSProxy

+ (instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END

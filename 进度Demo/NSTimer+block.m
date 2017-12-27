//
//  NSTimer+block.m
//  进度Demo
//
//  Created by 牛虎 on 2017/12/25.
//  Copyright © 2017年 Tom. All rights reserved.
//

#import "NSTimer+block.h"

@implementation NSTimer (block)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void (^)(void))block repeats:(BOOL)repeats {
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(blockInvoke:) userInfo:[block copy] repeats:repeats];
}

+ (void)blockInvoke:(NSTimer *)timer {
    void (^ block)(void) = timer.userInfo;
    if (block) {
        block();
    }
}

@end

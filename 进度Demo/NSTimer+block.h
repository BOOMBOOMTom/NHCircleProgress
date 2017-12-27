//
//  NSTimer+block.h
//  进度Demo
//
//  Created by 牛虎 on 2017/12/25.
//  Copyright © 2017年 Tom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (block)

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      block:(void(^)(void))block
                                    repeats:(BOOL)repeats;

@end

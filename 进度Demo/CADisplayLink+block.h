//
//  CADisplayLink+block.h
//  进度Demo
//
//  Created by 牛虎 on 2017/12/27.
//  Copyright © 2017年 Tom. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CADisplayLink (block)

+ (CADisplayLink *)displayLinkWithSelectorBlock:(void(^)(void))block;

@end

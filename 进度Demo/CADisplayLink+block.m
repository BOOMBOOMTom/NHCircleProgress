//
//  CADisplayLink+block.m
//  进度Demo
//
//  Created by 牛虎 on 2017/12/27.
//  Copyright © 2017年 Tom. All rights reserved.
//

#import "CADisplayLink+block.h"
#import <objc/runtime.h>

static char * const kObjcKey = "kObjcKey";

@implementation CADisplayLink (block)

+ (CADisplayLink *)displayLinkWithSelectorBlock:(void(^)(void))block{
    objc_setAssociatedObject(self, &kObjcKey, block, OBJC_ASSOCIATION_COPY);
    return [self displayLinkWithTarget:self selector:@selector(selectorBlock)];
}
+ (void)selectorBlock{
    
    void (^block)(void) = objc_getAssociatedObject(self, &kObjcKey);
    if (block) {
        block();
    }
}
@end

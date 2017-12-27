//
//  ViewController.m
//  进度Demo
//
//  Created by 牛虎 on 2017/12/22.
//  Copyright © 2017年 Tom. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Extensions.h"
#import "NHCircleProgress.h"

#import "CADisplayLink+block.h"


#define NHRGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)


@interface ViewController ()

@end

@implementation ViewController{
    NHCircleProgress *circle1;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    [self initCircles];
}
//初始化
- (void)initCircles {
    
#pragma drawRect实现方式
    //默认状态
    circle1 = [[NHCircleProgress alloc] initWithFrame:CGRectMake(50, 50, 300, 300) pathBackColor:nil pathFillColor:NHRGB(arc4random()%255, arc4random()%255, arc4random()%255) startAngle:-220 strokeWidth:5];
    circle1.progress = 0.6;
    circle1.animationModel = 1;
    [self.view addSubview:circle1];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    circle1.progress = 1;
}

@end

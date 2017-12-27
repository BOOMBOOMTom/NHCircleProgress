//
//  NHCircleProgress.m
//  进度Demo
//
//  Created by 牛虎 on 2017/12/25.
//  Copyright © 2017年 Tom. All rights reserved.
//

#import "NHCircleProgress.h"
#import "NSTimer+block.h"
#import "CADisplayLink+block.h"

//角度转换为弧度
#define CircleDegreeToRadian(d) ((d)*M_PI)/180.0
//255进制颜色转换
#define CircleRGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
//宽高定义
#define CircleSelfWidth self.frame.size.width
#define CircleSelfHeight self.frame.size.height

#define ToRad(deg)         ( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)        ( (180.0 * (rad)) / M_PI )
#define SQR(x)            ( (x) * (x) )


@implementation NHCircleProgress{
    CGFloat fakeProgress;
    NSTimer *timer;//定时器用作动画
    CADisplayLink *link;
}
- (instancetype)init {
    if (self = [super init]) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialization];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialization];
}

//初始化
- (instancetype)initWithFrame:(CGRect)frame
                pathBackColor:(UIColor *)pathBackColor
                pathFillColor:(UIColor *)pathFillColor
                   startAngle:(CGFloat)startAngle
                  strokeWidth:(CGFloat)strokeWidth {
    if (self = [super initWithFrame:frame]) {
        [self initialization];
        if (pathBackColor) {
            _pathBackColor = pathBackColor;
        }
        if (pathFillColor) {
            _pathFillColor = pathFillColor;
        }
        _startAngle = CircleDegreeToRadian(startAngle);
        _strokeWidth = strokeWidth;
    }
    return self;
}

//初始化数据
- (void)initialization {
    self.backgroundColor = [UIColor clearColor];
    _pathBackColor = CircleRGB(204, 204, 204);
    _pathFillColor = CircleRGB(219, 184, 102);
    _strokeWidth = 10;//线宽默认为10
    _startAngle = -CircleDegreeToRadian(90);//圆起点位置
    _reduceAngle = CircleDegreeToRadian(0);//整个圆缺少的角度
    _animationModel = CircleIncreaseByProgress;//根据进度来
    _showPoint = YES;//小圆点
    _showProgressText = YES;//文字
    _forceRefresh = NO;//一直刷新动画
    
    fakeProgress = 0.0;//用来逐渐增加直到等于progress的值
    //获取图片资源
    _pointImage = [UIImage imageNamed:@"circle_point1"];
    
    
    
}

#pragma Set
- (void)setStartAngle:(CGFloat)startAngle {
    if (_startAngle != CircleDegreeToRadian(startAngle)) {
        _startAngle = CircleDegreeToRadian(startAngle);
        [self setNeedsDisplay];
    }
}

- (void)setReduceAngle:(CGFloat)reduceAngle {
    if (_reduceAngle != CircleDegreeToRadian(reduceAngle)) {
        if (reduceAngle>=360) {
            return;
        }
        _reduceAngle = CircleDegreeToRadian(reduceAngle);
        [self setNeedsDisplay];
    }
}

- (void)setStrokeWidth:(CGFloat)strokeWidth {
    if (_strokeWidth != strokeWidth) {
        _strokeWidth = strokeWidth;
        [self setNeedsDisplay];
    }
}

- (void)setPathBackColor:(UIColor *)pathBackColor {
    if (_pathBackColor != pathBackColor) {
        _pathBackColor = pathBackColor;
        [self setNeedsDisplay];
    }
}

- (void)setPathFillColor:(UIColor *)pathFillColor {
    if (_pathFillColor != pathFillColor) {
        _pathFillColor = pathFillColor;
        [self setNeedsDisplay];
    }
}

- (void)setShowPoint:(BOOL)showPoint {
    if (_showPoint != showPoint) {
        _showPoint = showPoint;
        [self setNeedsDisplay];
    }
}

-(void)setShowProgressText:(BOOL)showProgressText {
    if (_showProgressText != showProgressText) {
        _showProgressText = showProgressText;
        [self setNeedsDisplay];
    }
}


//画背景线、填充线、小圆点、文字
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //获取图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //设置中心点 半径 起点及终点
    CGFloat maxWidth = self.frame.size.width<self.frame.size.height?self.frame.size.width:self.frame.size.height;
    CGPoint center = CGPointMake(maxWidth/2.0, maxWidth/2.0);
    CGFloat radius = maxWidth/2.0-_strokeWidth/2.0-50;//留出一像素，防止与边界相切的地方被切平
    CGFloat endA = _startAngle + (CircleDegreeToRadian(360) - _reduceAngle);//圆终点位置
    CGFloat valueEndA = _startAngle + (CircleDegreeToRadian(260)-_reduceAngle)*fakeProgress;  //数值终点位置
    
    //背景线
    UIBezierPath *basePath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:_startAngle endAngle:endA clockwise:YES];
    //线条宽度
    CGContextSetLineWidth(ctx, _strokeWidth);
    //设置线条顶端
    CGContextSetLineCap(ctx, kCGLineCapRound);
    //线条颜色
    [_pathBackColor setStroke];
    //把路径添加到上下文
    CGContextAddPath(ctx, basePath.CGPath);
    //渲染背景线
    CGContextStrokePath(ctx);
    
    //路径线
    UIBezierPath *valuePath = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:_startAngle endAngle:valueEndA clockwise:YES];
    //设置线条顶端
    CGContextSetLineCap(ctx, kCGLineCapRound);
    //线条颜色
    [_pathFillColor setStroke];
    //把路径添加到上下文
    CGContextAddPath(ctx, valuePath.CGPath);
    //渲染数值线
    CGContextStrokePath(ctx);
    
    //小尾巴 开始
    //起点
    CGPoint startpoint = [self pointFromCenter:center radiu:radius Angle:-220];
    CGContextMoveToPoint(ctx, startpoint.x, startpoint.y);
    //终点
    CGContextAddLineToPoint(ctx, startpoint.x-20, startpoint.y+20);
    CGContextSetLineWidth(ctx, _strokeWidth);
    [_pathFillColor setStroke];
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    
    //画文字
    NSString *leftText = [NSString stringWithFormat:@"0"];
    //段落格式
    NSMutableParagraphStyle *leftTextTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    leftTextTextStyle.lineBreakMode = NSLineBreakByWordWrapping;
    leftTextTextStyle.alignment = NSTextAlignmentCenter;//水平居中
    //字体
    UIFont *leftTextFont = [UIFont systemFontOfSize:18];
    //构建属性集合
    NSDictionary *leftTextAttributes = @{NSFontAttributeName:leftTextFont, NSParagraphStyleAttributeName:leftTextTextStyle,
                                         NSForegroundColorAttributeName:[UIColor whiteColor]};
    //获得size
    CGSize leftTextStringSize = [leftText sizeWithAttributes:leftTextAttributes];
    //垂直居中
    CGRect leftTextframe = CGRectMake(startpoint.x-20, startpoint.y+30,leftTextStringSize.width, leftTextStringSize.height);
    [leftText drawInRect:leftTextframe withAttributes:leftTextAttributes];
    
    //小尾巴 结束
    //起点
    CGPoint point = [self pointFromCenter:center radiu:radius Angle:40];
    CGContextMoveToPoint(ctx, point.x, point.y);
    //终点
    CGContextAddLineToPoint(ctx, point.x+20, point.y+20);
    CGContextSetLineWidth(ctx, _strokeWidth);
    if (fakeProgress == 1.0) {
        [_pathFillColor setStroke];
    }else{
        [_pathBackColor setStroke];
    }
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
    
    //画文字
    NSString *rightText = [NSString stringWithFormat:@"3亿"];
    //段落格式
    NSMutableParagraphStyle *rightTextTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    rightTextTextStyle.lineBreakMode = NSLineBreakByWordWrapping;
    rightTextTextStyle.alignment = NSTextAlignmentCenter;//水平居中
    //字体
    UIFont *rightTextFont = [UIFont systemFontOfSize:18];
    //构建属性集合
    NSDictionary *rightTextAttributes = @{NSFontAttributeName:rightTextFont, NSParagraphStyleAttributeName:rightTextTextStyle,
                                          NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    //获得size
    CGSize rightTextStringSize = [rightText sizeWithAttributes:rightTextAttributes];
    //垂直居中
    CGRect rightTextframe = CGRectMake(point.x-5, point.y+30,rightTextStringSize.width, rightTextStringSize.height);
    [rightText drawInRect:rightTextframe withAttributes:rightTextAttributes];
    
    
    //2.1 设置线条的宽度
    CGContextSetLineWidth(ctx, 15);
    //2.2 设置线条的起始点样式
    CGContextSetLineCap(ctx,kCGLineCapButt);
    //2.3  虚实切换 ，实线1虚线25
    CGFloat length1[] = {1,25};
    CGContextSetLineDash(ctx, 0, length1, 2);
    //2.4 设置颜色
    [[UIColor grayColor] set];
    //3.设置路径
    CGContextAddArc(ctx, center.x , center.y, radius+_strokeWidth+20, endA, CircleDegreeToRadian(40), 0);
    //4.绘制
    CGContextStrokePath(ctx);
    
    //1.1 设置线条的宽度
    CGContextSetLineWidth(ctx, 15);
    //1.2 设置线条的起始点样式
    CGContextSetLineCap(ctx,kCGLineCapButt);
    //1.3  虚实切换 ，实线1虚线25
    CGFloat length[] = {1,25};
    CGContextSetLineDash(ctx, 0, length, 2);
    //1.4 设置颜色
    [[UIColor redColor] set];
    //2.设置路径
    CGContextAddArc(ctx, center.x , center.y, radius+_strokeWidth+20, endA, valueEndA, 0);
    //3.绘制
    CGContextStrokePath(ctx);
    
    //画小圆点
    if (_showPoint) {
        CGContextDrawImage(ctx, CGRectMake(CircleSelfWidth/2 + ((CGRectGetWidth(self.bounds)-_strokeWidth)/2.f-50)*cosf(valueEndA)-_strokeWidth*1.5, CircleSelfWidth/2 + ((CGRectGetWidth(self.bounds)-_strokeWidth)/2.f-50)*sinf(valueEndA)-_strokeWidth*1.5, _strokeWidth*3, _strokeWidth*3), _pointImage.CGImage);
    }
    
    if (_showProgressText) {
        //画文字
        NSString *currentText = [NSString stringWithFormat:@"%.0f",fakeProgress*100];
        //段落格式
        NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        textStyle.lineBreakMode = NSLineBreakByWordWrapping;
        textStyle.alignment = NSTextAlignmentCenter;//水平居中
        //字体
        UIFont *font = [UIFont systemFontOfSize:0.15*CircleSelfWidth];
        //构建属性集合
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:textStyle};
        //获得size
        CGSize stringSize = [currentText sizeWithAttributes:attributes];
        //垂直居中
        CGRect r = CGRectMake((CircleSelfWidth-stringSize.width)/2.0, (CircleSelfHeight - stringSize.height)/2.0,stringSize.width, stringSize.height);
        [currentText drawInRect:r withAttributes:attributes];
        
        //画文字
        NSString *topText = [NSString stringWithFormat:@"上面的文字"];
        //段落格式
        NSMutableParagraphStyle *topTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        topTextStyle.lineBreakMode = NSLineBreakByWordWrapping;
        topTextStyle.alignment = NSTextAlignmentCenter;//水平居中
        //字体
        UIFont *topFont = [UIFont systemFontOfSize:16];
        //构建属性集合
        NSDictionary *topAttributes = @{NSFontAttributeName:topFont, NSParagraphStyleAttributeName:topTextStyle};
        //获得size
        CGSize topStringSize = [topText sizeWithAttributes:topAttributes];
        //垂直居中
        CGRect frame = CGRectMake((CircleSelfWidth-topStringSize.width)/2.0, (CircleSelfHeight - topStringSize.height)/2.0-topStringSize.height-20,topStringSize.width, topStringSize.height);
        [topText drawInRect:frame withAttributes:topAttributes];
        
        //画文字
        NSString *bottomText = [NSString stringWithFormat:@"下面的文字"];
        //段落格式
        NSMutableParagraphStyle *bottomTextStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        bottomTextStyle.lineBreakMode = NSLineBreakByWordWrapping;
        bottomTextStyle.alignment = NSTextAlignmentCenter;//水平居中
        //字体
        UIFont *bottomFont = [UIFont systemFontOfSize:18];
        //构建属性集合
        NSDictionary *bottomAttributes = @{NSFontAttributeName:bottomFont, NSParagraphStyleAttributeName:bottomTextStyle};
        //获得size
        CGSize bottomStringSize = [bottomText sizeWithAttributes:bottomAttributes];
        //垂直居中
        CGRect bottomframe = CGRectMake((CircleSelfWidth-bottomStringSize.width)/2.0, (CircleSelfHeight - bottomStringSize.height)/2.0+bottomStringSize.height+20,bottomStringSize.width, bottomStringSize.height);
        [bottomText drawInRect:bottomframe withAttributes:bottomAttributes];
        
    }
    
}

-(CGPoint)pointFromCenter:(CGPoint)center radiu:(CGFloat)radiu Angle:(int)angleInt{
    CGPoint result;
    result.y = round(center.y + radiu * sin(ToRad(angleInt))) ;
    result.x = round(center.x + radiu * cos(ToRad(angleInt)));
    return result;
}
//设置进度
- (void)setProgress:(CGFloat)progress {
    
    if ((_progress == progress && !_forceRefresh) || progress>1.0 || progress<0.0) {
        return;
    }
    
    fakeProgress = _increaseFromLast==YES?_progress:0.0;
    BOOL isReverse = progress<fakeProgress?YES:NO;
    //赋真实值
    _progress = progress;
    
    //先暂停计时器
//    if (timer) {
//        [timer invalidate];
//        timer = nil;
//    }
    if (link) {
        [link invalidate];
        link = nil;
    }
    //如果为0或没有动画则直接刷新
    if (_progress == 0.0 || _notAnimated) {
        fakeProgress = _progress;
        [self setNeedsDisplay];
        return;
    }
    
    //设置每次增加的数值
    CGFloat sameTimeIncreaseValue = _increaseFromLast==YES?fabs(fakeProgress-_progress):_progress;
    CGFloat defaultIncreaseValue = isReverse==YES?-0.01:0.01;
    
    __weak typeof(self) weakSelf = self;
    
//    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 block:^{
//
//
//    } repeats:YES];
 //   [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    link = [CADisplayLink displayLinkWithSelectorBlock:^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        //反方向动画
        if (isReverse) {
            if (fakeProgress <= _progress || fakeProgress <= 0.0f) {
                [strongSelf dealWithLast];
                return;
            } else {
                //进度条动画
                [strongSelf setNeedsDisplay];
            }
        } else {
            //正方向动画
            if (fakeProgress >= _progress || fakeProgress >= 1.0f) {
                [strongSelf dealWithLast];
                return;
            } else {
                //进度条动画
                [strongSelf setNeedsDisplay];
            }
        }
        
        //数值增加或减少
        if (_animationModel == CircleIncreaseSameTime) {
            fakeProgress += defaultIncreaseValue*sameTimeIncreaseValue;//不同进度动画时间基本相同
        } else {
            fakeProgress += defaultIncreaseValue;//进度越大动画时间越长。
        }
    }];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
}

//最后一次动画所做的处理
- (void)dealWithLast {
    //最后一次赋准确值
    fakeProgress = _progress;
    [self setNeedsDisplay];
//    if (timer) {
//        [timer invalidate];
//        timer = nil;
//    }
    if (link) {
        [link invalidate];
        link = nil;
    }
}

@end

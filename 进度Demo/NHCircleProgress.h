//
//  NHCircleProgress.h
//  进度Demo
//
//  Created by 牛虎 on 2017/12/25.
//  Copyright © 2017年 Tom. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CircleIncreaseModel) {
    CircleIncreaseSameTime      = 0,    // 同等时间
    CircleIncreaseByProgress    = 1,    // 根据进度决定动画时间
};

@interface NHCircleProgress : UIView

//图形定制
@property (nonatomic) UIColor *pathBackColor;/**<线条背景色*/
@property (nonatomic) UIColor *pathFillColor;/**<线条填充色*/
@property (nonatomic) UIImage *pointImage;/**<小圆点图片*/

//角度相关
@property (nonatomic) CGFloat startAngle;/**<起点角度。角度从水平右侧开始为0，顺时针为增加角度。直接传度数 如-90 */
@property (nonatomic) CGFloat reduceAngle;/**<减少的角度 直接传度数 如30*/
@property (nonatomic) CGFloat strokeWidth;/**<线宽*/

@property (nonatomic) BOOL showPoint;/**<是否显示小圆点*/
@property (nonatomic) BOOL showProgressText;/**<是否显示文字*/
@property (nonatomic) BOOL increaseFromLast;/**<是否从上次数值开始动画，默认为NO*/
@property (nonatomic) BOOL notAnimated;/**<不加动画，默认为NO*/
@property (nonatomic) BOOL forceRefresh;/**<set的progress等于上次时是否仍刷新，默认为NO*/

//动画模式
@property (nonatomic) CircleIncreaseModel animationModel;/**<动画模式*/

//进度
@property (nonatomic) CGFloat progress;/**<进度 0-1 */

//初始化 坐标 线条背景色 填充色 起始角度 线宽
- (instancetype)initWithFrame:(CGRect)frame
                pathBackColor:(UIColor *)pathBackColor
                pathFillColor:(UIColor *)pathFillColor
                   startAngle:(CGFloat)startAngle
                  strokeWidth:(CGFloat)strokeWidth;

@end

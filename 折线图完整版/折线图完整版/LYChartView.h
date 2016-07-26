//
//  LYChartView.h
//  折线图完整版
//
//  Created by apple on 16/7/25.
//  Copyright © 2016年 雷晏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYChartView : UIView

/**
 *  y轴上的最大值
 */
@property (nonatomic,assign) NSInteger verticalMaxValue;

/**
 *  y轴上的值的单位
 */
@property (nonatomic,copy) NSString *unite;

/**
 *  折线的颜色
 */
@property (nonatomic,strong) NSArray<UIColor *> *colorChartValues;

/**
 *  每个点的颜色
 */
@property (nonatomic,strong) NSArray<UIColor *> *colorPointValus;

/**
 *  坐标点y的值(支持多条折线图)
 */
@property (nonatomic,strong) NSArray *values;

/**
 *  是否开启动态绘制，默认NO
 */
@property (nonatomic,assign) BOOL isAnimation;

@end

//
//  LYChartView.m
//  折线图完整版
//
//  Created by apple on 16/7/25.
//  Copyright © 2016年 雷晏. All rights reserved.
//
#define KWIDTH  40
#define KHEIGHT 20

#import "LYChartView.h"

@interface LYChartView()
{
    NSArray *_value;//每一组纵坐标点
    CGFloat _maxValue;//最大值
}

/**
 *  渐变背景视图
 */
@property (nonatomic,strong) UIView *gradientView;
/**
 *  渐变图层
 */
@property (nonatomic,strong) CAGradientLayer *gradientLayer;

/**
 *  y轴上的值
 */
@property (nonatomic,strong) NSMutableArray <NSNumber *>*verticalValues;
/**
 *  折线路径图层
 */
@property (nonatomic,strong) NSMutableArray <CAShapeLayer *>*shapeLayerArray;
/**
 *   坐标点
 */
@property (nonatomic,strong) NSMutableArray *pointButtons;

@end


@implementation LYChartView

-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        //创建渐变背景图层
        [self drawGradientBackgroundView];
        //创建x轴的数据
        [self creatHorXLabel];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    //绘制x,y坐标轴
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context,2);
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    CGContextMoveToPoint(context,KWIDTH-5-1,10);
    CGContextAddLineToPoint(context, KWIDTH-1, 5);
    CGContextAddLineToPoint(context, KWIDTH+5-1, 10);
    CGContextAddLineToPoint(context, KWIDTH-1, 5);//
    CGContextAddLineToPoint(context,KWIDTH-1, rect.size.height-KHEIGHT+1);//
    CGContextAddLineToPoint(context,rect.size.width-5,rect.size.height-KHEIGHT+1);//
    CGContextAddLineToPoint(context,rect.size.width-10,rect.size.height-KHEIGHT+1-5);
    CGContextAddLineToPoint(context,rect.size.width-5,rect.size.height-KHEIGHT+1);//
    CGContextAddLineToPoint(context,rect.size.width-10,rect.size.height-KHEIGHT+1+5);
    CGContextStrokePath(context);
}



-(void)drawGradientBackgroundView
{
    self.gradientView = [[UIView alloc]initWithFrame:CGRectMake(KWIDTH,KHEIGHT, self.frame.size.width-KWIDTH-KHEIGHT, self.frame.size.height-KHEIGHT*2)];
    [self addSubview:self.gradientView];
    
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.gradientView.bounds;
    self.gradientLayer.startPoint = CGPointMake(0, 0);
    self.gradientLayer.endPoint = CGPointMake(1, 0);
    self.gradientLayer.colors =@[
                                 (__bridge id)[UIColor colorWithRed:253 / 255.0 green:164 / 255.0 blue:8 / 255.0 alpha:1.0].CGColor,
                                 (__bridge id)[UIColor colorWithRed:251 / 255.0 green:37 / 255.0 blue:45 / 255.0 alpha:1.0].CGColor];
    [self.gradientView.layer addSublayer:self.gradientLayer];
}


-(void)creatHorXLabel
{
    NSInteger month = 12;
    for(NSInteger i = 0 ; i < month ; i++){
        UILabel *labelmonth = [[UILabel alloc]initWithFrame:CGRectMake((self.gradientView.frame.size.width/12)*i+KWIDTH, self.gradientView.frame.size.height+KHEIGHT, self.gradientView.frame.size.width/12, KHEIGHT+10)];
        labelmonth.text = [NSString stringWithFormat:@"%ld月",i+1];
        labelmonth.tag = 2000+i;
        labelmonth.font = [UIFont systemFontOfSize:10.f];
        labelmonth.textColor = [UIColor blackColor];
        labelmonth.transform = CGAffineTransformMakeRotation(M_PI*0.3);
        [self addSubview:labelmonth];
    }
}


-(void)createVerYLabel
{
    for(NSInteger i = 1 ; i <= _verticalValues.count; i++){
        UILabel *labelValue = [[UILabel alloc]initWithFrame:CGRectMake(0,(self.gradientView.frame.size.height/_verticalValues.count)*(_verticalValues.count-i)+KHEIGHT/2,KWIDTH-3, KHEIGHT)];
        labelValue.tag = 1000+i;//用来记录,方便之后获取对应的y轴值
        labelValue.text = [NSString stringWithFormat:@"%@",_verticalValues[i-1]];
        labelValue.font = [UIFont systemFontOfSize:10.f];
        labelValue.textColor = [UIColor blackColor];
        labelValue.textAlignment = NSTextAlignmentRight;
        [self addSubview:labelValue];
    }
}



#pragma mark - Set
-(void)setUnite:(NSString *)unite{
    UILabel *unitLabel = [[UILabel alloc]initWithFrame:CGRectMake(KWIDTH-3+5,5,0, 0)];
    unitLabel.text = [NSString stringWithFormat:@"单位:%@",unite];
    [unitLabel sizeToFit];
    unitLabel.font = [UIFont systemFontOfSize:9.f];
    unitLabel.textColor = [UIColor blackColor];
    [self addSubview:unitLabel];
}

-(void)setVerticalMaxValue:(NSInteger)verticalMaxValue{
    _verticalMaxValue = verticalMaxValue;
    if(@(verticalMaxValue) == nil) return;
    //计算出y轴上的值的点
    [self getVerticalValues];
    //创建y轴的数据
    [self createVerYLabel];
    //绘制虚线
    [self drawLineDash];
}

-(void)setValues:(NSArray *)values{
    _values = values;
    if(values.count == 0||_verticalValues.count == 0) return;
    //求出y轴最大值
    _maxValue = [self getMaxOfValues:values];

    //绘制折线图
    [values enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self drawLine:obj];
    }];
}

-(void)setIsAnimation:(BOOL)isAnimation{
    _isAnimation = isAnimation;
    [self startAnimationDraw:isAnimation];
}

-(void)setColorChartValues:(NSArray<UIColor *> *)colorChartValues{
    _colorChartValues = colorChartValues;
    if(colorChartValues.count == 0 || _values.count == 0)return;
    
    [_shapeLayerArray enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.strokeColor = colorChartValues[idx].CGColor;
    }];
}

-(void)setColorPointValus:(NSArray *)colorPointValus{
    if(colorPointValus.count == 0 || _values.count == 0)return;
    [_pointButtons enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull arr, NSUInteger index, BOOL * _Nonnull stop) {
        [arr enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.backgroundColor = colorPointValus[index];
        }];
    }];
}

-(void)drawLine:(NSArray *)value
{
    _value = value;//每一组纵坐标点
    
    CAShapeLayer *lineShapeLayer = [CAShapeLayer layer];
    lineShapeLayer.fillColor = [UIColor clearColor].CGColor;
    UIBezierPath *lineBezierPath = [UIBezierPath bezierPath];
    
    UILabel *label = (UILabel*)[self viewWithTag:2000];//根据横坐标上面的label 获取直线关键点的x 值
    
    /******绘制折线*******/
    
    [lineBezierPath moveToPoint:CGPointMake(label.frame.origin.x+label.frame.size.width/2-KWIDTH,self.gradientView.frame.size.height/_maxValue*(_maxValue-[value[0] floatValue]))];
    for(int i = 1 ; i < value.count ; i++){
        UILabel *label1 = (UILabel*)[self viewWithTag:2000+i];//根据横坐标上面的label 获取直线关键点的x 值
        [lineBezierPath addLineToPoint:CGPointMake(label1.frame.origin.x+label1.frame.size.width/2-KWIDTH,self.gradientView.frame.size.height/_maxValue*(_maxValue-[value[i] floatValue]))];
    }
    lineShapeLayer.path = lineBezierPath.CGPath;
    lineShapeLayer.lineWidth = 1;
    lineShapeLayer.lineCap = kCALineCapRound;
    lineShapeLayer.lineJoin = kCALineJoinRound;
    [self.gradientView.layer addSublayer:lineShapeLayer];
    [self.shapeLayerArray addObject:lineShapeLayer];
    
    
    //保存每组点
    NSMutableArray *buttons = [NSMutableArray array];
    
    //绘制每一个坐标点
    for(int i = 0 ; i < value.count ; i++){
        
        UILabel *label = (UILabel*)[self viewWithTag:2000+i];//根据横坐标上面的label 获取直线关键点的x 值
        
        //坐标点
        UIButton *pointBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 6, 6)];
        pointBtn.tag = i;
        pointBtn.center = CGPointMake(label.frame.origin.x+label.frame.size.width/2-KWIDTH,self.gradientView.frame.size.height/_maxValue*(_maxValue-[value[i] floatValue]));
        pointBtn.backgroundColor = [UIColor blueColor];
        pointBtn.layer.cornerRadius = 3;
        pointBtn.layer.masksToBounds = YES;
        [self.gradientView addSubview:pointBtn];
        [pointBtn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //坐标点对应的值
        UILabel *labelValue = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 40, 20)];
        labelValue.center = CGPointMake(label.frame.origin.x+label.frame.size.width/2-KWIDTH+20,self.gradientView.frame.size.height/_maxValue*(_maxValue-[value[i] floatValue])+10);
        labelValue.textColor = [UIColor blackColor];
        labelValue.font = [UIFont systemFontOfSize:9.f];
        labelValue.text = [NSString stringWithFormat:@"%@",value[i]];
        [self.gradientView addSubview:labelValue];
        
        
        [buttons addObject:pointBtn];
    }
    
    [self.pointButtons addObject:buttons];

}

#pragma mark button click event
-(void)clickBtn:(UIButton *)button{
    
}


#pragma -mark 动态绘制折线
-(void)startAnimationDraw:(BOOL)animation{
    if(animation == YES){
        
        [_shapeLayerArray enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            basicAnimation.fromValue = @(0);
            basicAnimation.toValue = @(1);
            basicAnimation.duration = 2;
            basicAnimation.fillMode = kCAFillModeForwards;
            basicAnimation.removedOnCompletion = NO;
            [obj addAnimation:basicAnimation forKey:nil];
        }];
    }
}



-(void)drawLineDash
{
    for(int i = 1 ; i < _verticalValues.count;i++){
        
        CAShapeLayer *dashShapeLayer = [CAShapeLayer layer];
        dashShapeLayer.fillColor = [UIColor clearColor].CGColor;
        dashShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        dashShapeLayer.lineWidth = 2.f;
        
        //设置虚线，数组第一个@20设置虚线每根线的长度，第二个@5设置虚线间隔的长度
        [dashShapeLayer setLineDashPattern:@[@20,@5]];
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint:CGPointMake(0,self.gradientView.frame.size.height/_verticalValues.count*(_verticalValues.count-i))];
        [bezierPath addLineToPoint:CGPointMake(self.gradientView.frame.size.width,self.gradientView.frame.size.height/_verticalValues.count*(_verticalValues.count-i))];
        dashShapeLayer.path = bezierPath.CGPath;
        [self.gradientView.layer addSublayer:dashShapeLayer];
        
    }
}


#pragma mark - private method
-(CGFloat)getMaxOfValues:(NSArray *)value{
    __block  CGFloat maxMax = 0;
    __block  CGFloat max = 0;
    [value enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger idx, BOOL * _Nonnull stop) {
        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat value = [obj floatValue];
            max = MAX(max, value);
        }];
        maxMax = MAX(maxMax, max);
    }];
    return maxMax;
}


//计算出y轴上的值的点
-(void)getVerticalValues{
    //平分10等份
    NSInteger temp = 0;
    for(int i = 0 ; i < 10 ; i++){
        temp = _verticalMaxValue/10 * (i+1);
        [self.verticalValues addObject:@(temp)];
    }
}

#pragma mark - Get
-(NSMutableArray<CAShapeLayer *> *)shapeLayerArray{
    if(!_shapeLayerArray){
        _shapeLayerArray = [NSMutableArray array];
    }
    return _shapeLayerArray;
}

-(NSMutableArray *)pointButtons{
    if(!_pointButtons){
        _pointButtons = [NSMutableArray array];
    }
    return _pointButtons;
}

-(NSMutableArray<NSNumber *> *)verticalValues{
    if(!_verticalValues){
        _verticalValues = [NSMutableArray array];
    }
    return _verticalValues;
}

////排序，从低到高,并且去重
//-(NSArray *)sequenceArray{
//    NSSet *set = [NSSet setWithArray:_verticalValues];
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:nil ascending:YES];
//    NSArray *array = [set sortedArrayUsingDescriptors:@[sortDescriptor]];
//    return array;
//}
@end

//
//  ViewController.m
//  折线图完整版
//
//  Created by apple on 16/7/25.
//  Copyright © 2016年 雷晏. All rights reserved.
//

#import "ViewController.h"
#import "LYChartView.h"

@interface ViewController ()
@property (nonatomic,strong) LYChartView *chartView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _chartView = [[LYChartView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 20,300)];
    _chartView.center = self.view.center;
    _chartView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_chartView];
    
    _chartView.unite = @"km";
    _chartView.verticalMaxValue = 1000;
    _chartView.values = @[
                          @[@500,@200,@600,@400,@800,@900,@700,@500,@300,@100],
                          @[@1000,@800,@300,@600,@100,@400,@700,@200],
                          @[@100,@200,@700,@300,@600,@400,@800,@700,@300,@600]
                          ];

    _chartView.colorChartValues = @[[UIColor greenColor],[UIColor blueColor],[UIColor yellowColor]];
    _chartView.colorPointValus = @[[UIColor magentaColor],[UIColor cyanColor],[UIColor purpleColor]];
//    _chartView.isAnimation = YES;

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    _chartView.isAnimation = YES;
}

@end

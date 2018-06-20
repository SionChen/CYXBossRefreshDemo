//
//  CYXRefreshHeader.m
//  CYXBossRefreshDemo
//
//  Created by 超级腕电商 on 2018/6/20.
//  Copyright © 2018年 超级腕电商. All rights reserved.
//

#import "CYXRefreshHeader.h"
#import "UIView+Size.h"
/*header高度*/
const CGFloat HeaderHeight = 10.0;
/*header高度*/
const CGFloat HeaderWidth = 50.0;
/*偏移量刷新高度*/
const CGFloat RefreshFullOffset = 40;
/*圆球半径*/
const CGFloat RefreshArcRadius = 5;
/*中心点距离两边的最大值*/
const CGFloat RefreshMaxWidth = 20;
/*动画时间*/
const CGFloat KeyAnimationDuration = 0.5;
#define pointColor    [UIColor colorWithRed:90 / 255.0 green:200 / 255.0 blue:200 / 255.0 alpha:1.0].CGColor

@interface CYXRefreshHeader()
/*第一个点*/
@property (nonatomic,strong) CAShapeLayer *firstPointLayer;
/*第二个点*/
@property (nonatomic,strong) CAShapeLayer *secondPointLayer;
/*第三个点*/
@property (nonatomic,strong) CAShapeLayer *thirdPointLayer;
/*weak是为了防止循环引用*/
@property (nonatomic,weak) UIScrollView *scrollView;
/*正在执行动画*/
@property (nonatomic,assign) BOOL isAnimating;
/*偏移量*/
@property (nonatomic,assign) CGFloat offSet;
@end
@implementation CYXRefreshHeader
-(instancetype)init{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.frame = CGRectMake(0, HeaderHeight, HeaderWidth, HeaderHeight);
        [self.layer addSublayer:self.firstPointLayer];
        [self.layer addSublayer:self.secondPointLayer];
        [self.layer addSublayer:self.thirdPointLayer];
        self.firstPointLayer.frame = CGRectMake(HeaderWidth/2-RefreshArcRadius, HeaderHeight/2-RefreshArcRadius, RefreshArcRadius*2, RefreshArcRadius*2);
        self.secondPointLayer.frame = CGRectMake(HeaderWidth/2-RefreshArcRadius, HeaderHeight/2-RefreshArcRadius, RefreshArcRadius*2, RefreshArcRadius*2);
        self.thirdPointLayer.frame = CGRectMake(HeaderWidth/2-RefreshArcRadius, HeaderHeight/2-RefreshArcRadius, RefreshArcRadius*2, RefreshArcRadius*2);
        self.firstPointLayer.path = [self pointPath].CGPath;
        self.secondPointLayer.path = [self pointPath].CGPath;
        self.thirdPointLayer.path = [self pointPath].CGPath;
        //[self startAnimation];
//        self.firstPointLayer.frame = CGRectMake(HeaderWidth/2-RefreshMaxWidth-RefreshArcRadius, HeaderHeight/2-RefreshArcRadius, RefreshArcRadius*2, RefreshArcRadius*2);
//        self.secondPointLayer.frame = CGRectMake(HeaderWidth/2-RefreshArcRadius, HeaderHeight/2-RefreshArcRadius, RefreshArcRadius*2, RefreshArcRadius*2);
//        self.thirdPointLayer.frame = CGRectMake(HeaderWidth/2+RefreshMaxWidth-RefreshArcRadius, HeaderHeight/2-RefreshArcRadius, RefreshArcRadius*2, RefreshArcRadius*2);
    }
    return self;
}
#pragma mark ---Path
-(UIBezierPath *)pointPath{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(RefreshArcRadius, RefreshArcRadius) radius:RefreshArcRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    return path;
}
/*父视图改变的时候*/
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        self.scrollView = (UIScrollView *)newSuperview;
        self.centerX = self.scrollView.width/2;
        self.bottom = 0;
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }else {
        [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    }
}
/*执行动画*/
-(void)startAnimation{
    self.isAnimating = YES;
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = RefreshFullOffset;
        self.scrollView.contentInset = inset;
    }];
    CAKeyframeAnimation * animation = [self opacityAnimation];
    [self.firstPointLayer addAnimation:animation forKey:@"opacity"];
    
    animation = [self opacityAnimation];
    animation.beginTime = CACurrentMediaTime()+KeyAnimationDuration/2;
    [self.secondPointLayer addAnimation:animation forKey:@"opacity"];
    
    animation = [self opacityAnimation];
    animation.beginTime = CACurrentMediaTime()+KeyAnimationDuration;
    [self.thirdPointLayer addAnimation:animation forKey:@"opacity"];
}
/*停止动画*/
-(void)stopAnimation{
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = 0.f;
        self.scrollView.contentInset = inset;
    } completion:^(BOOL finished) {
        [self.thirdPointLayer removeAllAnimations];
        [self.firstPointLayer removeAllAnimations];
        [self.secondPointLayer removeAllAnimations];
        self.isAnimating = NO;
    }];
}
-(CAKeyframeAnimation *)opacityAnimation{
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.duration = KeyAnimationDuration;
    
    animation.repeatCount = HUGE_VALF;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = KeyAnimationDuration*2;
    animation.values = @[[NSNumber numberWithFloat:1.0f],
                         [NSNumber numberWithFloat:0.0f],
                         [NSNumber numberWithFloat:1.0f],
                         [NSNumber numberWithFloat:1.0f]];
    return animation;
}
#pragma mark ---Kvo
/*监听偏移量*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        self.offSet =  self.scrollView.contentOffset.y;
        [self setOffSetUI];
    }
}
/*设置*/
-(void)setOffSetUI{
    //如果到达临界点，则执行刷新动画
    if (!self.isAnimating&&self.offSet<=0) {
        CGFloat scale = -self.offSet/RefreshFullOffset;
        if (scale>1) {scale=1;}
        if (scale<0) {scale=0;}
        CGFloat centerX = HeaderWidth/2;
        CGFloat maxLeftX = centerX-RefreshMaxWidth;
        CGFloat maxLeftDistance = centerX - maxLeftX;
        CGFloat maxRightX = centerX+RefreshMaxWidth;
        CGFloat maxRightDistance = maxRightX - centerX;
        
        self.firstPointLayer.frame = CGRectMake(centerX-maxLeftDistance*scale-RefreshArcRadius, HeaderHeight/2-RefreshArcRadius, RefreshArcRadius*2, RefreshArcRadius*2);
        self.thirdPointLayer.frame = CGRectMake(centerX+maxRightDistance*scale-RefreshArcRadius, HeaderHeight/2-RefreshArcRadius, RefreshArcRadius*2, RefreshArcRadius*2);
        CGFloat topY =-(RefreshFullOffset/2-RefreshFullOffset/2.0*(1.0-scale))-RefreshArcRadius*2;//y坐标的变化
        self.top = topY;
    }
    if (-self.offSet >= RefreshFullOffset && !self.isAnimating && !self.scrollView.dragging) {
        //刷新
        [self startAnimation];
        if (self.refresh) {
            self.refresh();
        }
    }
}
/*初始化layer坐标*/
-(void)initLayerFrame{
    self.firstPointLayer.frame = CGRectMake(HeaderWidth/2-RefreshArcRadius, HeaderHeight/2-RefreshArcRadius, RefreshArcRadius*2, RefreshArcRadius*2);
    self.secondPointLayer.frame = CGRectMake(HeaderWidth/2-RefreshArcRadius, HeaderHeight/2-RefreshArcRadius, RefreshArcRadius*2, RefreshArcRadius*2);
    self.thirdPointLayer.frame = CGRectMake(HeaderWidth/2-RefreshArcRadius, HeaderHeight/2-RefreshArcRadius, RefreshArcRadius*2, RefreshArcRadius*2);
}
#pragma mark ---Start/End
-(void)endRefresh{
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets inset = self.scrollView.contentInset;
        inset.top = 0.f;
        self.scrollView.contentInset = inset;
    } completion:^(BOOL finished) {
        [self stopAnimation];
        [self initLayerFrame];
    }];
}
-(void)startRefresh{
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, -RefreshFullOffset);
    [self startAnimation];
}
#pragma mark ---G
-(CAShapeLayer*)firstPointLayer{
    if(!_firstPointLayer){
        _firstPointLayer = [CAShapeLayer layer];
        _firstPointLayer.fillColor = pointColor;
    }
    return _firstPointLayer;
}
-(CAShapeLayer*)secondPointLayer{
    if(!_secondPointLayer){
        _secondPointLayer = [CAShapeLayer layer];
        _secondPointLayer.fillColor = pointColor;
    }
    return _secondPointLayer;
}
-(CAShapeLayer*)thirdPointLayer{
    if(!_thirdPointLayer){
        _thirdPointLayer = [CAShapeLayer layer];
        _thirdPointLayer.fillColor = pointColor;
    }
    return _thirdPointLayer;
}
@end

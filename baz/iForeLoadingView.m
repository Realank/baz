//
//  iForeLoadingView.m
//  baz
//
//  Created by Realank on 15/12/18.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "iForeLoadingView.h"
#define VIEW_SIZE 110.0
#define ANIM_DURATION 0.8
#define ROUND_R 47.0
#define CIRCLE_ANGLE (1.5*M_PI)

typedef NS_ENUM(NSInteger, StepSection) {
    STEP_STARTING,
    STEP_LOADING,
    STEP_ENDING,
    STEP_END
};

@interface iForeLoadingView ()
@property (nonatomic,strong) UIView *loadingView;
@property (nonatomic,strong) CADisplayLink *link;
@property (nonatomic,strong) NSDate *startDate;
@property (nonatomic,strong) NSDate *endDate;
@property (nonatomic,assign) StepSection section;
@property (nonatomic,weak) CAShapeLayer* animateLayer;
@property (nonatomic,weak) UIImageView* iconView;
@end

@implementation iForeLoadingView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)updateLayout{
    switch (self.section) {
        case STEP_STARTING:{
            if ([[NSDate date] timeIntervalSinceDate:self.startDate] < ANIM_DURATION) {
                [self stepOne];
            }else{
                self.section = STEP_LOADING;
                [self.link invalidate];
                self.link = nil;
                [self stepTwo];
            }
        }break;
        case STEP_LOADING:{
            [self.link invalidate];
            self.link = nil;
        }break;
        case STEP_ENDING:{
            
            if ([[NSDate date] timeIntervalSinceDate:self.endDate] < ANIM_DURATION) {
                [self stepThree];
            }else{
                [self hideLoading];
            }
        }break;
        case STEP_END:{
            [self hideLoading];
        }break;
    }
}

- (void)dealloc{
    [self hideLoading];
}

- (void) showLoading{
    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_SIZE, VIEW_SIZE)];
    self.loadingView.backgroundColor = [UIColor clearColor];
    self.loadingView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addSubview:self.loadingView];
    
    CGPoint center = CGPointMake(VIEW_SIZE/2, VIEW_SIZE/2);
    
    CAShapeLayer *animateLayer = [CAShapeLayer layer];
    animateLayer.frame = self.loadingView.bounds;
    if (self.lineColor) {
        animateLayer.strokeColor = self.lineColor.CGColor;
    }else{
        animateLayer.strokeColor = [UIColor grayColor].CGColor;
    }
    
    animateLayer.fillColor = [UIColor clearColor].CGColor;
    animateLayer.lineWidth = 7;
    animateLayer.lineCap = kCALineCapRound;
    [self.loadingView.layer addSublayer:animateLayer];
    self.animateLayer = animateLayer;
    
    UIImageView* iconView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon"]];
    iconView.backgroundColor = [UIColor clearColor];
    iconView.alpha = 0;
    self.iconView = iconView;
    [UIView animateWithDuration:0.2 animations:^{
        iconView.alpha = 1;
    }];
    iconView.center = center;
    [self.loadingView addSubview:iconView];
    
    
    [self startAnimate];
}

- (void)startAnimate{
    // iphone每秒刷新60次
    // 屏幕刷新的时候就会触发
    self.section = STEP_STARTING;
    self.startDate = [NSDate date];
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLayout)];
    //    _link.frameInterval = 2;
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
}

- (void) endAnimate{
    self.section = STEP_ENDING;
    self.endDate = [NSDate date];
    if (_link) {
        [self.link invalidate];
        self.link = nil;
    }
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLayout)];
    //    _link.frameInterval = 2;
    [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}



- (void) hideLoading {
    self.section = STEP_END;
    if (self.link) {
        [self.link invalidate];
        self.link = nil;
    }
    
    if (self.animateLayer) {
        [self.animateLayer removeFromSuperlayer];
    }
    
    if (self && self.loadingView) {
        __weak __typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.iconView.alpha = 0;
        } completion:^(BOOL finished) {
            [weakSelf.loadingView removeFromSuperview];
            weakSelf.loadingView.hidden = YES;
            weakSelf.loadingView = nil;
            [weakSelf removeFromSuperview];
        }];
    }
    
    
}

- (void)stepOne{
    NSLog(@"step one");
    CGFloat percent = [[NSDate date] timeIntervalSinceDate:self.startDate] / ANIM_DURATION;
    if (percent > 1) {
        percent = 1;
    }
    CGFloat length = ROUND_R*2*M_PI*percent;//动画的行走的长度
    CGPoint center = CGPointMake(VIEW_SIZE/2, VIEW_SIZE/2);
    CGFloat straightLength = (ROUND_R * (2*M_PI-CIRCLE_ANGLE));//开始那段竖线的长度
    if (length < straightLength) {//竖直向下
        CGPoint startPoint = CGPointMake(center.x+straightLength, center.y+ROUND_R);
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path moveToPoint:startPoint];
        [path addLineToPoint:CGPointMake(startPoint.x-length, startPoint.y)];
        self.animateLayer.path = path.CGPath;
    }else if (length < ROUND_R*CIRCLE_ANGLE){
        CGPoint startPoint = CGPointMake(center.x+straightLength, center.y+ROUND_R);
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path moveToPoint:startPoint];
        [path addLineToPoint:CGPointMake(center.x, center.y+ROUND_R)];
        [path addArcWithCenter:center radius:ROUND_R startAngle:M_PI/2 endAngle:(length-straightLength)/ROUND_R + M_PI/2 clockwise:YES];
        self.animateLayer.path = path.CGPath;
    }else{
        straightLength -= length - ROUND_R*CIRCLE_ANGLE;
        length = ROUND_R*CIRCLE_ANGLE;
        CGPoint startPoint = CGPointMake(center.x+straightLength, center.y+ROUND_R);
        UIBezierPath* path = [UIBezierPath bezierPath];
        [path moveToPoint:startPoint];
        [path addLineToPoint:CGPointMake(center.x, center.y+ROUND_R)];
        [path addArcWithCenter:center radius:ROUND_R startAngle:M_PI/2 endAngle:(length-straightLength)/ROUND_R + M_PI/2 clockwise:YES];
        self.animateLayer.path = path.CGPath;
    }
    
}
- (void)stepTwo{
    NSLog(@"step two");
    CGPoint center = CGPointMake(VIEW_SIZE/2, VIEW_SIZE/2);
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:center radius:ROUND_R startAngle:M_PI/2 endAngle:CIRCLE_ANGLE + M_PI/2 clockwise:YES];
    
    self.animateLayer.path = path.CGPath;
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
    anim.keyPath = @"transform.rotation";
    anim.values = @[@(0),@(M_PI*2)];
    anim.repeatCount = MAXFLOAT;
    anim.duration = ANIM_DURATION;
    [self.animateLayer addAnimation:anim forKey:nil];
    
}
- (void)stepThree{
    NSLog(@"step three");
    CGPoint center = CGPointMake(VIEW_SIZE/2, VIEW_SIZE/2);
    [self.animateLayer removeAllAnimations];
    CGFloat percent = [[NSDate date] timeIntervalSinceDate:self.endDate] / ANIM_DURATION;
    if (percent > 1) {
        percent = 1;
    }
    NSTimeInterval loadingTime = [[NSDate date] timeIntervalSinceDate: self.startDate] - ANIM_DURATION;
    if (loadingTime < 0) {
        [self hideLoading];
        return;
    }
    CGFloat endAngle = loadingTime / ANIM_DURATION * M_PI * 2 + CIRCLE_ANGLE + M_PI/2;
    CGFloat length = CIRCLE_ANGLE * ROUND_R * (1 - percent);
    CGFloat startAngle = endAngle - length/ROUND_R;
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:center radius:ROUND_R startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.animateLayer.path = path.CGPath;
}



@end

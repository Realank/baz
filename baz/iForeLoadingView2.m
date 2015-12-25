//
//  iForeLoadingView2.m
//  baz
//
//  Created by Realank on 15/12/21.
//  Copyright © 2015年 Realank. All rights reserved.
//
#import "iForeLoadingView2.h"
#define VIEW_SIZE 110.0
#define ANIM_DURATION 2
#define ROUND_R 47.0
#define CIRCLE_MAX_ANGLE (1.9*M_PI)
#define CIRCLE_MIN_ANGLE (0.1*M_PI)

typedef NS_ENUM(NSInteger, StepSection) {
    STEP_INCREASE,
    STEP_DECREASE,
    STEP_ENDING,
    STEP_END
};

@interface iForeLoadingView2 ()
@property (nonatomic,weak) UIView *loadingView;
@property (nonatomic,weak) CADisplayLink *link;
@property (nonatomic,assign) CGFloat startAngle;
@property (nonatomic,assign) CGFloat endAngle;
@property (nonatomic,assign) StepSection section;
@property (nonatomic,weak) CAShapeLayer* animateLayer;
@property (nonatomic,weak) UIImageView* iconView;
@end

@implementation iForeLoadingView2

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc{
    
    if (self.link) {
        [self.link invalidate];
        self.link = nil;
    }
    
    if (self.animateLayer) {
        [self.animateLayer removeFromSuperlayer];
    }
    
    [self.loadingView removeFromSuperview];
    self.loadingView.hidden = YES;
    self.loadingView = nil;
    [self removeFromSuperview];
}

- (void)updateLayout{
    //    NSLog(@"refreshing");
    CGFloat angle = self.endAngle - self.startAngle;
    switch (self.section) {
        case STEP_INCREASE:{
            if (angle <= CIRCLE_MAX_ANGLE) {
                [self increaseCircle];
            }else{
                self.section = STEP_DECREASE;
            }
        }break;
        case STEP_DECREASE:{
            if (angle >= CIRCLE_MIN_ANGLE) {
                [self decreaseCircle];
            }else{
                self.section = STEP_INCREASE;
            }
        }break;
        case STEP_ENDING:{
            
            if (angle >= CIRCLE_MIN_ANGLE) {
                [self endingCircle];
            }else{
                [self hideLoading];
            }
        }break;
        case STEP_END:{
            [self hideLoading];
        }break;
    }
}


- (void) showLoading{
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_SIZE, VIEW_SIZE)];
    loadingView.backgroundColor = [UIColor clearColor];
    loadingView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [self addSubview:loadingView];
    self.loadingView = loadingView;
    
    CGPoint center = CGPointMake(VIEW_SIZE/2, VIEW_SIZE/2);
    
    CAShapeLayer *animateLayer = [CAShapeLayer layer];
    animateLayer.frame = self.loadingView.bounds;
    if (self.lineColor) {
        animateLayer.strokeColor = self.lineColor.CGColor;
    }else{
        animateLayer.strokeColor = [UIColor lightGrayColor].CGColor;
    }
    
    animateLayer.fillColor = [UIColor clearColor].CGColor;
    animateLayer.lineWidth = 3;
    animateLayer.lineCap = kCALineCapRound;
    [self.loadingView.layer addSublayer:animateLayer];
    self.animateLayer = animateLayer;
    
    UIImageView* iconView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon"]];
    iconView.backgroundColor = [UIColor clearColor];
    iconView.alpha = 0;
    self.iconView = iconView;
    [UIView animateWithDuration:0.2 animations:^{
        iconView.alpha = 0.5;
    }];
    iconView.center = center;
    [self.loadingView addSubview:iconView];
    
    
    [self startAnimate];
}

- (void)startAnimate{
    
    self.section = STEP_INCREASE;
    self.startAngle = 0;
    self.endAngle = CIRCLE_MIN_ANGLE;
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLayout)];
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    self.link = link;
    
}

- (void) endAnimate{
    self.section = STEP_ENDING;
    
}

- (void) hideLoading {
    if (self) {
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
}

- (void)increaseCircle{
    //    NSLog(@"increaseCircle");
    CGFloat angleStep = (CIRCLE_MAX_ANGLE-CIRCLE_MIN_ANGLE)/ANIM_DURATION/60;
    self.startAngle += angleStep;
    self.endAngle += 2*angleStep;
    CGPoint center = CGPointMake(VIEW_SIZE/2, VIEW_SIZE/2);
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:center radius:ROUND_R startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
    self.animateLayer.path = path.CGPath;
    
}
- (void)decreaseCircle{
    //    NSLog(@"decreaseCircle");
    CGFloat angleStep = (CIRCLE_MAX_ANGLE-CIRCLE_MIN_ANGLE)/ANIM_DURATION/60;
    self.startAngle += 2*angleStep;
    self.endAngle += angleStep;
    CGPoint center = CGPointMake(VIEW_SIZE/2, VIEW_SIZE/2);
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:center radius:ROUND_R startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
    self.animateLayer.path = path.CGPath;
    
}

- (void)endingCircle{
    //    NSLog(@"endingCircle");
    CGFloat angleStep = (CIRCLE_MAX_ANGLE-CIRCLE_MIN_ANGLE)/ANIM_DURATION/60;
    self.startAngle += 4*angleStep;
    self.endAngle += angleStep;
    CGPoint center = CGPointMake(VIEW_SIZE/2, VIEW_SIZE/2);
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:center radius:ROUND_R startAngle:self.startAngle endAngle:self.endAngle clockwise:YES];
    self.animateLayer.path = path.CGPath;
    
}


@end

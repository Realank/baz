//
//  ViewController.m
//  baz
//
//  Created by Realank on 15/12/18.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import "ViewController.h"
#import "iForeLoadingView.h"
#import "iForeLoadingView2.h"
#define ScreenWidth    [UIScreen mainScreen].bounds.size.width
#define ScreenHeigh    [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property (nonatomic,weak) iForeLoadingView *loadingView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    static BOOL animate = NO;
    if (!animate) {
        iForeLoadingView *loading = [[iForeLoadingView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
        loading.center = CGPointMake(ScreenWidth/2, ScreenHeigh/2-64);
        [self.view addSubview:loading];
        loading.lineColor = [UIColor lightGrayColor];
        
        self.loadingView = loading;
        [self.loadingView showLoading];
    }else {
        [self.loadingView endAnimate];
    }
    animate = !animate;
    
    
}

@end

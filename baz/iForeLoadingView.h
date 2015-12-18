//
//  iForeLoadingView.h
//  baz
//
//  Created by Realank on 15/12/18.
//  Copyright © 2015年 Realank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iForeLoadingView : UIView

@property (nonatomic, strong)UIColor *lineColor;
- (void) showLoading;
- (void) endAnimate;
@end

//
//  OONode.m
//  PathFinding
//
//  Created by ztc on 16/11/22.
//  Copyright © 2016年 oosnail. All rights reserved.
//

#import "OONode.h"

@implementation OONode

- (id)init{
    self = [super  init];
    if(self){
        [self setDefault];
    }
    return self;
}

- (void)setDefault{
    
}

//不同的状态
- (void)setViewTpye:(OONodeViewType)viewTpye{
    _viewTpye = viewTpye;
    switch (viewTpye) {
        case OONodeViewTypeNone:
            self.backgroundColor = [UIColor whiteColor];
            break;
        case OONodeViewTypeStart:
            self.backgroundColor = [UIColor blueColor];
            break;
        case OONodeViewTypeEnd:
            self.backgroundColor = [UIColor greenColor];
            break;
        case OONodeViewTypeSearched:
            self.backgroundColor = [UIColor yellowColor];
            break;
        case OONodeViewTypeNeighbor:
            self.backgroundColor = [UIColor grayColor];
            break;
        default:
            self.backgroundColor = [UIColor whiteColor];
            break;
    }
}

- (void)setViewState:(OONodeViewState)viewState{
    _viewState = viewState;
    switch (viewState) {
        case OONodeViewStateNone:
            [self.layer removeAllAnimations];
            break;
        case OONodeViewStateChoose:
            [self.layer addAnimation:[self opacityForever_Animation:0.5] forKey:nil];            break;
        default:
            break;
    }
}

//闪烁
- (CABasicAnimation *)opacityForever_Animation:( float )time
{
    
    CABasicAnimation *animation = [ CABasicAnimation animationWithKeyPath : @"opacity" ]; // 必须写 opacity 才行。
    
    animation. fromValue = [ NSNumber numberWithFloat : 1.0f ];
    
    animation. toValue = [ NSNumber numberWithFloat : 0.0f ]; // 这是透明度。
    
    animation. autoreverses = YES ;
    
    animation. duration = time;
    
    animation. repeatCount = MAXFLOAT ;
    
    animation. removedOnCompletion = NO ;
    
    animation. fillMode = kCAFillModeForwards ;
    
    animation.timingFunction =[CAMediaTimingFunction functionWithName : kCAMediaTimingFunctionEaseIn ]; /// 没有的话是均匀的动画。
    
    return animation;
    
}

@end


//
//  NSTimer+OOAddition.m
//  quiridor
//
//  Created by ztc on 16/11/18.
//  Copyright © 2016年 ZTC. All rights reserved.
//

#import "NSTimer+OOAddition.h"

@implementation NSTimer(OOAddition)
-(void)pauseTimer{
    
    if (![self isValid]) {
        return ;
    }
    
    [self setFireDate:[NSDate distantFuture]];
}


-(void)resumeTimer{
    
    if (![self isValid]) {
        return ;
    }
    [self setFireDate:[NSDate date]];
    
}

@end

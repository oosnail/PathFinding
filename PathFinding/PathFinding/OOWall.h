//
//  OOWall.h
//  PathFinding
//
//  Created by ztc on 16/11/22.
//  Copyright © 2016年 oosnail. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger,OOWallType ){
    OOWallTypehorizontal,//啥都是不
    OOWallTypeVertical,//啥都是不
};

typedef NS_ENUM(NSUInteger,OOWallState ){
    OOWallStateNone,//啥都是不
    OOWallStateChoose,//选中状态（还不是一堵墙）
    OOWallStatetureWall,//是一堵墙
};

@interface OOWall : UIView
@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, assign) OOWallType wallType;
@property (nonatomic, assign) OOWallState wallState;

@end

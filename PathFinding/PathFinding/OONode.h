//
//  OONode.h
//  PathFinding
//
//  Created by ztc on 16/11/22.
//  Copyright © 2016年 oosnail. All rights reserved.
//

#import <UIKit/UIKit.h>
//OONode的状态
typedef NS_ENUM(NSUInteger,OONodeViewType ) {
    OONodeViewTypeNone,//啥都是不
    OONodeViewTypeStart,//起始点
    OONodeViewTypeEnd,//结束点
    OONodeViewTypeSearched,//搜索过的点
    OONodeViewTypeNeighbor//即将搜索点（搜索过的点周边）
};

typedef NS_ENUM(NSUInteger,OONodeViewState ){
    OONodeViewStateNone,//啥都是不
    OONodeViewStateChoose,//啥都是不
};

@interface OONode : UIView
@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, weak) OONode *parent;
@property (nonatomic, assign) int distance;
@property (nonatomic, assign) OONodeViewType viewTpye;
@property (nonatomic, assign) OONodeViewState viewState;

@end

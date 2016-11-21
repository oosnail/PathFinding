//
//  ViewController.m
//  quiridor
//
//  Created by ztc on 16/11/17.
//  Copyright © 2016年 ZTC. All rights reserved.
//

/*
 1.遍历点 searchArray
 2.通过遍历点 获取可选择的下一步点 nextStepArray（此处可优化）
 3.从nextStepArray获取离终点最近点
 4.判断最近的点是不是终点 如果是 return
 5.如果不是将最近的点加入searchArray
 */

#import "ViewController.h"
#import "NSTimer+OOAddition.h"

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

typedef NS_ENUM(NSUInteger,OOWallType ){
    OOWallTypehorizontal,//啥都是不
    OOWallTypeVertical,//啥都是不
};

typedef NS_ENUM(NSUInteger,OOWallState ){
    OOWallStateNone,//啥都是不
    OOWallStateChoose,//选中状态（还不是一堵墙）
    OOWallStatetureWall,//是一堵墙
};



@interface OONode : UIView
@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, weak) OONode *parent;
@property (nonatomic, assign) int distance;
@property (nonatomic, assign) OONodeViewType viewTpye;
@property (nonatomic, assign) OONodeViewState viewState;

@end

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


@interface OOWall : UIView
@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, assign) OOWallType wallType;
@property (nonatomic, assign) OOWallState wallState;


@end
@implementation OOWall
- (void)setWallState:(OOWallState)wallState{
    _wallState = wallState;
    switch (wallState) {
        case OOWallStateNone:
            self.backgroundColor = [UIColor clearColor];
            break;
        case OOWallStateChoose:
            self.backgroundColor = [UIColor yellowColor];
            break;
        case OOWallStatetureWall:
            self.backgroundColor = [UIColor purpleColor];
            break;
        default:
            self.backgroundColor = [UIColor clearColor];
            break;
    }
}
@end



#define MaxX  10
#define MaxY  10
#define lineWidth  5.f
#define _width  ((kScreenWidth - lineWidth)/MaxX -lineWidth)
#define _height ((kScreenWidth - lineWidth)/MaxY -lineWidth)


#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
//起始点
@property (nonatomic,strong) NSArray* starPoint;
//结束点
@property (nonatomic,strong) NSArray* endPoint;

@property (nonatomic,strong) NSMutableArray<OONode *>* searchedArray;
//searchArray 附近的地址
@property (nonatomic,strong) NSMutableArray<OONode*>* neighborArray;
//所有的节点
@property (nonatomic,strong) NSMutableArray<OONode*>* allNodeArray;

//墙的地址
@property (nonatomic,strong) NSDictionary* wallViewDic;
//墙的地址
@property (nonatomic,strong) NSMutableArray<NSArray*>* wallArray;
//是否已经找到终点
@property (nonatomic, assign) BOOL findendPoint;

//最近的点
@property (nonatomic,strong) OONode* nearestPoint;

//定时器
@property (nonatomic,strong)NSTimer *time;
//开始按钮
@property (nonatomic,strong)UIButton *starButton;
//暂停按钮
@property (nonatomic,strong)UIButton *pauseButton;
//清除所有的墙
@property (nonatomic,strong)UIButton *clearWallButton;

//开始点
@property (nonatomic,strong)OONode *startNodeView;
//结束点
@property (nonatomic,strong)OONode *endNodeView;
//选择的点
@property (nonatomic,strong)OONode *chooseNodeView;
//choosewall
@property (nonatomic,strong) OOWall *chooseWall;

//截图
@property(nonatomic,strong) UIView * snapshot;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib
    [self setDefaultValue];
    [self UIInit];
}

- (void)setDefaultValue{
    _starPoint = @[@0,@0];
    _endPoint = @[@(MaxX-1),@(MaxY-1)];
    
    _searchedArray = [NSMutableArray array];
    
    _neighborArray = [NSMutableArray array];
    
    _allNodeArray = [NSMutableArray array];
    
    _wallArray = [NSMutableArray array];
    
    NSMutableArray *horizontal = [NSMutableArray array];
    NSMutableArray *vertical = [NSMutableArray array];
    _wallViewDic = @{@"horizontal" : horizontal,@"vertical":vertical};
    _endPoint = @[@0,@9];
    //添加墙
    {
        NSArray *wall = @[@[@(0),@(5.5)],@[@(1),@(5.5)],@[@(0.5),@(9)]];
        [_wallArray addObjectsFromArray:wall];
    }
    
    //[self resetDodeStatus];
    
}

- (void)UIInit{
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(10,70, 100, 40)];
    [button setTitle:@"开始寻路" forState:UIControlStateNormal];
    [button setTitle:@"结束寻路" forState:UIControlStateSelected];
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(button1Click:) forControlEvents:UIControlEventTouchUpInside];
    _starButton = button;
    
    
    UIButton *button2 = [[UIButton alloc]initWithFrame:CGRectMake(130,70, 100, 40)];
    [button2 setTitle:@"停止寻路" forState:UIControlStateNormal];
    [button2 setTitle:@"继续寻路" forState:UIControlStateSelected];
    button2.backgroundColor = [UIColor redColor];
    [self.view addSubview:button2];
    [button2 addTarget:self action:@selector(button2Click:) forControlEvents:UIControlEventTouchUpInside];
    _pauseButton = button2;
    
    UIButton *button3 = [[UIButton alloc]initWithFrame:CGRectMake(250,70, 100, 40)];
    [button3 setTitle:@"移除墙" forState:UIControlStateNormal];
    button3.backgroundColor = [UIColor redColor];
    [self.view addSubview:button3];
    [button3 addTarget:self action:@selector(button3Click:) forControlEvents:UIControlEventTouchUpInside];
    _clearWallButton = button3;
    
    
    UIView *chessboard = [[UIView alloc]init];
    chessboard.backgroundColor = [UIColor redColor];
    chessboard.bounds = CGRectMake(0, 0, kScreenWidth, kScreenWidth);
    chessboard.center = self.view.center;
    [self.view addSubview:chessboard];
    

    for(int x =0;x<MaxX;x++){
        for(int y =0;y<MaxY;y++){
            OONode * nodeView = [[OONode alloc]init];
            nodeView.bounds = CGRectMake(0, 0, _width, _height);
            nodeView.center = CGPointMake((x+1)*(_width+lineWidth)-_width/2,kScreenWidth- (y+1)*(_height+lineWidth)+_height/2);
            nodeView.x = x;
            nodeView.y = y;
            [chessboard addSubview:nodeView];
            [self setPointDistance:nodeView];
            [_allNodeArray addObject:nodeView];
            if(x == [_starPoint[0]intValue] && y == [_starPoint[1]intValue] ){
                _startNodeView = nodeView;
                nodeView.viewTpye = OONodeViewTypeStart;
                _nearestPoint = nodeView;
                [_searchedArray addObject:_nearestPoint];
                [_neighborArray addObject:_nearestPoint];
            }else if(x == [_endPoint[0]intValue]  && y == [_endPoint[1]intValue] ){
                nodeView.viewTpye = OONodeViewTypeEnd;
                _endNodeView = nodeView;
            }else{
                nodeView.viewTpye = OONodeViewTypeNone;
            }
            //添加手势
            //添加手势
            {
                UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
                [nodeView addGestureRecognizer:ges];
            }
            //设置wallView
            
             //TOP
             {
                 if(y < MaxY-1){
                 OOWall* wallView = [[OOWall alloc]init];
                 wallView.frame = CGRectMake((x+1)*(_width+lineWidth)-_width, kScreenWidth- (y+1)*(_height+lineWidth)-lineWidth, _width, lineWidth);
                wallView.wallState = OOWallStateNone;
                //如果是墙
                 if([_wallArray containsObject: @[@(nodeView.x),@(nodeView.y+0.5)]]){
                     wallView.wallState = OOWallStatetureWall;
                 }
                wallView.wallType = OOWallTypehorizontal;
                 wallView.x =nodeView.x;
                 wallView.y =nodeView.y+ 0.5;
                 [chessboard addSubview:wallView];
                [_wallViewDic[@"horizontal"] addObject:wallView];
             }
             }
             //right
                 {
                 if(x < MaxX-1){
                 OOWall* wallView = [[OOWall alloc]init];
                 wallView.frame = CGRectMake((x+1)*(_width+lineWidth),kScreenWidth- (y+1)*(_height+lineWidth), lineWidth,_width);
                     wallView.wallState = OOWallStateNone;
                     //如果是墙
                 if([_wallArray containsObject: @[@(nodeView.x+0.5),@(nodeView.y)]]){
                     wallView.wallState = OOWallStatetureWall;
                 }
                wallView.wallType = OOWallTypeVertical;
                wallView.x =nodeView.x+ 0.5;
                wallView.y =nodeView.y;
                 [chessboard addSubview:wallView];
                 [_wallViewDic[@"vertical"] addObject:wallView];
             }
             
             }
            
        }
    }
    
    
    float scale = 1;
    //添加选择墙的模块
    UIView *horizontalWall = [[UIView alloc]initWithFrame:CGRectMake(10,CGRectGetMaxY(chessboard.frame)+30, _width*scale, lineWidth*scale)];
    horizontalWall.backgroundColor = [UIColor purpleColor];
    horizontalWall.tag = 1;
    [self.view addSubview:horizontalWall];

    UIView *verticalWall = [[UIView alloc]initWithFrame:CGRectMake(130,CGRectGetMaxY(chessboard.frame)+30, lineWidth*scale, _height*scale)];
    verticalWall.backgroundColor = [UIColor purpleColor];
    verticalWall.tag = 2;
    [self.view addSubview:verticalWall];
    
    //长按手势
    UILongPressGestureRecognizer* longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    longPress.minimumPressDuration = 0;
    [horizontalWall addGestureRecognizer:longPress];
    
    UILongPressGestureRecognizer* longPress1=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    longPress1.minimumPressDuration = 0;
    [verticalWall addGestureRecognizer:longPress1];
}

-(void)longPress:(UILongPressGestureRecognizer *)longPress{
    //按住的时候回调用一次，松开的时候还会再调用一次
    UIView * invView = longPress.view;
    CGPoint location = [longPress locationInView:self.view];

    if(!_snapshot){
        _snapshot = [self customSnapshoFromView:invView];
        [invView.superview addSubview:_snapshot];
        if(_snapshot.tag == 1){
            _snapshot.bounds = CGRectMake(0, 0, _width, lineWidth);
        }else{
            _snapshot.bounds = CGRectMake(0, 0, lineWidth, _height);
        }
        _snapshot.center = location;
    }
    switch (longPress.state) {
        case UIGestureRecognizerStatePossible: {
//            [self setAllViewType:INVViewtatusNone];
            break;
        }
        case UIGestureRecognizerStateBegan: {
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self moviesnapshot:location];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            [self endmoviesnapshot:location];
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            [_snapshot removeFromSuperview];
            _snapshot = nil;
            break;
        }
        case UIGestureRecognizerStateFailed: {
            [_snapshot removeFromSuperview];
            _snapshot = nil;
            break;
        }
    }
}

- (void)moviesnapshot:(CGPoint)loc{
    float chessviewX = kScreenHeight/2.0 - kScreenWidth/2.0;
    _snapshot.center = loc;
    if(_snapshot.tag == 1){//横着
        int x = round((loc.x - (lineWidth)/2 - _width/2)*MaxX/(kScreenWidth - lineWidth));
        int y =MaxY-1 - round((loc.y- chessviewX - (lineWidth)/2)*MaxY/(kScreenWidth - lineWidth));
        if(x>=0 && x< MaxX && y >= 0 && y < MaxY-1 ){
            NSLog(@"horizontal：横着：%d 竖着：%d",x,y);
            OOWall *view = _wallViewDic[@"horizontal"][x*(MaxY-1)+y];
            if(view.wallState != OOWallStatetureWall){
                _chooseWall.wallState = OOWallStateNone;
                view.wallState = OOWallStateChoose;
                _chooseWall = view;
            }
        }
    }else{//竖着
        int x = round((loc.x - (lineWidth)/2 )*MaxX/(kScreenWidth - lineWidth))-1;
        int y =MaxY-1 - round((loc.y- chessviewX - (lineWidth)/2- _width/2)*MaxY/(kScreenWidth - lineWidth));
        if(x>= 0 && x< MaxX-1 && y >= 0 && y < MaxY ){
            NSLog(@"vertical：横着：%d 竖着：%d",x,y);
            OOWall *view = _wallViewDic[@"vertical"][x*(MaxY)+y];
            if(view.wallState != OOWallStatetureWall){
                _chooseWall.wallState = OOWallStateNone;
                view.wallState = OOWallStateChoose;
                _chooseWall = view;
            }
        }
    }
}

//移动结束
- (void)endmoviesnapshot:(CGPoint)loc{
    //获取loc的位置
    //1是横 2是竖
    if(_chooseWall){
        _chooseWall.wallState = OOWallStatetureWall;
        [_wallArray addObject:@[@(_chooseWall.x),@(_chooseWall.y)]];
        _chooseWall = nil;
    }
    [_snapshot removeFromSuperview];
    _snapshot = nil;
    
}


//开始 and 结束
- (void)button1Click:(UIButton*)button{
    if(!button.selected){
        _pauseButton.selected = NO;
        _clearWallButton.enabled = NO;
        [self beginSearch];
    }else{
        _clearWallButton.enabled = YES;
        [self endSearch];
        [self resetDodeStatus];
    }
    button.selected = !button.selected;
}

//继续 and 暂停
- (void)button2Click:(UIButton*)button{
    if(!button.selected){
        [self stopSearch];
    }else{
        [self againSearch];
    }
    
    button.selected = !button.selected;
}

- (void)button3Click:(UIButton*)button3Click{
    for (OOWall *wall in self.wallViewDic[@"horizontal"]) {
        wall.wallState = OOWallStateNone;
    }
    for (OOWall *wall in self.wallViewDic[@"vertical"]) {
        wall.wallState = OOWallStateNone;
    }
    [_wallArray removeAllObjects];
}

//开始搜索
- (void)beginSearch{
    [self resetDodeStatus];
    if(!_time){
        NSTimer *time = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(searchPath) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:time forMode:NSDefaultRunLoopMode];
        _time =time;
    }
}

//暂停寻路
- (void)stopSearch{
    if(_time){
        [_time pauseTimer];
    }
}

//恢复寻路
- (void)againSearch{
    if(_time){
        [_time resumeTimer];
    }
}

//寻路
- (void)searchPath{
    NSMutableArray*_neighboar = [self neighboarWithPoint:_nearestPoint];
    [_neighborArray removeObject:_nearestPoint];
    [_neighborArray addObjectsFromArray:_neighboar];
    [_searchedArray addObject:_nearestPoint];
    if(_nearestPoint.viewTpye != OONodeViewTypeStart && _nearestPoint.viewTpye != OONodeViewTypeEnd){
        _nearestPoint.viewTpye =OONodeViewTypeSearched;
    }
    [_nearestPoint layoutIfNeeded];
    //如果_neighborArray 为空 表示所有搜索都搜索到了。。
    if(_neighborArray.count==0){
        _findendPoint = NO;
        [self endSearch];
        return;
    }
    _nearestPoint = [self getNearestPointInNeighboar];
    if(_nearestPoint.distance == 0){
        _findendPoint = YES;
        [self endSearch];
        return;
    }
}

//结束寻路
- (void)endSearch{
    [_time invalidate];
    _time = nil;
    if(_findendPoint){
        //获得最优解
        OONode *parent = _nearestPoint;
        NSMutableArray * _bestPath = [NSMutableArray array];
        [_bestPath insertObject:parent atIndex:0];
        while (parent) {
            parent = parent.parent;
            if(parent){
                NSLog(@"x:%d,y:%d \n",parent.x,parent.y);
                [_bestPath insertObject:parent atIndex:0];
            }
        }
    }else{
        NSLog(@"sorry I can't find endPoint");
    }
    
}

- (void)resetDodeStatus{
    //重新改变
    _nearestPoint = nil;
    for(OONode *nodeView in _allNodeArray){
        nodeView.parent = nil;
        int x = nodeView.x;
        int y = nodeView.y;
        if(x == [_starPoint[0]intValue] && y == [_starPoint[1]intValue] ){
            nodeView.viewTpye = OONodeViewTypeStart;
            _nearestPoint = nodeView;
        }else if(x == [_endPoint[0]intValue]  && y == [_endPoint[1]intValue] ){
            nodeView.viewTpye = OONodeViewTypeEnd;
        }else{
            nodeView.viewTpye = OONodeViewTypeNone;
        }
    }
    [_searchedArray removeAllObjects];
    [_neighborArray removeAllObjects];
    
    [_searchedArray addObject:_nearestPoint];
    [_neighborArray addObject:_nearestPoint];
    
    
}

//获取某个点附近的点
- (NSMutableArray*)neighboarWithPoint:(OONode*)point{
    NSMutableArray *_neighboar = [NSMutableArray array];
    for (int i=0;i<4;i++){
        //上下左右
        OONode* _neiboarpoint;
        int _x;
        int _y;
        if(i == 0){//上
            if(point.y == MaxY-1){
                continue;
            }
            //判断是否有墙
            NSArray *wall = @[@(point.x),@(point.y+0.5)];
            if([_wallArray containsObject:wall]){
                continue;
            }
            
            
            _x = point.x;
            _y = point.y+1;
        }else if(i == 1){//下
            if(point.y == 0){
                continue;
            }
            NSArray *wall = @[@(point.x),@(point.y-0.5)];
            if([_wallArray containsObject:wall]){
                continue;
            }
            
            _x = point.x;
            _y = point.y-1;
        }else if(i == 2){//左
            if(point.x == 0){
                continue;
            }
            NSArray *wall = @[@(point.x-0.5),@(point.y)];
            if([_wallArray containsObject:wall]){
                continue;
            }
            _x = point.x-1;
            _y = point.y;
        }else if(i == 3){//右
            NSArray *wall = @[@(point.x+0.5),@(point.y)];
            if([_wallArray containsObject:wall]){
                continue;
            }
            if(point.x == MaxX-1){
                continue;
            }
            _x = point.x+1;
            _y = point.y;
        }
        //通过数组获取位置
        _neiboarpoint = _allNodeArray[_x*MaxY + _y];
        if([_neighboar containsObject: _neiboarpoint] || [_searchedArray containsObject: _neiboarpoint]){
            continue;
        }
        _neiboarpoint.parent = point;
        if(_neiboarpoint.viewTpye != OONodeViewTypeEnd && _neiboarpoint.viewTpye != OONodeViewTypeStart){
            _neiboarpoint.viewTpye = OONodeViewTypeNeighbor;
        }
        [_neighboar addObject:_neiboarpoint];
    }
    return _neighboar;
}

//给point计算位置
- (void)setPointDistance:(OONode*)point{
    point.distance = abs([_endPoint[0] intValue] - point.x)+abs([_endPoint[1] intValue]  - point.y);
}

- (void)updatePointDistance{
    for(OONode*node in _allNodeArray){
        [self setPointDistance:node];
    }
}

//获取附近的点离终点最近
- (OONode*)getNearestPointInNeighboar{
    OONode *nearlistPoint;
    for (OONode*point in _neighborArray) {
        if(!nearlistPoint){
            nearlistPoint = point;
            continue;
        }
        if(point.distance < nearlistPoint.distance){
            nearlistPoint = point;
        }
    }
    return nearlistPoint;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tap:(UIGestureRecognizer*)gesture{
    OONode *node = (OONode*)gesture.view;
    //如果之前有选择的情况
    if(_chooseNodeView){
        if(_chooseNodeView == node){
            return;
        }
        _chooseNodeView.viewState  = OONodeViewStateNone;
        if(node.viewTpye == OONodeViewTypeStart){
            node.viewState = OONodeViewStateChoose;
            _chooseNodeView = node;
        }else if(node.viewTpye == OONodeViewTypeEnd){
            node.viewState = OONodeViewStateChoose;
            _chooseNodeView = node;
        }else{
            //设置起始点 或者 结束点
            node.viewTpye = _chooseNodeView.viewTpye;
            if(node.viewTpye == OONodeViewTypeStart){
                _startNodeView = node;
                _starPoint = @[@(node.x),@(node.y)];
            }else if(node.viewTpye == OONodeViewTypeEnd){
                _endPoint = @[@(node.x),@(node.y)];
                _endNodeView = node;
            }
            //ggxc
            [self updatePointDistance];
            _chooseNodeView.viewTpye = OONodeViewTypeNone;
            _chooseNodeView = nil;
        }
    }else{
        //如果之前没有
        if(node.viewTpye == OONodeViewTypeStart){
            node.viewState = OONodeViewStateChoose;
            _chooseNodeView = node;
        }else if(node.viewTpye == OONodeViewTypeEnd){
            node.viewState = OONodeViewStateChoose;
            _chooseNodeView = node;
        }
    }
}

//复制图片
- (UIImageView *)customSnapshoFromView:(UIView *)inputView {
    // 用cell的图层生成UIImage，方便一会显示
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // 自定义这个快照的样子（下面的一些参数可以自己随意设置）
    UIImageView * snapview = [[UIImageView alloc] initWithImage:image];
    snapview.layer.masksToBounds = NO;
    snapview.layer.cornerRadius = 0.0;
    snapview.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapview.layer.shadowRadius = 5.0;
    snapview.layer.shadowOpacity = 0.4;
    snapview.alpha = 0.8;
    snapview.tag = inputView.tag;
    return snapview;
}

@end

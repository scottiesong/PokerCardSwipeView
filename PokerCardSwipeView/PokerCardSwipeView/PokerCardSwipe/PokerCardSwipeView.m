//
//  PokerCardSwipeView.m
//  PokerCardSwipeView
//
//  Created by pengyuesong on 2023/9/28.
//

#import "PokerCardSwipeView.h"
#import "Constants.h"

#define DEBUG_LOG 0

@interface PokerCardSwipeView ()

// view总共的数量
@property (nonatomic, assign) NSInteger totalCardCount;
// 当前的下标
@property (nonatomic, assign) NSInteger nowIndex;
// 卡片的宽度
@property (nonatomic, assign) CGFloat cardWidth;
// 卡片的高度
@property (nonatomic, assign) CGFloat cardHeight;
// 是否是第一次执行
@property (nonatomic, assign) BOOL isFirstLayoutSub;
// 所有card的集合
@property (nonatomic, strong) NSMutableArray *cardArray;
// 左侧card集合 不含正中card
@property (nonatomic, strong) NSMutableArray *cardLeftArray;
// 右侧card集合 不含正中card
@property (nonatomic, strong) NSMutableArray *cardRigthArray;
// 正中card
@property (nonatomic, strong) PokerCard *middleCard;
// 拖动开始时
@property (nonatomic, assign) CGPoint oldCenter;

@end

@implementation PokerCardSwipeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initSelf];
    }
    return self;
}

// 进行一些自身的初始化和设置
- (void)initSelf {
    self.clipsToBounds = YES;
    self.cardArray = [[NSMutableArray alloc] init];
    self.cardWidth = .0f;
    self.cardHeight = .0f;
}

- (void)setItemSize:(CGSize)itemSize {
    _itemSize = itemSize;
    self.cardWidth = itemSize.width;
    self.cardHeight = itemSize.height;
}

// 布局subview的方法
- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.isFirstLayoutSub) {
        self.isFirstLayoutSub = YES;
        self.cardWidth = (self.cardWidth <= .0f) ? self.bounds.size.width * .5 : self.cardWidth;
        self.cardHeight = (self.cardHeight <= .0f) ? self.bounds.size.height * .7 : self.cardHeight;
        [self reloadData];
    }
}

// 重新加载数据方法，会再首次执行layoutSubviews的时候调用
- (void)reloadData {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(CardSwipeGetCard:withIndex:)] || ![self.delegate respondsToSelector:@selector(CardSwipeGetTotalCount:)]) {
        return;
    }
    self.totalCardCount = (int)[self.delegate CardSwipeGetTotalCount:self];
    
//    [self drawCard:self.totalNum middleIndex:self.totalNum - 1];
    [self drawCard:self.totalCardCount middleIndex:0];
//    [self drawCard:self.totalNum middleIndex:1];
    
    [self printLeftArray];
    [self printRightArray];
}

#pragma mark - Draw Cards
// 画卡片
- (void)drawCard:(NSInteger)totalCount middleIndex:(NSInteger)middleIndex {
    if (totalCount <= 0) return;
    if (middleIndex >= totalCount || middleIndex < 0) return;
    
    if (middleIndex == 0) {
        // 初始化全部向右排列
        [self drawRight:totalCount middleIndex:middleIndex];
    } else if (middleIndex == (totalCount - 1)) {
        // 初始化全部向左排列
        [self drawLeft:totalCount middleIndex:middleIndex isDrawMiddle:YES];
    } else {
        // 左右都有
        [self drawLeft:totalCount middleIndex:middleIndex isDrawMiddle:NO];
        [self drawRight:totalCount middleIndex:middleIndex];
        [self removeMiddleCardFromSubArray:middleIndex];
    }
    
    self.nowIndex = (int)middleIndex;
    
    [self removeMiddleCardFromSubArray:self.nowIndex];
}

// 画左侧卡片列
- (void)drawLeft:(NSInteger)totalCount middleIndex:(NSInteger)middleIndex isDrawMiddle:(BOOL)isDrawMiddle {
    CGFloat degree = .0f;
    CGAffineTransform rotate = CGAffineTransformIdentity;
    PokerCard *precard = nil;
    
    if (isDrawMiddle) {
        degree = DEGREE_ROTATE;
    }
    precard = nil;
    for (int i = (int)(middleIndex); i >= 0; i--) {
        if (!isDrawMiddle && (i == middleIndex)) {
            continue;
        }
        PokerCard *card = [self.delegate CardSwipeGetCard:self withIndex:i];
        [self addSubview:card];
        card.frame = CGRectMake((CGRectGetWidth(self.frame) - self.cardWidth) / 2 - (middleIndex - i) * INTER_ITEM_SPACING_MIN, TOP_MARGTIN + (middleIndex - i) * INTER_LINE_SPACING_MIN, self.cardWidth, self.cardHeight - TOP_MARGTIN);
        [self Blur:card];
        
        degree -= DEGREE_ROTATE;
        rotate = CGAffineTransformMakeRotation(degree / 180 * M_PI);
        card.transform = rotate;
        CGAffineTransform transform = CGAffineTransformScale(rotate, SCALE_HORIZONTAL, 1 - SCALE_VALUE * (middleIndex - i));
        card.transform = transform;
        
        if (precard != nil) {
            [self sendSubviewToBack:card];
        } else {
            precard = card;
        }
        
        [self.cardArray insertObject:card atIndex:0];
        if (i <= self.totalCardCount - 1) {
            [self.cardLeftArray insertObject:card atIndex:0];
        }
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cardPanHandle:)];
        [card addGestureRecognizer:pan];
    }
}

// 画右侧卡片列
- (void)drawRight:(NSInteger)totalCount middleIndex:(NSInteger)middleIndex {
    CGFloat degree = .0f;
    CGAffineTransform rotate = CGAffineTransformIdentity;
    PokerCard *precard = nil;
    
    degree = .0f;
    precard = nil;
    for (int i = (int)middleIndex; i < totalCount; i++) {
        PokerCard *card = [self.delegate CardSwipeGetCard:self withIndex:i];
        [self addSubview:card];
        card.frame = CGRectMake((CGRectGetWidth(self.frame) - self.cardWidth) / 2 + (i - middleIndex) * INTER_ITEM_SPACING_MIN, TOP_MARGTIN + (i - middleIndex) * INTER_LINE_SPACING_MIN, self.cardWidth, self.cardHeight - TOP_MARGTIN);
        [self Blur:card];
        
        if (precard != nil) {
            [self sendSubviewToBack:card];
        } else {
            precard = card;
        }
        degree = DEGREE_ROTATE * (i - middleIndex);
        rotate = CGAffineTransformMakeRotation(degree / 180 * M_PI);
        CGAffineTransform transform = CGAffineTransformScale(rotate, SCALE_HORIZONTAL, 1 - SCALE_VALUE * (i - middleIndex));
        if (i == 0) {
            transform = CGAffineTransformScale(rotate, SCALE_HORIZONTAL, 1);
        }
        card.transform = transform;
        
        [self.cardArray addObject:card];
        [self.cardRigthArray addObject:card];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cardPanHandle:)];
        [card addGestureRecognizer:pan];
    }
}

#pragma mark - Move Cards
// 卡片向左移动
- (void)moveCardToLeft:(NSInteger)index {
    if (index >= self.cardArray.count) return;
    if (index < self.cardLeftArray.count) {
        if (index >= self.cardLeftArray.count) return;
        PokerCard *card = (PokerCard*)self.cardLeftArray[index];
        __block CGFloat degree = .0f;
        __block CGAffineTransform rotate = CGAffineTransformIdentity;
        __block NSInteger length = self.cardLeftArray.count;
        
        [UIView animateWithDuration:.25 animations:^{
            degree = -DEGREE_ROTATE * (length - index);
            rotate = CGAffineTransformMakeRotation(degree / 180 * M_PI);
            card.transform = rotate;
            card.frame = CGRectMake((CGRectGetWidth(self.frame) - self.cardWidth) / 2 - (length - index) * INTER_ITEM_SPACING_MIN, TOP_MARGTIN + (length - index) * INTER_LINE_SPACING_MIN, self.cardWidth, self.cardHeight - TOP_MARGTIN);
            [self Blur:card];
        } completion:^(BOOL finished) {
            CGAffineTransform transform = CGAffineTransformScale(rotate, SCALE_HORIZONTAL, 1 - SCALE_VALUE * (length - index));
            card.transform = transform;
        }];
    } else {
        if ((index - self.cardLeftArray.count) >= self.cardRigthArray.count) return;
        __block NSInteger currentIndex = index - self.cardLeftArray.count;
        PokerCard *card = (PokerCard*)self.cardRigthArray[currentIndex];
        __block CGFloat degree = .0f;
        __block CGAffineTransform rotate = CGAffineTransformIdentity;
        
        [UIView animateWithDuration:.25 animations:^{
            degree = DEGREE_ROTATE * (currentIndex);
            rotate = CGAffineTransformMakeRotation(degree / 180 * M_PI);
            card.transform = rotate;
            card.frame = CGRectMake((CGRectGetWidth(self.frame) - self.cardWidth) / 2 + (currentIndex) * INTER_ITEM_SPACING_MIN, TOP_MARGTIN + (currentIndex) * INTER_LINE_SPACING_MIN, self.cardWidth, self.cardHeight - TOP_MARGTIN);
            [self Blur:card];
        } completion:^(BOOL finished) {
            CGAffineTransform transform = CGAffineTransformScale(rotate, SCALE_HORIZONTAL, 1 - SCALE_VALUE * (currentIndex));
            card.transform = transform;
            
            if (currentIndex == 0) {
                [self bringSubviewToFront:card];
                [self cancelBlur:card];
            }
        }];
    }
}

// 卡片向右移动
- (void)moveCardToRight:(NSInteger)index {
    if (index >= self.cardArray.count) return;
    if (index < self.cardLeftArray.count) {
        if (index >= self.cardLeftArray.count) return;
        PokerCard *card = (PokerCard*)self.cardLeftArray[index];
        __block NSInteger currentIndex = index + 1;
        __block CGFloat degree = .0f;
        __block CGAffineTransform rotate = CGAffineTransformIdentity;
        __block NSInteger length = self.cardLeftArray.count;
        
        [UIView animateWithDuration:.25 animations:^{
            degree = -DEGREE_ROTATE * (length - currentIndex);
            rotate = CGAffineTransformMakeRotation(degree / 180 * M_PI);
            card.transform = rotate;
            card.frame = CGRectMake((CGRectGetWidth(self.frame) - self.cardWidth) / 2 - (length - currentIndex) * INTER_ITEM_SPACING_MIN, TOP_MARGTIN + (length - currentIndex) * INTER_LINE_SPACING_MIN, self.cardWidth, self.cardHeight - TOP_MARGTIN);
            [self Blur:card];
        } completion:^(BOOL finished) {
            CGAffineTransform transform = CGAffineTransformScale(rotate, SCALE_HORIZONTAL, 1 - SCALE_VALUE * (length - currentIndex));
            card.transform = transform;
            
            if ((index) == (self.cardLeftArray.count)) {
                [self bringSubviewToFront:card];
                [self cancelBlur:card];
            }
        }];
    } else {
        if ((index - self.cardLeftArray.count) >= self.cardRigthArray.count) return;
        __block NSInteger currentIndex = index - self.cardLeftArray.count;
        PokerCard *card = (PokerCard*)self.cardRigthArray[currentIndex];
        currentIndex++;
        __block CGFloat degree = .0f;
        __block CGAffineTransform rotate = CGAffineTransformIdentity;
        
        [UIView animateWithDuration:.25 animations:^{
            degree = DEGREE_ROTATE * (currentIndex);
            rotate = CGAffineTransformMakeRotation(degree / 180 * M_PI);
            card.transform = rotate;
            card.frame = CGRectMake((CGRectGetWidth(self.frame) - self.cardWidth) / 2 + (currentIndex) * INTER_ITEM_SPACING_MIN, TOP_MARGTIN + (currentIndex) * INTER_LINE_SPACING_MIN, self.cardWidth, self.cardHeight - TOP_MARGTIN);
            [self Blur:card];
        } completion:^(BOOL finished) {
            CGAffineTransform transform = CGAffineTransformScale(rotate, SCALE_HORIZONTAL, 1 - SCALE_VALUE * (currentIndex));
            card.transform = transform;
        }];
    }
}

#pragma mark - Swipe Methods
// 向左甩卡片动作
- (void)swipeToLeft {
    if (self.nowIndex == (self.totalCardCount - 1)) {
        self.nowIndex = (self.totalCardCount - 1);
        [self restoreInitialPosition:(PokerCard*)self.cardArray[self.nowIndex]];
        return;
    }
    for (int i = 0; i < self.cardArray.count; i++) {
        [self moveCardToLeft:i];
    }
    self.nowIndex++;
    [self removeMiddleCardFromSubArray:self.nowIndex];
}

// 向右甩卡片动作
- (void)swipeToRight {
    if (self.nowIndex == 0) {
        self.nowIndex = 0;
        [self restoreInitialPosition:(PokerCard*)self.cardArray[self.nowIndex]];
        return;
    }
    for (int i = (int)(self.cardArray.count - 1); i >= 0; i--) {
        [self moveCardToRight:i];
    }
    self.nowIndex--;
    [self removeMiddleCardFromSubArray:self.nowIndex];
}

#pragma mark - 卡片调整
// 从两侧数组中移出中间卡片 用以下次移动动作
- (void)removeMiddleCardFromSubArray:(NSInteger)middleIndex {
    PokerCard *middelCard = (PokerCard*)self.cardArray[middleIndex];
    if ([self.cardLeftArray containsObject:middelCard]) {
        [self.cardLeftArray removeObject:middelCard];
    }
    if ([self.cardRigthArray containsObject:middelCard]) {
        [self.cardRigthArray removeObject:middelCard];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self bringSubviewToFront:middelCard];
        [self cancelBlur:middelCard];
    });
    
    [self printLeftArray];
    [self printRightArray];
}

// 恢复卡片原来的位置
- (void)restoreInitialPosition:(PokerCard*)card {
    __weak typeof(self) weakSelf = self;
    __block CGAffineTransform rotate = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.5 animations:^{
        card.center = weakSelf.oldCenter;
        rotate = CGAffineTransformMakeRotation(0 / 180 * M_PI);
        CGAffineTransform transform = CGAffineTransformScale(rotate, SCALE_HORIZONTAL, SCALE_VERTICAL);
        card.transform = transform;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - UIPanGestureRecognizer Events
// 卡片手势动作
- (void)cardPanHandle:(UIPanGestureRecognizer*)pan {
    PokerCard *checkedCard = (PokerCard*)pan.view;
    PokerCard *card = (PokerCard*)self.cardArray[self.nowIndex];
    
    if (checkedCard != card) {
        return;
    }
    
    CGPoint point = [pan translationInView:self];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        // 开始拖动
        [self panGestureBeginWithPoint:card];
        //        NSLog(@"[test] Began Point.y %f", point.x);
        
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        // 拖动中
        [self panGestureMoveWithPoint:card panGesture:pan];
        
        //        NSLog(@"[test] Changed Point.y %f", point.x);
        
    } else if (pan.state == UIGestureRecognizerStateEnded) {
        // 拖动结束
        [self panGestureEndWithPoint:card panGesture:pan];
        //        NSLog(@"[test] Ended Point.y %f", point.x);
        
    } else if (pan.state == UIGestureRecognizerStateCancelled) {
        //        [self panGestureEndWithPoint:point];
        //        NSLog(@"[test] Ended Point.y %f", point.x);
    }
}

// 开始拖动
- (void)panGestureBeginWithPoint:(PokerCard *)card {
    // 缓存卡片最初的位置信息
    self.oldCenter = card.center;
}

// 拖动中
- (void)panGestureMoveWithPoint:(PokerCard *)card panGesture:(UIPanGestureRecognizer *)pan {
    // 给顶部视图添加动画
    CGPoint transLcation = [pan translationInView:card];
    // 视图跟随手势移动
    card.center = CGPointMake(card.center.x + transLcation.x, card.center.y + transLcation.y);
    // 移动中的缩放处理
    // 计算偏移系数
    CGFloat XOffPercent = (card.center.x - self.center.x) / (self.center.x);
    CGFloat rotation = M_PI / 10.5 * XOffPercent;
    card.transform = CGAffineTransformMakeRotation(rotation);
    [pan setTranslation:CGPointZero inView:card];
    // 给其余底部视图添加缩放动画
    // TODO: ...
}

// 拖动结束
- (void)panGestureEndWithPoint:(PokerCard *)card panGesture:(UIPanGestureRecognizer *)pan {
    CGPoint velocity = [pan velocityInView:self];
    
    // 移除拖动视图逻辑
//    // 加速度 小于 1100points/second
//    if (sqrt(pow(velocity.x, 2) + pow(velocity.y, 2)) < 1100.0) {
//    }
    
    // 移动区域半径大于150
    if ((sqrt(pow(self.oldCenter.x - card.center.x, 2) + pow(self.oldCenter.y - card.center.y, 2))) > 150) {
        if (velocity.x < 0) {
            // 向左拖动
            if ([self.cardLeftArray containsObject:card]) {
                [self restoreInitialPosition:card];
                return;
            }
            
            // 先添加入左列 用于画左列其他卡
            [self.cardLeftArray addObject:card];
            [self printLeftArray];
            // 先移除于右列 用于画右列其他卡
            if ([self.cardRigthArray containsObject:card]) {
                [self.cardRigthArray removeObject:card];
            }
            [self printRightArray];
            // 左移动作
            [self swipeToLeft];
        } else {
            // 向右拖动
            if ([self.cardRigthArray containsObject:card]) {
                [self restoreInitialPosition:card];
                return;
            }
            // 先移除于左列 用于画左列其他卡
            if ([self.cardLeftArray containsObject:card]) {
                [self.cardLeftArray removeObject:card];
            }
            [self printLeftArray];
            // 先插入入左列 用于画左列其他卡
            [self.cardRigthArray insertObject:card atIndex:0];
            [self printRightArray];
            // 右移动作
            [self swipeToRight];
        }
    } else {
        // 回到初始位置
        [self restoreInitialPosition:card];
    }
}

#pragma mark - Pring Data Array
- (void)printLeftArray {
#if DEBUG_LOG
    for (int i = 0; i < self.cardLeftArray.count; i++) {
        PokerCard *card = (PokerCard*)self.cardLeftArray[i];
        NSLog(@"<-: %d: %ld", i, (long)card.tag);
    }
#endif
}

- (void)printRightArray {
#if DEBUG_LOG
    for (int i = 0; i < self.cardRigthArray.count; i++) {
        PokerCard *card = (PokerCard*)self.cardRigthArray[i];
        NSLog(@"->: %d: %ld", i, (long)card.tag);
    }
#endif
}

- (void)Blur:(PokerCard*)card {
    card.isBlur = YES;
}

- (void)cancelBlur:(PokerCard*)card {
    card.isBlur = NO;
}

- (PokerCard *)dequeueReusableCardWithIdentifier {
    return [[PokerCard alloc] init];
}

#pragma mark - Lazy Load
- (NSMutableArray *)cardArray {
    if (!_cardArray) {
        _cardArray = [[NSMutableArray alloc] init];
    }
    return _cardArray;
}

- (NSMutableArray *)cardLeftArray {
    if (!_cardLeftArray) {
        _cardLeftArray = [[NSMutableArray alloc] init];
    }
    return _cardLeftArray;
}

- (NSMutableArray *)cardRigthArray {
    if (!_cardRigthArray) {
        _cardRigthArray = [[NSMutableArray alloc] init];
    }
    return _cardRigthArray;
}

@end

//
//  PokerCardSwipeView.h
//  PokerCardSwipeView
//
//  Created by pengyuesong on 2023/9/28.
//

#import <UIKit/UIKit.h>
#import "PokerCard.h"

NS_ASSUME_NONNULL_BEGIN

@class PokerCardSwipeView;

@protocol PokerCardSwipeDelegate <NSObject>

@required
// 获取显示数据内容
- (PokerCard *)CardSwipeGetCard:(PokerCardSwipeView *)cardSwipe withIndex:(int)index;
// 获取数据源总量
- (NSInteger)CardSwipeGetTotalCount:(PokerCardSwipeView *)cardSwipe;
@end

@interface PokerCardSwipeView : UIView

@property (nonatomic, weak) id<PokerCardSwipeDelegate> delegate;

// 卡片的宽高对象
@property (nonatomic, assign) CGSize itemSize;

// 层叠透明方式显示 默认NO
@property (nonatomic, assign) BOOL isStackCard;
// 加载方法
- (void)reloadData;
// 根据id获取缓存的cell
- (PokerCard *)dequeueReusableCardWithIdentifier;

@end

NS_ASSUME_NONNULL_END

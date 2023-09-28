//
//  PokerCard.h
//  PokerCardSwipeView
//
//  Created by pengyuesong on 2023/9/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PokerCard : UIView

// 卡片数据源对象 类型可自定义
@property (nonatomic, strong) NSString *entity;
// 非主显卡片是否需要模糊
@property (nonatomic, assign) BOOL isBlur;
// 卡片的宽高对象
@property (nonatomic, assign) CGSize itemSize;

@end

NS_ASSUME_NONNULL_END

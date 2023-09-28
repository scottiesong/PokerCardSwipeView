//
//  GlobalTools.h
//  PokerCardSwipeView
//
//  Created by pengyuesong on 2023/9/28.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GlobalTools : NSObject

// 计算标签的size
+ (CGSize)getTextSize:(NSString*)content withSize:(CGSize)size withFont:(UIFont*)font;

@end

NS_ASSUME_NONNULL_END

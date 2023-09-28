//
//  GlobalTools.m
//  PokerCardSwipeView
//
//  Created by pengyuesong on 2023/9/28.
//

#import "GlobalTools.h"

@implementation GlobalTools

// 计算标签的size
+ (CGSize)getTextSize:(NSString*)content withSize:(CGSize)size withFont:(UIFont*)font {
    if(content.length == 0) return CGSizeMake(0, 0);
    CGSize titleSize = [content boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    titleSize.height = ceilf(titleSize.height);
    titleSize.width = ceilf(titleSize.width);
    return titleSize;
}

@end

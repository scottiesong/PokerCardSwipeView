//
//  Constants.h
//  PokerCardSwipeView
//
//  Created by pengyuesong on 2023/9/28.
//

#ifndef Constants_h
#define Constants_h

#define degreeTOradians(x) (M_PI * (x) / 180)

#define Main_Screen_Width [UIScreen mainScreen].bounds.size.width
#define Main_Screen_Height [UIScreen mainScreen].bounds.size.height
#define Main_Screen_PortraitWidth MIN(Main_Screen_Width, Main_Screen_Height)

// childView距离父View左右的距离
#define LEFT_RIGHT_MARGIN 20
// 当前view距离父view的顶部的值
#define TOP_MARGTIN 20

#define DEGREE_ROTATE 1

// 卡片间隔 水平方向
#define INTER_ITEM_SPACING_MIN 15.
// 卡片间隔 垂直方向
#define INTER_LINE_SPACING_MIN 10.

// 缩放最小单位值
#define SCALE_VALUE .05
// 卡片缩放 水平方向
#define SCALE_HORIZONTAL 1.
// 卡片缩放 垂直方向
#define SCALE_VERTICAL 1.

#endif /* Constants_h */

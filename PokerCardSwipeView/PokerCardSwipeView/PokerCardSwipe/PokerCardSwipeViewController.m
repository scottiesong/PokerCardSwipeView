//
//  PokerCardSwipeViewController.m
//  PokerCardSwipeView
//
//  Created by pengyuesong on 2023/9/28.
//

#import "PokerCardSwipeViewController.h"
#import "Constants.h"
#import "PokerCard.h"
#import "PokerCardSwipeView.h"

@interface PokerCardSwipeViewController () <PokerCardSwipeDelegate>

@property (nonatomic, strong) PokerCardSwipeView *cardSwipeView;
@property (nonatomic, strong) NSMutableArray *colorArray;

@end

@implementation PokerCardSwipeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.grayColor;
    
    self.colorArray = [[NSMutableArray alloc] init];
    self.colorArray = [@[UIColor.redColor, UIColor.orangeColor, UIColor.orangeColor, UIColor.greenColor, UIColor.blueColor/*, UIColor.systemRedColor, UIColor.systemOrangeColor, UIColor.systemYellowColor, UIColor.systemGreenColor, UIColor.systemBlueColor*/] mutableCopy];
    
    CGFloat x = 20;
    CGFloat y = 100;
    CGFloat width = [UIScreen mainScreen].bounds.size.width - x * 2;
    CGFloat height = 550;
    [self.view addSubview:self.cardSwipeView];
    self.cardSwipeView.frame = CGRectMake(x, y, width, height);
    self.cardSwipeView.itemSize = CGSizeMake(287, ceilf(504 * Main_Screen_PortraitWidth / 375.));
}

- (UIView *)CardSwipeGetCard:(PokerCardSwipeView *)cardSwipe withIndex:(int)index {
    PokerCard *card = (PokerCard*)[cardSwipe dequeueReusableCardWithIdentifier];
//    card.backgroundColor = self.colorArray[index];
    UIColor *color = self.colorArray[index];
    card.layer.borderColor = color.CGColor;
    card.layer.borderWidth = 1.f;
    card.layer.cornerRadius = 10.f;
    if (index == 0) {
        card.isBlur = NO;
    } else {
        card.isBlur = YES;
    }
    card.entity = [NSString stringWithFormat:@"%d", index];
    card.itemSize = cardSwipe.itemSize;
    return card;
}

- (NSInteger)CardSwipeGetTotalCount:(PokerCardSwipeView *)cardSwipe {
    return self.colorArray.count;
}

#pragma mark - Lazy Load
- (PokerCardSwipeView *)cardSwipeView {
    if (!_cardSwipeView) {
        _cardSwipeView = [[PokerCardSwipeView alloc] init];
        _cardSwipeView.backgroundColor = UIColor.whiteColor;
        _cardSwipeView.delegate = self;
//        _cardSwipeView.isStackCard = NO;
        
        _cardSwipeView.layer.borderColor = UIColor.blackColor.CGColor;
        _cardSwipeView.layer.borderWidth = 1.f;
    }
    return _cardSwipeView;
}

@end

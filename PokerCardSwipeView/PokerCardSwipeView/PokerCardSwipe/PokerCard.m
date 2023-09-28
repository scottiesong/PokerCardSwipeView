//
//  PokerCard.m
//  PokerCardSwipeView
//
//  Created by pengyuesong on 2023/9/28.
//

#import "PokerCard.h"
#import "GlobalTools.h"

@interface PokerCard ()

@property (nonatomic, strong) UIView *maskContainerView;
@property (nonatomic, strong) UIVisualEffectView *effectview;

@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat maxHeight;

@property (nonatomic, strong) UILabel *mainLabel;// 大标题

@end

@implementation PokerCard

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayout];
        self.maxWidth = .0f;
        self.maxHeight = .0f;
    }
    return self;
}

- (void)setupLayout {
    self.backgroundColor = UIColor.whiteColor;
    
    [self addSubview:self.mainLabel];
    
    [self addSubview:self.effectview];
    self.effectview.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize titleSize = [GlobalTools getTextSize:_entity withSize:CGSizeMake(_maxWidth - 5 * 2, CGFLOAT_MAX) withFont:self.mainLabel.font];
    self.mainLabel.frame = CGRectMake(5, 10, titleSize.width, titleSize.height);
    
    self.effectview.frame = CGRectMake(0, 0, _maxWidth, _maxHeight);
}

- (void)setEntity:(NSString *)entity {
    if (_entity == entity) {
        _entity = entity;
        return;
    }
    _entity = entity;
}

- (void)setIsBlur:(BOOL)isBlur {
    _isBlur = isBlur;
    self.effectview.hidden = !isBlur;
}

- (void)setItemSize:(CGSize)itemSize {
    _itemSize = itemSize;
    _maxWidth = itemSize.width;
    _maxHeight = itemSize.height;
}

#pragma mark - Lazy Load
- (UIVisualEffectView *)effectview {
    if (!_effectview) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
        _effectview.contentView.layer.cornerRadius = 10.f;
        
        for (UIView *subView in _effectview.subviews) {
            subView.layer.cornerRadius = 10.f;
        }
    }
    return _effectview;
}

- (UIView *)mainContainerView {
    if (!_maskContainerView) {
        _maskContainerView = [[UIView alloc] init];
        _maskContainerView.backgroundColor = UIColor.whiteColor;
    }
    return _maskContainerView;
}

- (UILabel *)mainLabel {
    if (!_mainLabel) {
        _mainLabel = [[UILabel alloc] init];
        _mainLabel.textAlignment = NSTextAlignmentLeft;
        _mainLabel.numberOfLines = 0;
        _mainLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _mainLabel;
}

@end

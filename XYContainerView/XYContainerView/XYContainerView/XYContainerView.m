//
//  XYContainerView.m
//  XYContainerView
//
//  Created by aKerdi on 2018/1/12.
//  Copyright © 2018年 XXT. All rights reserved.
//

#import "XYContainerView.h"

static NSString *XYCollectionCellId = @"XYCollectionCellId";
static NSString *XYTableViewContentOffsetKeyPath = @"contentOffset";

@interface XYCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIView    *subContainerView;

@end

@interface XYContainerView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *containerView;

@property (nonatomic, strong) UIView    *headContainerView;
@property (nonatomic, strong) UIView    *bannerView;
@property (nonatomic, strong) UIView    *stickView;

@property (nonatomic, assign) NSInteger subContainersCount;
@property (nonatomic, assign) CGFloat   contentOffsetY;

@property (nonatomic, weak) UIScrollView *currentScrollView;

@end

@implementation XYContainerView

- (void)dealloc {
    UIScrollView *scrollView = (UIScrollView *)self.currentScrollView;
    [scrollView removeObserver:self forKeyPath:XYTableViewContentOffsetKeyPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.subContainersCount = 0;
        _horizonScrollEnable = YES;
        
        [self addSubview:self.containerView];
        self.containerView.frame = self.bounds;
        [self addSubview:self.headContainerView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - public

- (void)reloadData {
    self.subContainersCount = [self calculateSubContainersCount];
    UIView *headContainerView = [self getHeadContainerView];
    for (NSInteger i=0; i<self.subContainersCount; i++) {
        UIView *subContainerView = [self.dataSource xyContainerView:self subContainerViewAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if ([subContainerView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *subContainerScrollView = (UIScrollView *)subContainerView;
            if (i==0) {
                [subContainerScrollView addObserver:self forKeyPath:XYTableViewContentOffsetKeyPath options:NSKeyValueObservingOptionNew context:@selector(reloadData)];
                self.currentScrollView = subContainerScrollView;
                [subContainerScrollView addSubview:self.headContainerView];
                CGRect rect = self.headContainerView.frame;
                rect.origin.y = -CGRectGetHeight(self.headContainerView.frame);
                self.headContainerView.frame = rect;
            }
            UIEdgeInsets insets = subContainerScrollView.contentInset;
            insets.top = CGRectGetHeight(headContainerView.frame);
            subContainerScrollView.contentInset = UIEdgeInsetsMake(insets.top, insets.left, insets.bottom, insets.right);
        }
    }
    [self.containerView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object != self.currentScrollView) {
        return;
    }
    if (context == @selector(reloadData)) {
        CGPoint tableOffset = [[change objectForKey:@"new"] CGPointValue];
        CGFloat tableOffsetY = tableOffset.y;
        
        self.contentOffsetY = tableOffsetY;
        if ([self.delegate respondsToSelector:@selector(xyContainerView:scrollDidScroll:)]) {
            [self.delegate xyContainerView:self scrollDidScroll:object];
        }
        
        CGRect rect = self.headContainerView.frame;
        if (tableOffsetY>=-CGRectGetHeight(self.stickView.frame)) {
            if (self.headContainerView.superview==self) {
                return;
            }
            
            rect.origin.y = -CGRectGetHeight(self.headContainerView.frame)+CGRectGetHeight(self.stickView.frame);
            self.headContainerView.frame = rect;
            [self addSubview:self.headContainerView];
        } else {
            if (self.headContainerView.superview==self) {
                rect.origin.y = -CGRectGetHeight(self.headContainerView.frame);
                self.headContainerView.frame = rect;
                [self.currentScrollView addSubview:self.headContainerView];
            }
        }
    }
}

- (void)selectSectionAtIndex:(NSInteger)index {
    [self selectSectionAtIndex:index animated:NO];
}

- (void)selectSectionAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < 0||index >= self.subContainersCount) {
        return;
    }
    [self scrollViewWillBeginDragging:self.containerView];
    CGPoint contentOffset = self.containerView.contentOffset;
    __weak typeof(self) weakSelf = self;
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            weakSelf.containerView.contentOffset = CGPointMake(index*CGRectGetWidth(self.bounds), contentOffset.y);
        } completion:^(BOOL finished) {
            [weakSelf scrollViewDidEndDecelerating:self.containerView];
        }];
    } else {
        [UIView animateWithDuration:0.001 animations:^{
            weakSelf.containerView.contentOffset = CGPointMake(index*CGRectGetWidth(self.bounds), contentOffset.y);
        } completion:^(BOOL finished) {
            [weakSelf scrollViewDidEndDecelerating:self.containerView];
        }];
    }
}

- (void)setHorizonScrollEnable:(BOOL)horizonScrollEnable {
    if (_horizonScrollEnable == horizonScrollEnable) {
        return;
    }
    _horizonScrollEnable = horizonScrollEnable;
    self.containerView.scrollEnabled = horizonScrollEnable;
}

#pragma mark - private

- (NSInteger)calculateSubContainersCount {
    if ([self.dataSource respondsToSelector:@selector(xyContainerViewWithNumberOfSubContainerView:)]) {
        return [self.dataSource xyContainerViewWithNumberOfSubContainerView:self];
    }
    return 0;
}

- (UIView *)getHeadContainerView {
    [self.bannerView removeFromSuperview];
    [self.stickView removeFromSuperview];
    self.bannerView = nil;
    self.stickView = nil;
    if ([self.delegate respondsToSelector:@selector(xyContainerViewWithBannerView:)]) {
        self.bannerView = [self.delegate xyContainerViewWithBannerView:self];
    }
    if ([self.delegate respondsToSelector:@selector(xyContainerViewWithStickView:)]) {
        self.stickView = [self.delegate xyContainerViewWithStickView:self];
    }
    [self.headContainerView addSubview:self.bannerView];
    CGRect rect = self.stickView.frame;
    rect.origin.y = CGRectGetMaxY(self.bannerView.frame);
    self.stickView.frame = rect;
    [self.headContainerView addSubview:self.stickView];
    CGRect headContainerViewRect = self.headContainerView.frame;
    headContainerViewRect.size.height = CGRectGetHeight(self.bannerView.frame)+CGRectGetHeight(self.stickView.frame);
    self.headContainerView.frame = headContainerViewRect;
    return self.headContainerView;
}

- (void)targetScrollDidScrollInnerFunc {
    UIScrollView *currentScrollView = self.currentScrollView;
    
    for (NSInteger i=0;i<self.subContainersCount;i++) {
        UIScrollView *subScrollView = (UIScrollView *)[self.dataSource xyContainerView:self subContainerViewAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (subScrollView==currentScrollView) {
            continue;
        }
        if (currentScrollView.contentOffset.y>=-CGRectGetHeight(self.stickView.frame)) {
            subScrollView.contentOffset = CGPointMake(0, -CGRectGetHeight(self.stickView.frame));
        } else {
            subScrollView.contentOffset = currentScrollView.contentOffset;
        }
    }
}

#pragma mark - UICollectinoViewDataSource

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.currentScrollView.userInteractionEnabled = NO;
    CGFloat maxTop = MAX(-(CGRectGetHeight(self.headContainerView.frame)+self.currentScrollView.contentOffset.y), -(CGRectGetHeight(self.headContainerView.frame)-CGRectGetHeight(self.stickView.frame)));
    CGRect rect = self.headContainerView.frame;
    rect.origin.y = maxTop;
    self.headContainerView.frame = rect;
    [self addSubview:self.headContainerView];
    [self targetScrollDidScrollInnerFunc];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect rect = self.headContainerView.frame;
    rect.origin.x = 0;
    self.headContainerView.frame = rect;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentScrollView.userInteractionEnabled = YES;
    CGPoint offsetP = scrollView.contentOffset;
    NSInteger index = offsetP.x/CGRectGetWidth(self.bounds);
    XYCollectionCell *cell = (XYCollectionCell *)[self.containerView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [self.currentScrollView removeObserver:self forKeyPath:XYTableViewContentOffsetKeyPath];
    
    self.currentScrollView = (UIScrollView *)cell.subContainerView;
    [self.currentScrollView addObserver:self forKeyPath:XYTableViewContentOffsetKeyPath options:NSKeyValueObservingOptionNew context:@selector(reloadData)];
    
    CGRect rect = self.headContainerView.frame;
    rect.origin.y = -CGRectGetHeight(self.headContainerView.frame);
    self.headContainerView.frame = rect;
    [self.currentScrollView addSubview:self.headContainerView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.subContainersCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XYCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:XYCollectionCellId forIndexPath:indexPath];
    UIView *subContainerView = [self.dataSource xyContainerView:self subContainerViewAtIndexPath:indexPath];
    if (cell.subContainerView!=subContainerView) {
        [cell.subContainerView removeFromSuperview];
        [cell addSubview:subContainerView];
        cell.subContainerView = subContainerView;
    }
    return cell;
}

#pragma mark - Accessory

- (UIView *)headContainerView {
    if (!_headContainerView) {
        _headContainerView = [UIView new];
        _headContainerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), 0);
    }
    return _headContainerView;
}

- (UICollectionView *)containerView {
    if (!_containerView) {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        flowLayout.minimumLineSpacing = 0.0000001;
        flowLayout.minimumInteritemSpacing = 0.0000001;
        flowLayout.itemSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.frame));
        _containerView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _containerView.delegate = self;
        _containerView.dataSource = self;
        _containerView.pagingEnabled = YES;
        _containerView.showsVerticalScrollIndicator = NO;
        _containerView.showsHorizontalScrollIndicator = NO;
        _containerView.bounces = NO;
        _containerView.backgroundColor = [UIColor clearColor];
        [_containerView registerClass:[XYCollectionCell class] forCellWithReuseIdentifier:XYCollectionCellId];
    }
    return _containerView;
}
@end

@implementation XYCollectionCell

@end

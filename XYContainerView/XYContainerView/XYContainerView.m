//
//  XYContainerView.m
//  XYContainerView
//
//  Created by aKerdi on 2018/1/12.
//  Copyright © 2018年 XXT. All rights reserved.
//

#import "XYContainerView.h"
#import "UIViewAdditions.h"

static NSString *XYCollectionCellId = @"XYCollectionCellId";

@interface XYCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIView *subContainerView;

@end

@interface XYContainerView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *containerView;

@property (nonatomic, strong) UIView    *headContainerView;
@property (nonatomic, strong) UIView    *bannerView;
@property (nonatomic, strong) UIView    *stickView;

@property (nonatomic, strong) NSArray   *subContainers;
@property (nonatomic, assign) NSInteger subContainersCount;

@property (nonatomic, weak) UIScrollView *currentScrollView;

@end

@implementation XYContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.subContainersCount = 0;
        self.subContainers = nil;
        [self addSubview:self.containerView];
        [self addSubview:self.headContainerView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.containerView.frame = self.bounds;
}

#pragma mark - public

- (void)reloadData {
    
    self.subContainersCount = [self calculateSubContainersCount];
    UIView *headContainerView = [self getHeadContainerView];
    for (NSInteger i=0; i<self.subContainersCount; i++) {
        UIView *subContainerView = [self.dataSource xyContainerView:self subContainerViewAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if ([subContainerView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *subContainerScrollView = (UIScrollView *)subContainerView;
            [subContainerScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:@selector(reloadData)];
            if (i==0) {
                self.currentScrollView = subContainerScrollView;
                [subContainerScrollView addSubview:self.headContainerView];
                self.headContainerView.top = -self.headContainerView.height;
            }
            UIEdgeInsets insets = subContainerScrollView.contentInset;
            insets.top = headContainerView.height;
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
        if (tableOffsetY>=-self.stickView.height) {
            if (self.headContainerView.superview==self) {
                return;
            }
            self.headContainerView.top = -self.headContainerView.height+self.stickView.height;
            [self addSubview:self.headContainerView];
        } else {
            if (self.headContainerView.superview==self) {
                self.headContainerView.top = -self.headContainerView.height;
                [self.currentScrollView addSubview:self.headContainerView];
            }
        }
    }
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
    self.stickView.top = self.bannerView.bottom;
    [self.headContainerView addSubview:self.stickView];
    self.headContainerView.height = self.bannerView.height+self.stickView.height;
    return self.headContainerView;
}

- (void)targetScrollDidScrollInnerFunc {
    
    UIScrollView *currentScrollView = self.currentScrollView;
    
    for (NSInteger i=0;i<self.subContainersCount;i++) {
        UIScrollView *subScrollView = (UIScrollView *)[self.dataSource xyContainerView:self subContainerViewAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if (subScrollView==currentScrollView) {
            continue;
        }
        if (currentScrollView.contentOffset.y>=-self.stickView.height) {
            subScrollView.contentOffset = CGPointMake(0, -self.stickView.height);
        } else {
            subScrollView.contentOffset = currentScrollView.contentOffset;
        }
    }
}

#pragma mark - UICollectinoViewDataSource

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.currentScrollView.scrollEnabled = NO;
    self.headContainerView.top = MAX(-(self.headContainerView.height+self.currentScrollView.contentOffset.y), -(self.headContainerView.height-self.stickView.height));
    [self addSubview:self.headContainerView];
    [self targetScrollDidScrollInnerFunc];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.headContainerView.left = 0;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentScrollView.scrollEnabled = YES;
    CGPoint offsetP = scrollView.contentOffset;
    NSInteger index = offsetP.x/self.width;
    XYCollectionCell *cell = (XYCollectionCell *)[self.containerView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    self.currentScrollView = (UIScrollView *)cell.subContainerView;
    self.headContainerView.top = -self.headContainerView.height;
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
        _headContainerView.frame = CGRectMake(0, 0, self.width, 0);
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
        flowLayout.itemSize = CGSizeMake(self.width, self.height);
        _containerView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _containerView.delegate = self;
        _containerView.dataSource = self;
        _containerView.pagingEnabled = YES;
        _containerView.showsVerticalScrollIndicator = NO;
        _containerView.showsHorizontalScrollIndicator = NO;
        _containerView.bounces = NO;
        [_containerView registerClass:[XYCollectionCell class] forCellWithReuseIdentifier:XYCollectionCellId];
    }
    return _containerView;
}
@end

@implementation XYCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

@end

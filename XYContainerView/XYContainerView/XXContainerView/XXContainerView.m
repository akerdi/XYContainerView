//
//  XXContainerView.m
//  XYContainerView
//
//  Created by aKerdi on 2018/1/12.
//  Copyright © 2018年 XXT. All rights reserved.
//

#import "XXContainerView.h"

#import "XXContainerBottomScrollView.h"

static NSString *XXCollectionCellId = @"XXCollectionCellId";

@interface XXCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIView *subContainerView;

@end

@interface XXContainerView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) XXContainerBottomScrollView *containerView;

@property (nonatomic, strong) UIView        *headContainerView;
@property (nonatomic, strong) UIView        *bannerView;
@property (nonatomic, strong) UIView        *stickView;

@property (nonatomic, assign) NSInteger     subContainersCount;

@property (nonatomic, weak) UIScrollView    *currentScrollView;
@property (nonatomic, strong) UICollectionView   *crossCollectionView;

@end

@implementation XXContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.subContainersCount = 0;
        
        [self addSubview:self.containerView];
        [self.containerView addSubview:self.crossCollectionView];
        [self.containerView addSubview:self.headContainerView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.containerView.frame = self.bounds;
}

#pragma mark - UICollectinoViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.subContainersCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XXCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:XXCollectionCellId forIndexPath:indexPath];
    UIView *subContainerView = [self.dataSource xxContainerView:self subContainerViewAtIndexPath:indexPath];
    if (cell.subContainerView!=subContainerView) {
        [cell.subContainerView removeFromSuperview];
        [cell addSubview:subContainerView];
        cell.subContainerView = subContainerView;
    }
    return cell;
}

#pragma mark - public

- (void)reloadData {
    self.subContainersCount = [self calculateSubContainersCount];
    
    UIView *headContainerView = [self getHeadContainerView];
    
    self.containerView.contentSize = CGSizeMake(self.width, self.bannerView.height+self.height);
    
    self.crossCollectionView.top = headContainerView.height;
    CGFloat crossTableViewHeight = self.height-self.stickView.height;
    self.crossCollectionView.height = crossTableViewHeight;
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.crossCollectionView.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(self.width, crossTableViewHeight);
    
    for (NSInteger i=0; i<self.subContainersCount; i++) {
        UIView *subContainerView = [self.dataSource xxContainerView:self subContainerViewAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        if ([subContainerView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *subContainerScrollView = (UIScrollView *)subContainerView;
            if (subContainerScrollView.observationInfo) {
                [subContainerScrollView removeObserver:self forKeyPath:@"contentOffset"];
            }
            [subContainerScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:@selector(reloadData)];
            
            if (i==0) {
                self.currentScrollView = subContainerScrollView;
            }
            //设置高度
            subContainerScrollView.height = flowLayout.itemSize.height;
        } else {
            NSAssert(0, @"subContainerView must be a subclass of UIScrollView~~");
        }
    }
    [self.crossCollectionView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object != self.currentScrollView) {
        return;
    }
    if (context == @selector(reloadData)) {
        CGPoint tableOffset = [[change objectForKey:@"new"] CGPointValue];
        CGPoint containerViewOffset = self.containerView.contentOffset;
        CGFloat containerViewOffsetY = containerViewOffset.y;
        CGFloat tableOffsetY = tableOffset.y;
        if (containerViewOffsetY<=80) {
            if (self.currentScrollView.contentOffset.y !=0) {
                self.currentScrollView.contentOffset = CGPointZero;
            }
        } else {
        }
    }
}

#pragma mark - private

- (NSInteger)calculateSubContainersCount {
    if ([self.dataSource respondsToSelector:@selector(xxContainerViewWithNumberOfSubContainerView:)]) {
        return [self.dataSource xxContainerViewWithNumberOfSubContainerView:self];
    }
    return 0;
}

- (UIView *)getHeadContainerView {
    [self.bannerView removeFromSuperview];
    [self.stickView removeFromSuperview];
    self.bannerView = nil;
    self.stickView = nil;
    if ([self.delegate respondsToSelector:@selector(xxContainerViewWithBannerView:)]) {
        self.bannerView = [self.delegate xxContainerViewWithBannerView:self];
    }
    if ([self.delegate respondsToSelector:@selector(xxContainerViewWithStickView:)]) {
        self.stickView = [self.delegate xxContainerViewWithStickView:self];
    }
    [self.headContainerView addSubview:self.bannerView];
    self.stickView.top = self.bannerView.bottom;
    [self.headContainerView addSubview:self.stickView];
    self.headContainerView.height = self.bannerView.height+self.stickView.height;
    return self.headContainerView;
}

#pragma mark - Accessory

- (UICollectionView *)crossCollectionView {
    if (!_crossCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.sectionInset = UIEdgeInsetsZero;
        flowLayout.minimumLineSpacing = 0.0000001;
        flowLayout.minimumInteritemSpacing = 0.0000001;
        _crossCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
        _crossCollectionView.delegate = self;
        _crossCollectionView.dataSource = self;
        _crossCollectionView.pagingEnabled = YES;
        _crossCollectionView.showsVerticalScrollIndicator = NO;
        _crossCollectionView.showsHorizontalScrollIndicator = NO;
        _crossCollectionView.bounces = NO;
        [_crossCollectionView registerClass:[XXCollectionCell class] forCellWithReuseIdentifier:XXCollectionCellId];
    }
    return _crossCollectionView;
}

- (UIView *)headContainerView {
    if (!_headContainerView) {
        _headContainerView = [UIView new];
        _headContainerView.frame = CGRectMake(0, 0, self.width, 0);
    }
    return _headContainerView;
}

- (XXContainerBottomScrollView *)containerView {
    if (!_containerView) {
        _containerView = [[XXContainerBottomScrollView alloc] initWithFrame:self.bounds];
        typeof(self) weakSelf = self;
        _containerView.block = ^BOOL(XXContainerBottomScrollView *bottomScrollView, UIPanGestureRecognizer *gesture, UIPanGestureRecognizer *otherGesture) {
            CGPoint p1 = [gesture velocityInView:bottomScrollView];
            CGPoint p2 = [otherGesture velocityInView:bottomScrollView];
            if (ABS(p1.x)== 0.f || ABS(p2.x)== 0.f) {
                return YES;
            }
            if (ABS(p1.y)== 0.f || ABS(p2.y)== 0.f) {
                return NO;
            }
            if ((ABS(p1.x) / ABS(p1.y) > 1.5) || (ABS(p2.x) / ABS(p2.y) > 1.5)) {
                return NO;
            }
            return YES;
        };
    }
    return _containerView;
}

@end


@implementation XXCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

@end

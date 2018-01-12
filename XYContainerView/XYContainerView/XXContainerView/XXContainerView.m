//
//  XXContainerView.m
//  XYContainerView
//
//  Created by aKerdi on 2018/1/12.
//  Copyright © 2018年 XXT. All rights reserved.
//

#import "XXContainerView.h"

#import "XXContainerBottomScrollView.h"

@interface XXContainerView ()

@property (nonatomic, strong) XXContainerBottomScrollView *containerView;

@property (nonatomic, strong) UIView        *headContainerView;
@property (nonatomic, strong) UIView        *bannerView;
@property (nonatomic, strong) UIView        *stickView;

@property (nonatomic, assign) NSInteger     subContainersCount;

@property (nonatomic, weak) UIScrollView    *currentScrollView;
@property (nonatomic, strong) UITableView   *crossTableView;

@end

@implementation XXContainerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.subContainersCount = 0;
        
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
        UIView *subContainerView = [self.dataSource xxContainerView:self subContainerViewAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
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
        _containerView.block = ^BOOL(UIPanGestureRecognizer *gesture, UIPanGestureRecognizer *otherGesture) {
            if (gesture==self.crossTableView.panGestureRecognizer||otherGesture==self.crossTableView.panGestureRecognizer) {
                return NO;
            }
            CGPoint p0 = [gesture velocityInView:weakSelf.containerView];
            CGPoint p1 = [otherGesture velocityInView:weakSelf.containerView];
            return YES;
        };
    }
    return _containerView;
}

@end

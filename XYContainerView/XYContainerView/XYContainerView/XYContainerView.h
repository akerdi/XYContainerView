//
//  XYContainerView.h
//  XYContainerView
//
//  Created by aKerdi on 2018/1/12.
//  Copyright © 2018年 XXT. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XYContainerViewDelegate, XYContainerViewDataSource;
@interface XYContainerView : UIView

@property (nonatomic, weak) id<XYContainerViewDelegate> delegate;
@property (nonatomic, weak) id<XYContainerViewDataSource> dataSource;

@property (nonatomic, strong, readonly) UICollectionView *containerView;

/**
 偏移位置 值范围：x>= -(bannerViewHeight + stickViewHeight)
 */
@property (nonatomic, assign, readonly) CGFloat contentOffsetY;

@property (nonatomic, assign) BOOL horizonScrollEnable;

- (void)reloadData;

/**
 指定滑动

 @param index 0~(dataSource count-1)
 @param animated <#index description#>
 */
- (void)selectSectionAtIndex:(NSInteger)index animated:(BOOL)animated;
- (void)selectSectionAtIndex:(NSInteger)index;

@end

@protocol XYContainerViewDataSource <NSObject>

@required;

- (UIView *)xyContainerView:(XYContainerView *)containerView subContainerViewAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)xyContainerViewWithNumberOfSubContainerView:(XYContainerView *)containerView;

@end

@protocol XYContainerViewDelegate <NSObject>

@optional;

- (UIView *)xyContainerViewWithBannerView:(XYContainerView *)containerView;

- (UIView *)xyContainerViewWithStickView:(XYContainerView *)containerView;


/**
 用户自定义停留高度
 在用户左右滑动时会调用,来进行判断顶部固定高度位置
 计算停留高度时,xyContainerViewWithStickView 优先级高于xyContainerViewCustomStickViewHeight

 @param containerView <#containerView description#>
 @return >0 有效
 */
- (CGFloat)xyContainerViewCustomStickViewHeight:(XYContainerView *)containerView;

/**
 滑动回调
 方法来自于currentScrollView 的contentOffset 调用

 @param containerView <#containerView description#>
 @param scrollView 该对象为tableV|tableV|tableV 中某个
 */
- (void)xyContainerView:(XYContainerView *)containerView scrollDidScroll:(UIScrollView *)scrollView;

/**
 左右滑动，选中contentView 回调

 @param containerView <#containerView description#>
 @param index <#index description#>
 */
- (void)xyContainerView:(XYContainerView *)containerView didSelectContentAtIndex:(NSInteger)index;

@end

//
//  XYContainerView.h
//  XYContainerView
//
//  Created by aKerdi on 2018/1/12.
//  Copyright © 2018年 XXT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewAdditions.h"

@protocol XYContainerViewDelegate, XYContainerViewDataSource;
@interface XYContainerView : UIView

@property (nonatomic, weak) id<XYContainerViewDelegate> delegate;
@property (nonatomic, weak) id<XYContainerViewDataSource> dataSource;

- (void)reloadData;

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

@end

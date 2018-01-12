//
//  XXContainerView.h
//  XYContainerView
//
//  Created by aKerdi on 2018/1/12.
//  Copyright © 2018年 XXT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewAdditions.h"

@protocol XXContainerViewDelegate, XXContainerViewDataSource;
@interface XXContainerView : UIView

@property (nonatomic, weak) id<XXContainerViewDelegate> delegate;
@property (nonatomic, weak) id<XXContainerViewDataSource> dataSource;

- (void)reloadData;

@end

@protocol XXContainerViewDataSource <NSObject>

@required;

- (UIView *)xxContainerView:(XXContainerView *)containerView subContainerViewAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)xxContainerViewWithNumberOfSubContainerView:(XXContainerView *)containerView;

@end

@protocol XXContainerViewDelegate <NSObject>

@optional;

- (UIView *)xxContainerViewWithBannerView:(XXContainerView *)containerView;

- (UIView *)xxContainerViewWithStickView:(XXContainerView *)containerView;

@end

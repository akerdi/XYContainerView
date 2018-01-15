//
//  XXContainerBottomView.h
//  XYContainerView
//
//  Created by aKerdi on 2018/1/12.
//  Copyright © 2018年 XXT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XXContainerBottomScrollView;
typedef BOOL(^SubScollViewRecgnizerBlock)(XXContainerBottomScrollView *bottomScrollView, UIPanGestureRecognizer *gesture, UIPanGestureRecognizer *otherGesture);

@interface XXContainerBottomScrollView : UIScrollView

@property (nonatomic, copy) SubScollViewRecgnizerBlock block;

@end

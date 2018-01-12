//
//  XXContainerBottomView.m
//  XYContainerView
//
//  Created by aKerdi on 2018/1/12.
//  Copyright © 2018年 XXT. All rights reserved.
//

#import "XXContainerBottomScrollView.h"

@interface XXContainerBottomScrollView ()<UIGestureRecognizerDelegate>

@end

@implementation XXContainerBottomScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return self.block?self.block(gestureRecognizer, otherGestureRecognizer):NO;
    }
    return NO;
}

@end

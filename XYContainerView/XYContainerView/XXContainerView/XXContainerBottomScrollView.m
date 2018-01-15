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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return self.block?self.block(self, (UIPanGestureRecognizer *)gestureRecognizer, (UIPanGestureRecognizer *)otherGestureRecognizer):NO;
    }
    return NO;
}

@end

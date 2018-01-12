//
//  NSNumberFormatter+XXCurrency.m
//  XXT
//
//  Created by aKerdi on 2017/7/17.
//  Copyright © 2017年 xxtstudio. All rights reserved.
//

#import "NSNumberFormatter+XXCurrency.h"

@implementation NSNumberFormatter (XXCurrency)

- (void)numberFormatterCurrencyStyle
{
    [self setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [self setPositiveFormat:@"###0.00"];
    [self setUsesGroupingSeparator:YES];
    [self setGroupingSize:3];
    [self setGroupingSeparator:@" "];
}

- (void)numberFormatterPurchaseStyle
{
    [self setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [self setPositiveFormat:@"#"];
    [self setUsesGroupingSeparator:YES];
    [self setGroupingSize:3];
    [self setGroupingSeparator:@" "];
}

@end

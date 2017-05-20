//
//  QqcScanFramework.m
//  QqcScanFramework
//
//  Created by qiuqinchuan on 16/2/24.
//  Copyright © 2016年 Qqc. All rights reserved.
//

#import "QqcScanFramework.h"

static NSString* kVersion1_0 = @"1.0";
static NSString* kVersion1_0_info = @"1.0 封装了扫码模块";

@implementation QqcScanFramework

- (NSString*)version
{
    return kVersion1_0;
}


- (NSString*)versionInfo
{
    return kVersion1_0_info;
}

@end

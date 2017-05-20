//
//  QqcScanProcessor.h
//  QqcScan
//
//  Created by qiuqinchuan on 15/10/14.
//  Copyright © 2015年 Qqc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QqcScanProcessor : NSObject

/**
 *  扫码区域
 */
@property(nonatomic, assign) CGRect rcScan;

/**
 *  初始化扫码处理器
 *
 *  @param scanView 扫码主界面对象
 *
 *  @return 扫码处理器对象
 */
- (instancetype)initWithScanView:(UIView*)scanView;

/**
 *  开始扫码
 */
- (void)startScan;

/**
 *  停止扫码
 */
- (void)stopScan;

/**
 *  解析二维码图片获取二维码信息
 *
 *  @param image 二维码图片
 *
 *  @return 二维码信息
 */
- (NSString*)getDataWithImage:(UIImage *)image;


/**
 *  扫描二维码成功回调
 */
@property (nonatomic, copy) void (^QqcQRCodeSuccessBlock)(QqcScanProcessor *processor, NSString *result);

/**
 *  扫描二维码失败回调
 */
@property (nonatomic, copy) void (^QqcQRCodeFailBlock)(QqcScanProcessor *processor);


@end

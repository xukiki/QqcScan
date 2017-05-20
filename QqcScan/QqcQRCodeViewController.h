//
//  QqcQRCodeViewController.h
//  Qqc
//
//  Created by mahailin on 15/9/25.
//  Copyright © 2015年 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, QqcScanUIMask) {
    QqcScanUIMaskBack = (1 << 0),
    QqcScanUIMaskFlashLight = (1 << 1),
    QqcScanUIMaskPic = (1 << 2),
    QqcScanUIMaskHistory = (1 << 3),
};

@protocol QqcScanDelegate <NSObject>

@optional
//点击了回退按钮
- (void)onBack;

//点击了闪关灯
- (void)onFlashLight;

//点击了选择图片
- (void)onPic;

//点击了扫码历史
- (void)onHistory;

@end


/**
 *  二维码扫描控制器
 */
@interface QqcQRCodeViewController : UIViewController

@property(nonatomic, weak) id<QqcScanDelegate> delegate;

/**
 *  扫描二维码成功回调
 */
@property (nonatomic, copy) void (^QqcQRCodeSuccessBlock)(QqcQRCodeViewController *controller, NSString *result);

/**
 *  扫描二维码失败回调
 */
@property (nonatomic, copy) void (^QqcQRCodeFailBlock)(QqcQRCodeViewController *controller);

/**
 *  初始化接口
 *
 *  @param uiMask 配置显示扫码界面的按钮
 */
- (instancetype)initWithScanUIMask:(QqcScanUIMask)uiMask;

@end

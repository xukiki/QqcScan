//
//  QqcScanProcessor.m
//  QqcScan
//
//  Created by qiuqinchuan on 15/10/14.
//  Copyright © 2015年 Qqc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QqcScanProcessor.h"
#import "QqcSizeDef.h"
#import "ZXingObjC.h"

@interface QqcScanProcessor()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIView *scanView;
@property (nonatomic, strong) AVCaptureSession *qrCodeSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrCodePreviewLayer;

@end

@implementation QqcScanProcessor

#pragma mark - 系统框架
- (void)dealloc
{
    if (_qrCodeSession)
    {
        [_qrCodeSession stopRunning];
        _qrCodeSession = nil;
    }
}

- (instancetype)initWithScanView:(UIView*)scanView
{
    self = [super init];
    if (self)
    {
        _scanView = scanView;
        _rcScan = CGRectMake(0, 0, width_screen_qqc, height_screen_qqc);
        [self configCapture];
    }
    
    return self;
}

- (instancetype)init
{
    self = [self initWithScanView:nil];

    return self;
}

#pragma mark - 接口
- (void)startScan
{
    [self.qrCodeSession startRunning];
}

- (void)stopScan
{
    [self.qrCodeSession stopRunning];
}


#pragma mark -初始化
- (void)configCapture
{
    NSError *error = nil;
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (error)
    {
        NSLog(@"没有摄像头，%@", error.localizedDescription);
        return;
    }
    //设置输出
    AVCaptureMetadataOutput *outPut = [[AVCaptureMetadataOutput alloc] init];
    [outPut setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [outPut setRectOfInterest:_rcScan];

    
    //拍摄会话
    if ([self.qrCodeSession canAddInput:input])
    {
        [self.qrCodeSession addInput:input];
    }
    
    if ([self.qrCodeSession canAddOutput:outPut])
    {
        [self.qrCodeSession addOutput:outPut];
    }
    
    //设置输出的格式,一定要先设置会话的输出为output之后，再指定输出的元数据类型
    if ([outPut.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode])
    {
        [outPut setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    }
    
    
    //将图层添加到视图的图层
    if (_scanView)
    {
        [_scanView.layer insertSublayer:self.qrCodePreviewLayer atIndex:0];
    }
    else
    {
        NSLog(@"请调用initWithScanView设置扫码主窗口");
    }
}

- (AVCaptureSession *)qrCodeSession
{
    if (!_qrCodeSession)
    {
        _qrCodeSession = [[AVCaptureSession alloc] init];
        _qrCodeSession.sessionPreset = AVCaptureSessionPresetHigh;
    }
    
    return _qrCodeSession;
}

- (AVCaptureVideoPreviewLayer *)qrCodePreviewLayer
{
    if (!_qrCodePreviewLayer)
    {
        _qrCodePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.qrCodeSession];
        _qrCodePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _qrCodePreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        
        _qrCodePreviewLayer.frame = CGRectMake(0, 0, width_screen_qqc, height_screen_qqc);
    }
    
    return _qrCodePreviewLayer;
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate 扫码代理
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0)
    {
        [self stopScan];
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        if (obj.stringValue && ![obj.stringValue isEqualToString:@""] && obj.stringValue.length > 0)
        {
            if (self.QqcQRCodeSuccessBlock)
            {
                self.QqcQRCodeSuccessBlock(self, obj.stringValue);
            }
        }
        else
        {
            if (self.QqcQRCodeFailBlock)
            {
                self.QqcQRCodeFailBlock(self);
            }
        }
    }
    else
    {
        if (self.QqcQRCodeFailBlock)
        {
            self.QqcQRCodeFailBlock(self);
        }
    }
}

//解析二维码图片获取二维码信息
- (NSString*)getDataWithImage:(UIImage *)image
{
    UIImage *loadImage = image;
    CGImageRef imageToDecode = loadImage.CGImage;
    
    ZXLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:imageToDecode];
    ZXBinaryBitmap *bitmap = [ZXBinaryBitmap binaryBitmapWithBinarizer:[ZXHybridBinarizer binarizerWithSource:source]];
    
    NSError *error = nil;
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    ZXMultiFormatReader *reader = [ZXMultiFormatReader reader];
    ZXResult *result = [reader decode:bitmap
                                hints:hints
                                error:&error];
    
    NSString* strRet = @"";
    if (result)
    {
        strRet = result.text;
    }

    return strRet;
}

@end

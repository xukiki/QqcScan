//
//  QqcQRCodeViewController.m
//  Qqc
//
//  Created by mahailin on 15/9/25.
//  Copyright © 2015年 admin. All rights reserved.
//

#import "QqcQRCodeViewController.h"
#import "QqcScanProcessor.h"
#import "QqcSizeDef.h"
#import "UIImage+Qqc.h"
#import "QqcMarginDef.h"
#import "QqcUtility.h"
#import "QqcComFuncDef.h"
#import "QqcImagePickerController.h"

#define KDeviceFrame [UIScreen mainScreen].bounds

static const float kReaderViewWidth = 200;
static const float kReaderViewHeight = 200;

@interface QqcQRCodeViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property(nonatomic, assign)QqcScanUIMask scanUIMask;

/**
 *  扫码对象
 */
@property(nonatomic, strong) QqcScanProcessor* scanProcessor;

/**
 *  探照灯
 */
@property(nonatomic, strong) UIButton *btnTorch;

/**
 *  扫描线
 */
@property(nonatomic, strong) UIImageView *scanLineImageView;

/**
 *  定时器
 */
@property(nonatomic, strong) NSTimer *lineTimer;

/**
 *  顶部、低部阴影高度
 */
@property(nonatomic, assign) CGFloat heightTopBottomMask;

/**
 *  左、右阴影宽度
 */
@property(nonatomic, assign) CGFloat widthLeftRightMask;

@end

@implementation QqcQRCodeViewController

#pragma mark - 系统方法
- (instancetype)initWithScanUIMask:(QqcScanUIMask)uiMask
{
    self = [super init];
    if (self)
    {
        _scanUIMask = uiMask;
    }

    return self;
}

- (void)dealloc
{
    if (_lineTimer)
    {
        [self stopLineTimer];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)willDealloc {
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _heightTopBottomMask = (height_screen_qqc-kReaderViewHeight)/2;
    _widthLeftRightMask = (width_screen_qqc-kReaderViewWidth)/2;
    
    [self buildMaskView];
    [self buildFunctionBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self startQRCodeScan];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self stopQRCodeScan];
}

#pragma mark - 内部使用方法

/**
 *  设置遮罩层
 */
- (void)buildMaskView
{
    CGFloat customAlpha = 0.66;
    UIColor *customColor = [UIColor blackColor];
    
    //顶部view
    UIView* topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width_screen_qqc, _heightTopBottomMask)];
    topView.alpha = customAlpha;
    topView.backgroundColor = customColor;
    [self.view addSubview:topView];
    
    //左边view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, _heightTopBottomMask, _widthLeftRightMask, kReaderViewHeight)];
    leftView.alpha = customAlpha;
    leftView.backgroundColor = customColor;
    [self.view addSubview:leftView];
    
    //右边view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(width_screen_qqc-_widthLeftRightMask, _heightTopBottomMask, _widthLeftRightMask, kReaderViewHeight)];
    rightView.alpha = customAlpha;
    rightView.backgroundColor = customColor;
    [self.view addSubview:rightView];
    
    //底部view
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, height_screen_qqc-_heightTopBottomMask, width_screen_qqc, _heightTopBottomMask)];
    bottomView.alpha = customAlpha;
    bottomView.backgroundColor = customColor;
    [self.view addSubview:bottomView];
    
    //左上边角imageview
    UIImage *customImage = [UIImage imageFromBundleWithName:@"qrCodeLeftTop.png" bundleName:@"QqcScan"];
    UIImageView *leftTopImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame)-8, CGRectGetMaxY(topView.frame)-8, customImage.size.width, customImage.size.height)];
    leftTopImageView.image = customImage;
    [self.view addSubview:leftTopImageView];
    
    //右上边角imageview
    customImage = [UIImage imageFromBundleWithName:@"qrCodeRightTop.png" bundleName:@"QqcScan"];
    UIImageView *rightTopImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - customImage.size.width+8, CGRectGetMaxY(topView.frame)-8, customImage.size.width, customImage.size.height)];
    rightTopImage.image = customImage;
    [self.view addSubview:rightTopImage];
    
    //左下边角imageview
    customImage = [UIImage imageFromBundleWithName:@"qrCodeLeftBottom.png" bundleName:@"QqcScan"];
    UIImageView *leftBottomImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame)-8, CGRectGetMinY(bottomView.frame) - customImage.size.height+8, customImage.size.width, customImage.size.height)];
    leftBottomImage.image = customImage;
    [self.view addSubview:leftBottomImage];
    
    //右下边角
    customImage = [UIImage imageFromBundleWithName:@"qrCodeRightBottom.png" bundleName:@"QqcScan"];
    UIImageView *rightBottomImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - customImage.size.width+8, CGRectGetMinY(bottomView.frame) - customImage.size.height+8, customImage.size.width, customImage.size.height)];
    rightBottomImage.image = customImage;
    [self.view addSubview:rightBottomImage];
    
    //扫描区域框view
    UIView *scanView = [[UIView alloc] initWithFrame:CGRectMake(_widthLeftRightMask, _heightTopBottomMask, kReaderViewWidth, kReaderViewHeight)];
    scanView.layer.borderColor = [UIColor whiteColor].CGColor;
    scanView.layer.borderWidth = 0.33;
    [self.view addSubview:scanView];
    
    //添加扫描线
    [self.view addSubview:self.scanLineImageView];
    
    //说明label
    UILabel *introduceLabel = [[UILabel alloc] init];
    introduceLabel.backgroundColor = [UIColor clearColor];
    introduceLabel.frame = CGRectMake(0.0, CGRectGetMinY(bottomView.frame) + 25.0, width_screen_qqc, 20.0);
    introduceLabel.textAlignment = NSTextAlignmentCenter;
    introduceLabel.font = [UIFont boldSystemFontOfSize:13.0];
    introduceLabel.textColor = [UIColor whiteColor];
    introduceLabel.text = @"将二维码置于框内，即可自动扫描";
    [self.view addSubview:introduceLabel];
}

/**
 *   创建功能按钮
 */
- (void)buildFunctionBtn
{
    CGFloat picBtnY = height_content_qqc + 44 - 80;
    
    UIButton *picBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, picBtnY , 80, 80)];
    [picBtn addTarget:self action:@selector(onBtnPic:) forControlEvents:UIControlEventTouchUpInside];
    [picBtn setImage:[UIImage imageFromBundleWithName:@"icon_photo.png" bundleName:@"QqcScan"] forState:UIControlStateNormal];
    [self.view addSubview:picBtn];
    
    UIButton *hisBtn = [[UIButton alloc] initWithFrame:CGRectMake(width_screen_qqc - 80, picBtnY, 80, 80)];
    [hisBtn addTarget:self action:@selector(onBtnHistory:) forControlEvents:UIControlEventTouchUpInside];
    [hisBtn setImage:[UIImage imageFromBundleWithName:@"icon_history.png" bundleName:@"QqcScan"] forState:UIControlStateNormal];
    [self.view addSubview:hisBtn];
    
    _btnTorch = [[UIButton alloc] initWithFrame:CGRectMake(width_screen_qqc - 80, margins_vert16_qqc, 80, 80)];
    [_btnTorch addTarget:self action:@selector(onBtnFlashLight:) forControlEvents:UIControlEventTouchUpInside];
    [_btnTorch setImage:[UIImage imageFromBundleWithName:@"icon_flash_off.png" bundleName:@"QqcScan"] forState:UIControlStateNormal];
    [_btnTorch setImage:[UIImage imageFromBundleWithName:@"icon_flash_on.png" bundleName:@"QqcScan"] forState:UIControlStateSelected];
    [self.view addSubview:_btnTorch];
    
    UIButton *btnBack = [[UIButton alloc] initWithFrame:(CGRect) {0, margins_vert16_qqc, 80, 80}];
    [btnBack addTarget:self action:@selector(onBtnBack:) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setImage:[UIImage imageFromBundleWithName:@"icon_brackets_left_white.png" bundleName:@"QqcScan"] forState:UIControlStateNormal];
    [self.view addSubview:btnBack];
    
    if ( !(_scanUIMask&QqcScanUIMaskBack) )          {   [btnBack setHidden:YES];      }
    if ( !(_scanUIMask&QqcScanUIMaskFlashLight) )    {   [_btnTorch setHidden:YES];    }
    if ( !(_scanUIMask&QqcScanUIMaskPic) )           {   [picBtn setHidden:YES];       }
    if ( !(_scanUIMask&QqcScanUIMaskHistory) )       {   [hisBtn setHidden:YES];       }
    if ( ![QqcUtility isHasTorch] )              {   [_btnTorch setHidden:YES];    }
}

/**
 *  开始扫描
 */
- (void)startQRCodeScan
{
    [self stopLineTimer];
    [[NSRunLoop mainRunLoop] addTimer:self.lineTimer forMode:NSRunLoopCommonModes];
    [self.scanProcessor startScan];
}

/**
 *  停止扫描
 */
- (void)stopQRCodeScan
{
    [self stopLineTimer];
    [self.scanProcessor stopScan];
}

/**
 *  开始定时器
 *
 *  @param timer 定时器
 */
- (void)startLineTimer:(NSTimer *)timer
{
    __weak typeof(self)weakSelf = self;
    __block CGRect frame = self.scanLineImageView.frame;
    static BOOL flag = YES;
    
    if (flag)
    {
        frame.origin.y = _heightTopBottomMask;
        flag = NO;
        
        [UIView animateWithDuration:1.0 / 20.0 animations:^{
            frame.origin.y += 5.0;
            weakSelf.scanLineImageView.frame = frame;
        } completion:nil];
    }
    else
    {
        if (self.scanLineImageView.frame.origin.y >= _heightTopBottomMask)
        {
            if (self.scanLineImageView.frame.origin.y >= _heightTopBottomMask+kReaderViewHeight - 12.0)
            {
                frame.origin.y = _heightTopBottomMask;
                self.scanLineImageView.frame = frame;
                flag = YES;
            }
            else
            {
                [UIView animateWithDuration:1.0 / 20.0 animations:^{
                    frame.origin.y += 5.0;
                    weakSelf.scanLineImageView.frame = frame;
                } completion:nil];
            }
        }
        else
        {
            flag = !flag;
        }
    }
}

/**
 *  停止定时器
 */
- (void)stopLineTimer
{
    [self.lineTimer invalidate];
    self.lineTimer = nil;
}


#pragma mark - 数据初始化
- (QqcScanProcessor *)scanProcessor
{
    if (!_scanProcessor)
    {
        _scanProcessor = [[QqcScanProcessor alloc] initWithScanView:self.view];
        
        __weak __typeof(self) weakSelf = self;
        _scanProcessor.QqcQRCodeSuccessBlock = ^(QqcScanProcessor *processor, NSString *scanResult){
            weakSelf.QqcQRCodeSuccessBlock(weakSelf, scanResult);
        };
        
        _scanProcessor.QqcQRCodeFailBlock = ^(QqcScanProcessor *processor){
            weakSelf.QqcQRCodeFailBlock(weakSelf);
        };

    }
    
    return _scanProcessor;
}

- (UIImageView *)scanLineImageView
{
    if (!_scanLineImageView)
    {
        _scanLineImageView = [[UIImageView alloc] initWithImage:[UIImage imageFromBundleWithName:@"qrCodeLine.png" bundleName:@"QqcScan"]];
        _scanLineImageView.frame = CGRectMake((width_screen_qqc - 280.0) / 2.0, _heightTopBottomMask, 280.0, 12.0);
    }
    
    return _scanLineImageView;
}

/**
 *  初始化lineTimer
 *
 *  @return 返回NSTimer实例
 */
- (NSTimer *)lineTimer
{
    if (!_lineTimer)
    {
        _lineTimer = [NSTimer timerWithTimeInterval:1.0 / 20 target:self selector:@selector(startLineTimer:) userInfo:nil repeats:YES];
    }
    
    return _lineTimer;
}


#pragma mark - UIImagePickerController 选择相片代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    __weak typeof(self)weakSelf = self;
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self dismissViewControllerAnimated:YES completion:^{
        NSString* strContent = [_scanProcessor getDataWithImage:image];
        if (str_is_exist_qqc(strContent))
        {
            if (weakSelf.QqcQRCodeSuccessBlock)
            {
                weakSelf.QqcQRCodeSuccessBlock(weakSelf, strContent);
            }
        }
        else
        {
            weakSelf.QqcQRCodeFailBlock(weakSelf);
        }
    }];
}

#pragma mark - 进入后台时，关闭闪关灯
- (void)handleEnteredBackground
{
    _btnTorch.selected = NO;
    [QqcUtility turnTorchOn:NO];
}

#pragma mark - 功能事件响应
- (void)onBtnBack:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    if (_delegate && [_delegate respondsToSelector:@selector(onBack)])
    {
        [_delegate onBack];
    }
    else
    {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }
}

- (void)onBtnHistory:(id)sender
{
    NSLog(@"%s", __FUNCTION__);
    
    if (_delegate && [_delegate respondsToSelector:@selector(onHistory)])
    {
        [_delegate onHistory];
    }
}

- (void)onBtnPic:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(onPic)])
    {
        [_delegate onPic];
    }
    else
    {
        QqcImagePickerController *controller = [[QqcImagePickerController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        controller.allowsEditing = YES;
        controller.delegate = self;
        [self presentViewController:controller
                                animated:YES
                              completion:^(void){
                                  NSLog(@"Picker View Controller is presented");
                              }];
    }
}

-(void)onBtnFlashLight:(id) sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(onFlashLight)])
    {
        [_delegate onFlashLight];
    }
    else
    {
        if (_btnTorch.selected) {
            _btnTorch.selected = NO;
            [QqcUtility turnTorchOn:NO];
        }else{
            _btnTorch.selected = YES;
            [QqcUtility turnTorchOn:YES];
        }
    }
}

#pragma mark - 屏幕旋转
- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0)
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations NS_AVAILABLE_IOS(6_0)
{
    return UIInterfaceOrientationMaskPortrait;
}

@end


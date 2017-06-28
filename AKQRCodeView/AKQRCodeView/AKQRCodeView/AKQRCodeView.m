//
//  AKQRCodeView.m
//  AKQRCodeView
//
//  Created by 吴莎莉 on 2017/6/28.
//  Copyright © 2017年 alasku. All rights reserved.
//

#import "AKQRCodeView.h"
#import <AVFoundation/AVFoundation.h>


@interface AKQRCodeView()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>

/// 扫描View
@property (nonatomic,strong) UIView *scanRectView;
/// 捕捉设备
@property (nonatomic,strong) AVCaptureDevice *captureDevice;
/// 设备采集
@property (nonatomic,strong) AVCaptureDeviceInput *deviceInput;
/// 采集数据输出
@property (nonatomic,strong) AVCaptureMetadataOutput *dataOutput;
/// 捕捉
@property (nonatomic,strong) AVCaptureSession *captureSession;
/// 捕捉影像图层
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *preview;
/// 扫描线
@property (nonatomic,strong) UIView *scanLine;

@end


@implementation AKQRCodeView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    if (self.captureSession != nil && self.captureSession.isRunning) {
        return;
    }
    
    if (self.captureSession != nil && !self.captureSession.isRunning) {
        return;
    }
    
    @try{
        self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if (self.captureDevice == nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"模拟器是不能扫描滴..." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:actionOK];
            [[self viewController:self] presentViewController:alert animated:YES completion:nil];

            return;
        }
        
        NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"请在iPhone的\"设置-隐私-相机\"选项中，允许本程序访问您的相机" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            
            [alert addAction:actionOK];
            [[self viewController:self] presentViewController:alert animated:YES completion:nil];
            
            return;
        }
        
        self.deviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.captureDevice error:nil];
        self.dataOutput = [AVCaptureMetadataOutput new];
        [self.dataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        self.captureSession = [AVCaptureSession new];
        
        if ([UIScreen mainScreen].bounds.size.height < 500.0) {
            // iPhone 4 or 4S
            [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
        }else {
            [self.captureSession setSessionPreset:AVCaptureSessionPresetHigh]; // 高精度
        }
        
        [self.captureSession addInput:self.deviceInput];
        [self.captureSession addOutput:self.dataOutput];
        
        // 二维码
        self.dataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode39Mod43Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code];
        
        //扫描区域
        self.preview = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
        self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.preview.frame = self.bounds;
        
        [self.layer insertSublayer:self.preview atIndex:0];
        [self addSubview:self.scanRectView];
        
        self.scanRectView.frame = self.bounds;
        
        // 放大
        @try{
            [self.captureDevice lockForConfiguration:nil];
        }@catch (NSError *error) {
            NSLog(@"Error: lockForConfiguration");
        }@finally {
            self.captureDevice.videoZoomFactor = 1.5; // 放大1.5
            [self.captureDevice unlockForConfiguration];
        }
    }@catch (NSError *error){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"请在iPhone的\"设置-隐私-相机\"选项中，允许本程序访问您的相机" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alert addAction:actionOK];
        [[self viewController:self] presentViewController:alert animated:YES completion:nil];

    }
}

//MARK: - AVCaptureOutput Delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
   //You can call a alert voice here
    [self playAudioWithUrlString:self.warningToneFileName Alert:YES];
    // stop scan
    [self.captureSession stopRunning];
    [self.scanLine removeFromSuperview];
    
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.getStringValue(obj.stringValue);
        });
        [self removeAudioObject:self.warningToneFileName];
    }
}


- (void)startLineAnimated {
    
    CGFloat startX = 0;
    CGFloat lineWidth = self.bounds.size.width;
    [self.scanRectView addSubview:self.scanLine];
    self.scanLine.frame = CGRectMake(startX, 0.0, lineWidth, 1.5);
    [self scanLineAnimation];
}


- (void)scanLineAnimation {
    
    if (self.scanLine != nil) {
        
        CGFloat startY = 0;
        CGFloat endY = self.bounds.size.height - 1.5;
        
        [UIView animateWithDuration:3.5 delay:0.0 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut animations:^{
            
            CGRect lineFrame = self.scanLine.frame;
            lineFrame.origin.y = endY;
            self.scanLine.frame = lineFrame;
        } completion:^(BOOL finished) {
            CGRect lineFrame = self.scanLine.frame;
            lineFrame.origin.y = startY;
            self.scanLine.frame = lineFrame;
        }];
    }
}

// start
- (void)startScan {
    
    [self.captureSession startRunning];
    [self startLineAnimated];
}

// end
- (void)stopScan {
    [self.captureSession stopRunning];
    [self.scanLine removeFromSuperview];
}


//MARK: - Lazy
- (UIView *)scanRectView {
    
    if (_scanRectView == nil) {
        
        _scanRectView = [UIView new];
        _scanRectView.layer.borderColor = [UIColor greenColor].CGColor;
        _scanRectView.layer.borderWidth = 1.5;
        return _scanRectView;
    }
    return _scanRectView;
}

- (UIView *)scanLine {
    
    if (_scanLine == nil) {
        _scanLine = [UIView new];
        _scanLine.backgroundColor = [UIColor redColor];
        return _scanLine;
    }
    return _scanLine;
}

//MARK: - Audio Method
- (void)playAudioWithUrlString:(NSString *)urlStr Alert:(BOOL)isAlert {
    
    SystemSoundID soundID;
    NSURL *url = [[NSBundle mainBundle] URLForResource:urlStr withExtension:nil];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundID);
    
    if (isAlert) {
        AudioServicesPlayAlertSound(soundID);
    }else {
        AudioServicesPlaySystemSound(soundID);
    }
}

- (void)removeAudioObject:(NSString *)urlStr {
    
    SystemSoundID soundID;
    NSURL *url = [[NSBundle mainBundle] URLForResource:urlStr withExtension:nil];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(url), &soundID);
    AudioServicesRemoveSystemSoundCompletion(soundID);
}


//MARK: - Others
- (UIViewController*)viewController:(UIView *)view {
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]] || [nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}


@end

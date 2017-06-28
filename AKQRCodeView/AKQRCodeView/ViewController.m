//
//  ViewController.m
//  AKQRCodeView
//
//  Created by 吴莎莉 on 2017/6/28.
//  Copyright © 2017年 alasku. All rights reserved.
//

#import "ViewController.h"
#import "AKQRCodeView.h"

@interface ViewController ()

@property (nonatomic,strong) AKQRCodeView *scanView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view addSubview:self.scanView];
    [self.scanView startScan];
    self.scanView.getStringValue = ^(NSString *stringValue) {
        NSLog(@"_______  StringValue: %@",stringValue);
        
        // Use stringValue here
        
    };
}


- (AKQRCodeView *)scanView {
    
    if (_scanView == nil) {
        _scanView = [[AKQRCodeView alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 200) / 2, ([UIScreen mainScreen].bounds.size.height - 200) / 2, 200, 200)];
        _scanView.warningToneFileName = @"sound.mp3";
    }
    return _scanView;
}


@end

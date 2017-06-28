# AKQRCodeView
A simple QRView 

# How to use
add Code like this where you need scan
``` 
AKQRCodeView *scanView = [[AKQRCodeView alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 200) / 2, ([UIScreen mainScreen].bounds.size.height - 200) / 2, 200, 200)];
    scanView.warningToneFileName = @"sound.mp3";
    [self.view addSubview:scanView];
    [scanView startScan];
    scanView.getStringValue = ^(NSString *stringValue) {
        NSLog(@"_______  StringValue: %@",stringValue);
        
        // Use stringValue here
        
    };
```
Demo will show you the details.



//
//  AKQRCodeView.h
//  AKQRCodeView
//
//  Created by 吴莎莉 on 2017/6/28.
//  Copyright © 2017年 alasku. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^getQRstringValueBlock)(NSString *stringValue);


@interface AKQRCodeView : UIView

/// getQRstringValueBlock
@property (nonatomic,copy) getQRstringValueBlock getStringValue;
/// warningToneFileName
@property (nonatomic,copy) NSString *warningToneFileName;

// start
- (void)startScan;


@end

//
//  TwoBtnVCViewController.h
//  uUU
//
//  Created by wenwang wang on 2019/6/19.
//  Copyright © 2019 wenwang wang. All rights reserved.
//

#import <UIKit/UIKit.h>

//            _twoBtn = [[TwoBtnVCViewController alloc] initWithFrame:CGRectMake(0, ScreenHeight - SafeAreaBottomHeight - kStatusHeight - kNavHeight - 43, ScreenWidth, 43)];
//            [self.view addSubview:_twoBtn];
//            [_twoBtn showBtn];
//            _twoBtn.callBackBlock = ^{
//                NSLog(@"fdsaaa22");
//            };

NS_ASSUME_NONNULL_BEGIN

typedef void(^CallBackBlcok) (void);

@interface TwoBtnVCViewController : UIView

- (void)showBtn;

@property (nonatomic,copy)CallBackBlcok callBackBlock;

@end

NS_ASSUME_NONNULL_END

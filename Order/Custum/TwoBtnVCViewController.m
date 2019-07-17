//
//  TwoBtnVCViewController.m
//  uUU
//
//  Created by wenwang wang on 2019/6/19.
//  Copyright © 2019 wenwang wang. All rights reserved.
//

#import "TwoBtnVCViewController.h"
#import <Masonry.h>
#import "Tools.h"

@interface TwoBtnVCViewController ()

// 底部确定按钮，多选合并出库单时用
@property (strong, nonatomic) UIView *bottomBtnContainerView;

@end

/*--------- 屏幕尺寸 ---------*/
#define ScreenHeight [UIScreen mainScreen] .bounds.size.height

// 状态栏高度
#define kStatusHeight  [[UIApplication sharedApplication] statusBarFrame].size.height

// 底部宏
#define SafeAreaBottomHeight (ScreenHeight == 812.0 ? 34 : 0)


/*--------- 颜色RGB ---------*/
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

@implementation TwoBtnVCViewController

- (void)showBtn {
    
    
    
    [self bottomBtnContainerView];
    [self layoutIfNeeded];
    
    [self.bottomBtnContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(43);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        [self layoutIfNeeded];
    }];
}


- (UIView *)bottomBtnContainerView {
    
    if(_bottomBtnContainerView == nil) {
        
        _bottomBtnContainerView = [[UIView alloc] init];
        [self addSubview:_bottomBtnContainerView];
        [_bottomBtnContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
            make.left.mas_equalTo(40);
            make.right.mas_equalTo(-40);
            make.bottom.mas_equalTo(0);
        }];
        
        UIButton *cancelBtn = [[UIButton alloc] init];
        UIButton *confirmBtn = [[UIButton alloc] init];
        [_bottomBtnContainerView addSubview:cancelBtn];
        [_bottomBtnContainerView addSubview:confirmBtn];
        
        [cancelBtn.layer setCornerRadius:5.0];
        [cancelBtn addTarget:self action:@selector(cancelMerOrder) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [cancelBtn setBackgroundImage:[Tools createImageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
        [cancelBtn setBackgroundImage:[Tools createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
        cancelBtn.clipsToBounds = YES;
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(confirmBtn.mas_left).offset(-40);
            make.bottom.mas_equalTo(0);
        }];
        
        [confirmBtn.layer setCornerRadius:5.0];
        [confirmBtn addTarget:self action:@selector(merOrder) forControlEvents:UIControlEventTouchUpInside];
        [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        [confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [confirmBtn setBackgroundImage:[Tools createImageWithColor:RGB(38, 135, 250)] forState:UIControlStateNormal];
        [confirmBtn setBackgroundImage:[Tools createImageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
        confirmBtn.clipsToBounds = YES;
        [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(cancelBtn.mas_right).offset(40);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.width.mas_equalTo(cancelBtn.mas_width);
        }];
    }
    return _bottomBtnContainerView;
}


- (void)cancelMerOrder {
    
    [self close];
}


- (void)merOrder {
    
    self.callBackBlock();
    [self close];
}


- (void)close {
    
    [self.bottomBtnContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

@end

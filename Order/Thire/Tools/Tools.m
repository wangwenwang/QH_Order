//
//  Tools.m
//  YBDriver
//
//  Created by 凯东源 on 16/8/30.
//  Copyright © 2016年 凯东源. All rights reserved.
//

#import "Tools.h"
#import <MBProgressHUD.h>
#import "Reachability.h"
#import "AppDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface Tools()

// 蓝牙检测
@property (nonatomic, strong)CBCentralManager *centralManager;

@end

@implementation Tools

- (instancetype)init {
    
    if(self = [super init]) {
        
        // 蓝牙检测
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        
    }
    return self;
}

- (void)stopBleScan {
    
    [self.centralManager stopScan];
    self.centralManager.delegate = nil;
}

/*!
 * @brief 把字典转换成JSON字符串
 * @param dict 字典
 * @return 返回JSON字符串
 */
+ (NSString *)JsonStringWithDictonary:(NSDictionary *)dict {
    //    NSString *jsonString = @"";
    //    if ([NSJSONSerialization isValidJSONObject:dict]){
    //        NSError *error;
    //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    //        jsonString =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //    }
    //    return jsonString;
    
    
    
    
    NSString *jsonString = [[NSString alloc]init];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    
    //    NSRange range = {0,jsonString.length};
    //    [mutStr replaceOccurrencesOfString:@" "withString:@""options:NSLiteralSearch range:range];
    
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n"withString:@""options:NSLiteralSearch range:range2];
    
    NSRange range3 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\\"withString:@""options:NSLiteralSearch range:range3];
    
    NSRange range4 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\r"withString:@""options:NSLiteralSearch range:range4];
    
    NSRange range5 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\t"withString:@""options:NSLiteralSearch range:range5];
    
    NSRange range6 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\r\n"withString:@""options:NSLiteralSearch range:range6];
    
    NSRange range7 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\r\t"withString:@""options:NSLiteralSearch range:range7];
    
    NSString *fff = [mutStr stringByReplacingOccurrencesOfString:@"\"{" withString:@"{"];
    
    fff = [fff stringByReplacingOccurrencesOfString:@"}\"" withString:@"}"];
    
    return fff;
}

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//请求API
//方式：POST
//类型：application/x-www-form-urlencoded
+ (NSString *)postAPI:(NSString *)urlStr andString:(NSString *)postStr {
    NSMutableData* data = (NSMutableData *)[postStr dataUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [[NSURL alloc]initWithString:urlStr];
    NSMutableData *postBody=[NSMutableData data];
    [postBody appendData:data];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0f];
    [request setHTTPMethod: @"POST"];
    [request setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postBody];
    NSError *error = nil;
    NSHTTPURLResponse* urlResponse = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    //    NSLog(@"结果：%@",result);
    return result;
}


+ (void)showAlert:(UIView *)view andTitle:(NSString *)title {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.margin = 15.0f;
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;
    [hud hide:YES afterDelay:1.5];
}


+ (void)showAlertMulLineText:(UIView *)view andTitle:(NSString *)title {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.detailsLabelFont = [UIFont systemFontOfSize:16.0];
    hud.detailsLabelText = title;
    hud.margin = 15.0f;
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;
    [hud hide:YES afterDelay:2.5];
}


+ (void)showAlert:(nullable UIView *)view andTitle:(nullable NSString *)title andTime:(NSTimeInterval)time {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = title;
    hud.margin = 15.0f;
    hud.removeFromSuperViewOnHide = YES;
    hud.userInteractionEnabled = NO;
    [hud hide:YES afterDelay:time];
}

+ (BOOL)isConnectionAvailable {
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            //NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            //NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            //NSLog(@"3G");
            break;
    }
    return isExistenceNetwork;
}

/**
 * 获取手机当前时间
 *
 * return 手机当前时间 "yyy-MM-dd HH:mm:ss"
 */
+ (NSString *)getCurrentDate {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    return currentDateString;
}

static CGRect oldframe;

+ (void)showImage:(UIImageView *)avatarImageView{
    UIImage *image=avatarImageView.image;
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    oldframe=[avatarImageView convertRect:avatarImageView.bounds toView:window];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha=0;
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:oldframe];
    imageView.image=image;
    imageView.tag=1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=oldframe;
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}

+ (NSInteger)getMinNumber:(NSInteger)a andB:(NSInteger)b {
    if(a < b) {
        return a;
    }else {
        return b;
    }
}

typedef void (^Animation)(void);

+ (void)setRootViewControllerWithCrossDissolve:(UIWindow *)window andViewController:(UIViewController *)vc {
    
    Animation animation = ^{
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        window.rootViewController = vc;
        [UIView setAnimationsEnabled:oldState];
    };
    [UIView transitionWithView:window
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:animation
                    completion:nil];
}

+ (void)setRootViewControllerWithFlipFromRight:(UIWindow *)window andViewController:(UIViewController *)vc {
    [UIView transitionWithView:window duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight animations:^{
        [window setRootViewController:vc];
    } completion:^(BOOL finished) {
        nil;
    }];
}

+ (void)setNavigationControllerTitleColor:(UINavigationController *)nav {
    nav.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
}

+ (NSString *)getOrderStatus:(NSString *)s {
    if([s isEqualToString:@"CLOSE"]) {
        return @"已完成";
    }else if([s isEqualToString:@"OPEN"]) {
        return @"在途";
    }else if([s isEqualToString:@"CANCEL"]) {
        return @"已取消";
    }else if([s isEqualToString:@"PENDING"]) {
        return @"待接收";
    }else {
        return s;
    }
}

+ (NSString *)getRoleName:(NSString *)s {
    if([s isEqualToString:@"PARTY"]) {
        return @"客户";
    }else if([s isEqualToString:@"PARGANA"]) {
        return @"大区";
    }else if([s isEqualToString:@"BUSINESS"]) {
        return @"业务员";
    }else if([s isEqualToString:@"ADMIN"]) {
        return @"管理员";
    }else {
        return s;
    }
}

+ (NSString *)getOrderState:(NSString *)s {
    if([s isEqualToString:@"新建"]) {
        return @"已接收";
    } else if([s isEqualToString:@"已释放"]) {
        return @"待装车";
    } else if([s isEqualToString:@"已确认"]) {
        return @"已拼车";
    } else if([s isEqualToString:@"已回单"]) {
        return @"已完结";
    } else {
        return s;
    }
}

+ (NSString *)getPaymentType:(NSString *)s {
    if([s isEqualToString:@"FPAD"]) {
        return @"预付";
    } else if([s isEqualToString:@"FDAP"]) {
        return @"到付";
    } else if([s isEqualToString:@"MP"]) {
        return @"月结";
    } else if([s isEqualToString:@"DJ"]) {
        return @"未知";
    } else {
        return s;
    }
}

+ (NSDictionary *)setProdictModel:(ProductModel *)m {
    
    NSMutableArray *arrPRODUCT_POLICY = [[NSMutableArray alloc] init];
    for(int i = 0; i < m.PRODUCT_POLICY.count; i++) {
        NSDictionary *dictProductPolicy = [self setProductPolicyModel:m.PRODUCT_POLICY[i]];
        [arrPRODUCT_POLICY addObject:dictProductPolicy];
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @(m.IDX), @"IDX",
                          m.BUSINESS_IDX, @"BUSINESS_IDX",
                          m.PRODUCT_NO, @"PRODUCT_NO",
                          m.PRODUCT_NAME, @"PRODUCT_NAME",
                          m.PRODUCT_DESC, @"PRODUCT_DESC",
                          m.PRODUCT_BARCODE, @"PRODUCT_BARCODE",
                          m.PRODUCT_TYPE, @"PRODUCT_TYPE",
                          m.PRODUCT_CLASS, @"PRODUCT_CLASS",
                          @(m.PRODUCT_PRICE), @"PRODUCT_PRICE",
                          m.PRODUCT_URL, @"PRODUCT_URL",
                          @(m.PRODUCT_VOLUME), @"PRODUCT_VOLUME",
                          @(m.PRODUCT_WEIGHT), @"PRODUCT_WEIGHT",
                          arrPRODUCT_POLICY, @"PRODUCT_POLICY",
                          m.ISINVENTORY, @"ISINVENTORY",
                          @(m.PRODUCT_INVENTORY), @"PRODUCT_INVENTORY",
                          @(m.PRODUCT_CURRENT_PRICE), @"PRODUCT_CURRENT_PRICE",
                          @(m.CHOICED_SIZE), @"CHOICED_SIZE",
                          nil];
    
    return dict;
}

+ (NSDictionary *)setProductPolicyModel:(ProductPolicyModel *)m {
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          m.POLICY_NAME, @"POLICY_NAME",
                          m.POLICY_TYPE, @"POLICY_TYPE",
                          m.AMOUNT_START, @"AMOUNT_START",
                          m.AMOUNT_END, @"AMOUNT_END",
                          m.REQUEST_BATCH, @"REQUEST_BATCH",
                          m.SALE_PRICE, @"SALE_PRICE",
                          nil];
    
    return dict;
}

+ (NSDictionary *)setPromotionOrderModel:(PromotionOrderModel *)m {
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @(m.IDX), @"IDX",
                          @(m.ENT_IDX), @"ENT_IDX",
                          @(m.ORG_IDX), @"ORG_IDX",
                          m.BUSINESS_IDX, @"BUSINESS_IDX",
                          @(m.BUSINESS_TYPE), @"BUSINESS_TYPE",
                          m.PAYMENT_TYPE, @"PAYMENT_TYPE",
                          m.GROUP_NO, @"GROUP_NO",
                          m.ORD_NO, @"ORD_NO",
                          m.ORD_NO_CLIENT, @"ORD_NO_CLIENT",
                          m.ORD_NO_CONSIGNEE, @"ORD_NO_CONSIGNEE",
                          m.ORD_STATE, @"ORD_STATE",
                          m.REQUEST_ISSUE, @"REQUEST_ISSUE",
                          m.REQUEST_DELIVERY, @"REQUEST_DELIVERY",
                          m.CONSIGNEE_REMARK, @"CONSIGNEE_REMARK",
                          @(m.ORG_PRICE), @"ORG_PRICE",
                          @(m.ACT_PRICE), @"ACT_PRICE",
                          @(m.MJ_PRICE), @"MJ_PRICE",
                          m.MJ_REMARK, @"MJ_REMARK",
                          @(m.TOTAL_QTY), @"TOTAL_QTY",
                          @(m.TOTAL_WEIGHT), @"TOTAL_WEIGHT",
                          @(m.TOTAL_VOLUME), @"TOTAL_VOLUME",
                          @(m.OPERATOR_IDX), @"OPERATOR_IDX",
                          m.ADD_DATE, @"ADD_DATE",
                          m.EDIT_DATE, @"EDIT_DATE",
                          @(m.FROM_IDX), @"FROM_IDX",
                          m.FROM_CODE, @"FROM_CODE",
                          m.FROM_NAME, @"FROM_NAME",
                          m.FROM_ADDRESS, @"FROM_ADDRESS",
                          m.FROM_PROPERTY, @"FROM_PROPERTY",
                          m.FROM_CNAME, @"FROM_CNAME",
                          m.FROM_CTEL, @"FROM_CTEL",
                          m.FROM_CSMS, @"FROM_CSMS",
                          m.FROM_COUNTRY, @"FROM_COUNTRY",
                          m.FROM_PROVINCE, @"FROM_PROVINCE",
                          m.FROM_CITY, @"FROM_CITY",
                          m.FROM_REGION, @"FROM_REGION",
                          m.FROM_ZIP, @"FROM_ZIP",
                          @(m.TO_IDX), @"TO_IDX",
                          m.TO_CODE, @"TO_CODE",
                          m.TO_NAME, @"TO_NAME",
                          m.TO_ADDRESS, @"TO_ADDRESS",
                          m.TO_PROPERTY, @"TO_PROPERTY",
                          m.TO_CNAME, @"TO_CNAME",
                          m.TO_CTEL, @"TO_CTEL",
                          m.TO_CSMS, @"TO_CSMS",
                          m.TO_COUNTRY, @"TO_COUNTRY",
                          m.TO_PROVINCE, @"TO_PROVINCE",
                          m.TO_CITY, @"TO_CITY",
                          m.TO_REGION, @"TO_REGION",
                          m.TO_ZIP, @"TO_ZIP",
                          m.PARTY_IDX, @"PARTY_IDX",
                          nil];
    
    return dict;
}


+ (NSDictionary *)setPromotionDetailModel:(PromotionDetailModel *)m; {
    
    //    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
    //                          @(m.IDX), @"IDX",
    //                          @(m.ENT_IDX), @"ENT_IDX",
    //                          @(m.ORDER_IDX), @"ORDER_IDX",
    //                          m.PRODUCT_TYPE, @"PRODUCT_TYPE",
    //                          @(m.PRODUCT_IDX), @"PRODUCT_IDX",
    //                          m.PRODUCT_NO, @"PRODUCT_NO",
    //                          m.PRODUCT_NAME, @"PRODUCT_NAME",
    //                          @(m.LINE_NO), @"LINE_NO",
    //                          @(m.PO_QTY), @"PO_QTY",
    //                          m.PO_UOM, @"PO_UOM",
    //                          @(m.PO_WEIGHT), @"PO_WEIGHT",
    //                          @(m.PO_VOLUME), @"PO_VOLUME",
    //                          @(m.ORG_PRICE), @"ORG_PRICE",
    //                          @(m.ACT_PRICE), @"ACT_PRICE",
    //                          m.SALE_REMARK, @"SALE_REMARK",
    //                          m.MJ_REMARK, @"MJ_REMARK",
    //                          @(m.MJ_PRICE), @"MJ_PRICE",
    //                          m.LOTTABLE01, @"LOTTABLE01",
    //                          m.LOTTABLE02, @"LOTTABLE02",
    //                          m.LOTTABLE03, @"LOTTABLE03",
    //                          m.LOTTABLE04, @"LOTTABLE04",
    //                          m.LOTTABLE05, @"LOTTABLE05",
    //                          m.LOTTABLE06, @"LOTTABLE06",
    //                          m.LOTTABLE07, @"LOTTABLE07",
    //                          m.LOTTABLE08, @"LOTTABLE08",
    //                          m.LOTTABLE09, @"LOTTABLE09",
    //                          m.LOTTABLE10, @"LOTTABLE10",
    //                          @(m.LOTTABLE11), @"LOTTABLE11",
    //                          @(m.LOTTABLE12), @"LOTTABLE12",
    //                          @(m.LOTTABLE13), @"LOTTABLE13",
    //                          @(m.OPERATOR_IDX), @"OPERATOR_IDX",
    //                          m.ADD_DATE, @"ADD_DATE",
    //                          m.EDIT_DATE, @"EDIT_DATE",
    //                          m.PRODUCT_URL, @"PRODUCT_URL",
    //                          nil];
    
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          @(m.IDX), @"IDX",
                          @(m.ENT_IDX), @"ENT_IDX",
                          @(m.ORDER_IDX), @"ORDER_IDX",
                          m.PRODUCT_TYPE, @"PRODUCT_TYPE",
                          @(m.PRODUCT_IDX), @"PRODUCT_IDX",
                          m.PRODUCT_NO, @"PRODUCT_NO",
                          m.PRODUCT_NAME, @"PRODUCT_NAME",
                          @(m.LINE_NO), @"LINE_NO",
                          @(m.PO_QTY), @"PO_QTY",
                          @(m.PO_WEIGHT), @"PO_WEIGHT",
                          @(m.PO_VOLUME), @"PO_VOLUME",
                          @(m.ORG_PRICE), @"ORG_PRICE",
                          @(m.ACT_PRICE), @"ACT_PRICE",
                          @(m.MJ_PRICE), @"MJ_PRICE",
                          m.LOTTABLE06, @"LOTTABLE06",
                          m.LOTTABLE10, @"LOTTABLE10",
                          @(m.LOTTABLE11), @"LOTTABLE11",
                          @(m.LOTTABLE12), @"LOTTABLE12",
                          @(m.LOTTABLE13), @"LOTTABLE13",
                          @(m.OPERATOR_IDX), @"OPERATOR_IDX",
                          m.PRODUCT_URL, @"PRODUCT_URL",
                          m.PRODUCT_UOM, @"PRODUCT_UOM",
                          m.PO_UOM, @"PO_UOM",
                          nil];
    
    return dict;
}

+ (NSString *)getPayTypeText:(NSString *)key {
    @try {
        
        if (key == nil || [key isEqualToString:@""]) return @"";
        
        if ([key isEqualToString:@"FPAD"]) {
            return @"先付款后发货";
        } else if ([key isEqualToString:@"FDAP"]) {
            return @"货到付款";
        } else if ([key isEqualToString:@"MP"]) {
            return @"月结";
        } else if ([key isEqualToString:@"DJ"]) {
            return @"兑奖";
        }
        return key;
    } @catch (NSException *exception) {
        
        return key;
    }
}

+ (NSMutableArray *)ChangeProductToPromotionDetailUtil:(NSMutableArray *)products {
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *arrReturn = [[NSMutableArray alloc] init];
    for(int i = 0; i < products.count; i++) {
        
        PromotionDetailModel *p = [[PromotionDetailModel alloc] init];
        ProductModel *m = products[i];
        p.ENT_IDX = 9008;
        p.PRODUCT_IDX = m.IDX;
        p.PRODUCT_TYPE = @"GF";
        p.PRODUCT_NO = m.PRODUCT_NO;
        p.PRODUCT_NAME = m.PRODUCT_NAME;
        p.LINE_NO = 0;
        p.PO_QTY = 0;
        p.PO_WEIGHT = m.PRODUCT_WEIGHT;
        p.PO_VOLUME = m.PRODUCT_VOLUME;
        p.ORG_PRICE = m.PRODUCT_PRICE;
        p.SALE_REMARK = [NSString stringWithFormat:@"%@分类赠品", m.PRODUCT_NAME];
        p.MJ_PRICE = 0;
        p.LOTTABLE02 = @"NR";
        p.OPERATOR_IDX = [app.user.IDX longLongValue];
        p.LOTTABLE09 = m.ISINVENTORY;
        p.LOTTABLE11 = m.PRODUCT_INVENTORY;
        // 是否算空瓶费，PRODUCT_TYPE_1 = "雪花瓶装啤酒" 时算空瓶费
        p.PRODUCT_TYPE_1 = m.PRODUCT_TYPE;
        p.PRODUCT_DESC = m.PRODUCT_DESC;
        // 如果 PRODUCT_DESC = "空瓶费"，需要费用
        if([p.PRODUCT_DESC isEqualToString:@"空瓶费"]) {
            
            p.ACT_PRICE = m.PRODUCT_PRICE;
        }
        p.PO_UOM = m.PRODUCT_UOM;
        p.PRODUCT_UOM = m.PRODUCT_UOM;
        p.PACK_UOM = m.PACK_UOM;
        
        [arrReturn addObject:p];
    }
    return arrReturn;
}

+ (double)getDouble:(double)d {
    
    NSString *str = [NSString stringWithFormat:@"%.2f", d];
    return [str doubleValue];
}


+ (NSString *)DateTransFrom:(NSString *)time {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:time];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

+ (void)msgChange:(CGFloat)overflowWidth andLabel:(UILabel *)_goodsNameLabel andBeginAnimations:(NSString *)animationName {
    CGRect frame = _goodsNameLabel.frame;
    frame.origin.x = 0;
    _goodsNameLabel.frame = frame;
    
    [UIView beginAnimations:animationName context:NULL];
    if(overflowWidth > 4) {
        [UIView setAnimationDuration:overflowWidth / 4];
    } else {
        [UIView setAnimationDuration:1.5];
    }
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:999];
    
    frame = _goodsNameLabel.frame;
    frame.origin.x = overflowWidth + 10;
    _goodsNameLabel.frame = frame;
    [UIView commitAnimations];
}




+ (void)addNavRightItemTypeMore:(nullable UIViewController *)vc andAction:(nullable SEL)action {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_more"] style:UIBarButtonItemStyleDone target:vc action:action];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -15;
    vc.navigationItem.rightBarButtonItems = @[negativeSpacer, rightItem];
}


+ (void)addNavRightItemTypeAdd:(nullable UIViewController *)vc andAction:(nullable SEL)action {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_add"] style:UIBarButtonItemStyleDone target:vc action:action];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -13;
    vc.navigationItem.rightBarButtonItems = @[negativeSpacer, rightItem];
}


+ (void)addNavRightItemTypeText:(nullable UIViewController *)vc andAction:(nullable SEL)action andTitle:(nullable NSString *)title {
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:title style:UIBarButtonItemStyleDone target:vc action:action];
    vc.navigationItem.rightBarButtonItem = rightItem;
}


+ (nullable NSString *)getCurrentBeforeDate_Second:(NSTimeInterval)second {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *nowDate = [NSDate date];
    NSDate *date1 = [nowDate initWithTimeIntervalSinceNow:+second];
    return [dateFormatter stringFromDate:date1];
}


+ (CGFloat)getHeightOfString:(nullable NSString *)text fontSize:(CGFloat)fontSize andWidth:(CGFloat)width {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    CGSize sizeToFit = [label sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}


+ (nullable NSString *)getDate_yyyy_mm_dd_hh_mm_ss:(nullable NSString *)yyyy_mm_dd_hh_mm_ss {
    NSString *yyyy_mm_dd = @"";
    if(yyyy_mm_dd_hh_mm_ss.length > 10) {
        yyyy_mm_dd = [yyyy_mm_dd_hh_mm_ss substringToIndex:10];
    } else {
        yyyy_mm_dd = yyyy_mm_dd_hh_mm_ss;
    }
    return yyyy_mm_dd;
}


+ (CGFloat)getWidthOfString:(nullable NSString *)text fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByCharWrapping;
    [label sizeToFit];
    return label.frame.size.width;
}


+ (nullable NSString *)getCurrentDate_yyyy_mm {
    NSDateFormatter *dateFormatter_yyyy_mm = [[NSDateFormatter alloc] init];
    [dateFormatter_yyyy_mm setLocale:[NSLocale currentLocale]];
    [dateFormatter_yyyy_mm setDateFormat:@"yyyy-MM"];
    NSString *toDay_yyyy_mm = [dateFormatter_yyyy_mm stringFromDate:[NSDate date]];
    return toDay_yyyy_mm;
}


+ (nullable NSString *)getCurrentDate_yyyy_mm_dd {
    NSDateFormatter *dateFormatter_yyyy_mm_dd = [[NSDateFormatter alloc] init];
    [dateFormatter_yyyy_mm_dd setLocale:[NSLocale currentLocale]];
    [dateFormatter_yyyy_mm_dd setDateFormat:@"yyyy-MM-dd"];
    NSString *toDay_yyyy_mm_dd = [dateFormatter_yyyy_mm_dd stringFromDate:[NSDate date]];
    return toDay_yyyy_mm_dd;
}


+ (void)interactivePopGestureRecognizer:(nullable UINavigationController *)nav andEnable:(BOOL)enable {
    if ([nav respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        nav.interactivePopGestureRecognizer.enabled = enable;
    }
}


+ (nullable NSString *)OneDecimal:(nullable NSString *)str {
    CGFloat flo = [str floatValue];
    NSString *result = [NSString stringWithFormat:@"%.1f", flo];
    return result;
}


+ (nullable NSString *)TwoDecimal:(nullable NSString *)str {
    CGFloat flo = [str floatValue];
    NSString *result = [NSString stringWithFormat:@"%.2f", flo];
    return result;
}


+ (nullable NSString *)formatFloat:(float)f {
    
    if (fmodf(f, 1)==0) {
        return [NSString stringWithFormat:@"%.0f",f];
    } else if (fmodf(f*10, 1)==0) {//如果有一位小数点
        return [NSString stringWithFormat:@"%.1f",f];
    } else if (fmodf(f*100, 1)==0) {//如果有两位小数点
        return [NSString stringWithFormat:@"%.2f",f];
    } else if (fmodf(f*1000, 1)==0) {
        return [NSString stringWithFormat:@"%.3f",f];
    } else if (fmodf(f*10000, 1)==0) {
        return [NSString stringWithFormat:@"%.4f",f];
    } else {
        return [NSString stringWithFormat:@"%.5f",f];
    }
}

+ (BOOL)isEmpty:(nullable NSString *)uu {
    
    if(uu == nil || [uu isEqualToString:@""]) {
        
        return YES;
    }else {
        return NO;
    }
}


+ (nullable NSDate *)dateFromString:(nullable NSString *)string {
    
    // 设置转换格式
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
    // NSString转NSDate
    NSDate *date=[formatter dateFromString:string];
    return date;
}


+ (nullable NSString *)getCurrentWeekDay {
    
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    return [self getWeekDayFordate:interval];
}


+ (nullable NSString *)getWeekDayFordate:(NSTimeInterval)data {
    
    NSArray *weekday = [NSArray arrayWithObjects: [NSNull null], @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:data];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:newDate];
    NSString *weekStr = [weekday objectAtIndex:components.weekday];
    return weekStr;
}


+ (nullable NSString *)changeImageToString:(nullable UIImage *)image {
    if(image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
        if(imageData) {
            return [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        }else {
            return @"";
        }
    }else {
        return @"";
    }
}


+ (nullable NSString *)getVISIT_STATES:(nullable NSString *)VISIT_STATES {
    if([VISIT_STATES isEqualToString:@""]) {
        return @"未拜访";
    }else if([VISIT_STATES isEqualToString:@"离店"]) {
        return @"已拜访";
    }else {
        return @"拜访中";
    }
}


+ (nullable NSString *)ToDBC:(nullable NSString *)input {
    NSString *result = @"";
    for (int i = 0; i < input.length; i++) {
        int c = [input characterAtIndex:i];
        int cTemp = c;
        if (c == 12288) {
            cTemp = (char)32;
            continue;
        }
        if (c > 65280 && c < 65375)
            cTemp = (char)(c - 65248);
        NSString *string = @"";
        if(cTemp == c) {
            NSRange ran = NSMakeRange(i, 1);
            string = [input substringWithRange:ran];
        }else {
            string =[NSString stringWithFormat:@"%c",cTemp];
        }
        result =  [NSString stringWithFormat:@"%@%@", result, string];
    }
    return result;
}


+ (nullable UIImage *)createImageWithColor:(nullable UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (BOOL)hasBASE_RATE:(int)BASE_RATE {
    if(BASE_RATE != 0 && BASE_RATE != 1) {
        return YES;
    }else {
        return NO;
    }
}

+ (BOOL)isNum:(nullable NSString *)checkedNumString {
    checkedNumString = [checkedNumString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(checkedNumString.length > 0) {
        return NO;
    }
    return YES;
}

+ (int)textLength: (nullable NSString *)text {
    NSUInteger asciiLength = 0;
    for (NSUInteger i = 0; i < text.length; i++) {
        unichar uc = [text characterAtIndex: i];
        asciiLength += isascii(uc) ? 1 : 2;
    }
    int unicodeLength = asciiLength;
    return unicodeLength;
}

#pragma mark - CLLocationManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    //第一次打开或者每次蓝牙状态改变都会调用这个函数
    if(central.state==CBCentralManagerStatePoweredOn)
    {
        NSLog(@"蓝牙设备开着");
                self.blueToothOpen = YES;
    }
    else
    {
        NSLog(@"蓝牙设备关着");
                self.blueToothOpen = NO;
    }
}


+ (BOOL)isToday:(nullable NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:now];
    // 当天起始时间
    NSDate *startDate = [calendar dateFromComponents:components];
    // 当天结束时间
    NSDate *expireDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    if ([date compare:startDate] == NSOrderedDescending && [date compare:expireDate] == NSOrderedAscending) {
        return YES;
    } else {
        return NO;
    }
}

@end

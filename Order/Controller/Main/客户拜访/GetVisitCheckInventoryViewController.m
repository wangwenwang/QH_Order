//
//  GetVisitCheckInventoryViewController.m
//  Order
//
//  Created by wenwang wang on 2018/11/20.
//  Copyright © 2018年 凯东源. All rights reserved.
//

#import "GetVisitCheckInventoryViewController.h"
#import "GetVisitEnterShopService.h"
#import "Tools.h"
#import <MBProgressHUD.h>
#import "GetVisitRecommendedOrderViewController.h"
#import "SelectGoodsService.h"
#import "ProductTbModel.h"
#import "GetVisitCheckInventoryTableViewCell.h"
#import "LM_alert.h"
#import "GetVisitCheckInventoryOkTableViewCell.h"

@interface GetVisitCheckInventoryViewController ()<GetVisitEnterShopServiceDelegate, SelectGoodsServiceDelegate, GetVisitCheckInventoryTableViewCellDelegate, GetVisitCheckInventoryOkTableViewCellDelegate>

// 检查库存
@property (weak, nonatomic) IBOutlet UITextView *strCheckInventory;

//textView的placeholder
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;

// 确认
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) SelectGoodsService *selectGoodsService;

// 品牌
@property (strong, nonatomic) NSMutableArray *brands;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;

// 类型
@property (strong, nonatomic) NSMutableArray *types;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

// 产品信息列表数据(搜索过滤后的)
@property (strong, nonatomic)NSMutableArray *productsFilter;

// 已检查产品列表
@property (weak, nonatomic) IBOutlet UITableView *checkOkTableView;

// 已检查产品
@property (strong, nonatomic)NSMutableArray *checkOkProducts;

// 上部分高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;

// 产品列表高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *productTableViewHeight;

// 底部分高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;

@end


#define kCellHeight_CheckInventory 90

#define kCellName_CheckInventory @"GetVisitCheckInventoryTableViewCell"

#define kCellHeight_CheckInventoryOk 53

#define kCellName_CheckInventoryOk @"GetVisitCheckInventoryOkTableViewCell"

#define kSplitter @"^；"


@implementation GetVisitCheckInventoryViewController

- (instancetype)init {
    
    if(self = [super init]) {
        
        _selectGoodsService = [[SelectGoodsService alloc] init];
        _selectGoodsService.delegate = self;
        
        _brands = [[NSMutableArray alloc] init];
        _types = [[NSMutableArray alloc] init];
        
        _checkOkProducts = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"检查库存";
    
    _confirmBtn.layer.cornerRadius = 20;
    _confirmBtn.layer.shadowOffset =  CGSizeMake(0, 3);
    _confirmBtn.layer.shadowOpacity = 0.5;
    _confirmBtn.layer.shadowColor =  [UIColor redColor].CGColor;
    
    [self registerCell];
    
    [_selectGoodsService getProductTypesData];
}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    _productTableViewHeight.constant = (ScreenHeight - kStatusHeight - kNavHeight - _topViewHeight.constant - _bottomViewHeight.constant) / 2;
}


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


#pragma mark - 功能函数

// 注册Cell
- (void)registerCell {
    
    [_tableView registerNib:[UINib nibWithNibName:kCellName_CheckInventory bundle:nil] forCellReuseIdentifier:kCellName_CheckInventory];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [_checkOkTableView registerNib:[UINib nibWithNibName:kCellName_CheckInventoryOk bundle:nil] forCellReuseIdentifier:kCellName_CheckInventoryOk];
    _checkOkTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)requstProduct:(NSString *)brand andType:(NSString *)type {
    
    NSString *_type = type;
    if([type isEqualToString:@"全部"]) {
        _type = @"";
    }
    
    [_selectGoodsService getProductsData:_pvItemM.iDX andOrderAddressIdx:_pvItemM.aDDRESSIDX andProductTypeIndex:0 andProductType:brand andOrderBrand:_type];
}

// 弹出选择品牌
- (void)showBrand:(NSArray *)arr {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __weak __typeof(self)weakSelf = self;
        [LM_alert showLMAlertViewWithTitle:@"请选品牌" message:@"" cancleButtonTitle:@"取消" okButtonTitle:nil otherButtonTitleArray:arr clickHandle:^(NSInteger index) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"%ld", (long)index);
                NSString *title = @"";
                if(index == 0) {
                    
                }else {
                    
                    _typeLabel.text = @"全部";
                    title = arr[index - 1];
                    [weakSelf.brandLabel setText:title];
                    [self requstProduct:_brandLabel.text andType:@""];
                }
            });
        }];
    });
}


// 弹出选择类型
- (void)showType:(NSArray *)arr {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        __weak __typeof(self)weakSelf = self;
        [LM_alert showLMAlertViewWithTitle:@"请选择类型" message:@"" cancleButtonTitle:@"取消" okButtonTitle:nil otherButtonTitleArray:arr clickHandle:^(NSInteger index) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"%ld", (long)index);
                NSString *title = @"";
                if(index == 0) {
                    
                }else {
                    
                    title = arr[index - 1];
                    [weakSelf.typeLabel setText:title];
                    [self requstProduct:_brandLabel.text andType:_typeLabel.text];
                }
            });
        }];
    });
}


#pragma mark - 事件

// 品牌
- (IBAction)choiceBrandOnclick {
    
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (ProductTbModel *tbM in _brands) {
        [list addObject:tbM.PRODUCT_TYPE];
    }
    list = [list valueForKeyPath:@"@distinctUnionOfObjects.self"];
    [self showBrand:list];
}

// 类型
- (IBAction)choiceTypeOnclick {

    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (ProductTbModel *tbM in _brands) {
        [list addObject:tbM.PRODUCT_CLASS];
    }
    list = [list valueForKeyPath:@"@distinctUnionOfObjects.self"];
    [self showType:list];
}

- (IBAction)confirmOnclick {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    GetVisitEnterShopService *s = [[GetVisitEnterShopService alloc] init];
    s.delegate = self;
    NSString *checkContext = @"";
    for (ProductModel *p in _checkOkProducts) {
        NSString *uom;
        if([Tools hasBASE_RATE:p.BASE_RATE]) {
            uom = p.PACK_UOM;
        }else {
            uom = p.PRODUCT_UOM;
        }
        if([checkContext isEqualToString:@""]) {
            checkContext = [NSString stringWithFormat:@"%@（%lld%@）", p.PRODUCT_NAME, p.CHOICED_SIZE, uom];
        }else {
            checkContext = [NSString stringWithFormat:@"%@%@%@（%lld%@）", checkContext, kSplitter, p.PRODUCT_NAME, p.CHOICED_SIZE, uom];
        }
    }
    checkContext = [NSString stringWithFormat:@"%@%@%@", checkContext, kSplitter, _strCheckInventory.text];
    
    [s GetVisitCheckInventory:_pvItemM.vISITIDX andStrCheckInventory:checkContext];
}

// 点击屏幕，收回键盘
- (IBAction)screenOnclick {
    
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if(tableView.tag == 1001) {
        
        return _productsFilter.count;
    }else if (tableView.tag == 1002) {
        
        return _checkOkProducts.count;
    }else {
        return 0;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView.tag == 1001) {
        
        return kCellHeight_CheckInventory;
    }else if (tableView.tag == 1002) {
        
        return kCellHeight_CheckInventoryOk;
    }else {
        return 44;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView.tag == 1001) {
        
        // 获取数据
        ProductModel *p = _productsFilter[indexPath.row];
        
        // 处理界面
        static NSString *cellId = kCellName_CheckInventory;
        GetVisitCheckInventoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        cell.delegate = self;
        cell.tag = indexPath.row;
        
        // 填充基本数据
        cell.productM = p;
        
        return cell;
    }else if(tableView.tag == 1002) {
        
        // 处理界面
        static NSString *cellId = kCellName_CheckInventoryOk;
        GetVisitCheckInventoryOkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        cell.delegate = self;
        cell.tag = indexPath.row;
        
        ProductModel *p = _checkOkProducts[indexPath.row];
        NSString *uom;
        if([Tools hasBASE_RATE:p.BASE_RATE]) {
            uom = p.PACK_UOM;
        }else {
            uom = p.PRODUCT_UOM;
        }
        cell.productNameLabel.text = [NSString stringWithFormat:@"%@（%lld%@）", p.PRODUCT_NAME, p.CHOICED_SIZE, uom];
        return cell;
    }else {
        
        return [[UITableViewCell alloc] init];
    }
}

#pragma mark - GetVisitEnterShopServiceDelegate

- (void)successOfGetVisitCheckInventory:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg];
    
    GetVisitRecommendedOrderViewController *vc = [[GetVisitRecommendedOrderViewController alloc] init];
    vc.pvItemM = _pvItemM;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)failureOfGetVisitCheckInventory:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg];
}


#pragma mark - 键盘回收

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text {
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if (![text isEqualToString:@""]) {
        _placeholderLabel.hidden = YES;
    }
    
    if ([text isEqualToString:@""] && range.location == 0 && range.length == 1) {
        _placeholderLabel.hidden = NO;
    }
    
    return YES;
}


#pragma mark - SelectGoodsServiceDelegate

// 获取产品类型回调
- (void)successOfGetProductTypeData:(NSMutableArray *)productTypes {
    
    for (ProductTbModel *tbM in productTypes) {
        [_brands addObject:tbM];
    }
    
    // 清理品牌并去重
//    NSArray *brandsTemp = [_brands copy];
//    for (ProductTbModel *brand in brandsTemp) {
//        if([brand.PRODUCT_TYPE isEqualToString:@"全部"] ||
//           [brand.PRODUCT_CLASS isEqualToString:@"全部"] ||
//           [brand.PRODUCT_TYPE isEqualToString:@""] ||
//           [brand.PRODUCT_CLASS isEqualToString:@""]) {
//            [_brands removeObject:brand];
//        }
//    }
    _brands = [_brands valueForKeyPath:@"@distinctUnionOfObjects.self"];
    
    // 设置默认品牌
    if(_brands.count > 0) {
        ProductTbModel *brand = [_brands firstObject];
        [_brandLabel setText:brand.PRODUCT_TYPE];
        [_typeLabel setText:@"全部"];
    }

    // 请求产品
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_selectGoodsService getProductsData:_pvItemM.iDX andOrderAddressIdx:_pvItemM.aDDRESSIDX andProductTypeIndex:0 andProductType:_brandLabel.text andOrderBrand:@""];
}


- (void)failureOfGetProductTypeData:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];

    [Tools showAlert:self.view andTitle:msg ? msg : @"获取产品类型失败"];
}


// 获取产品回调
- (void)successOfGetProductData:(NSMutableArray *)products {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    _productsFilter = products;
    [_tableView reloadData];
}


- (void)failureOfGetProductData:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [_productsFilter removeAllObjects];
    [_tableView reloadData];
    [Tools showAlert:self.view andTitle:msg ? msg : @"获取产品列表失败"];
}


#pragma mark - GetVisitCheckInventoryTableViewCellDelegate

- (void)okOfGetVisitCheckInventoryTableViewCell:(NSUInteger)row andQty:(NSUInteger)qty {
    
    [self.view endEditing:YES];
    
    ProductModel *p = _productsFilter[row];
    
    BOOL isbool = [_checkOkProducts containsObject:p];
    if(isbool == YES) {
        [Tools showAlert:self.view andTitle:@"此产品已检查"];
        return;
    }
    
    if(qty <= 0) {
        [Tools showAlert:self.view andTitle:@"请输入数量"];
        return;
    }
    p.CHOICED_SIZE = qty;
    
    [_checkOkProducts addObject:p];
    [_checkOkTableView reloadData];
}


#pragma mark - GetVisitCheckInventoryOkTableViewCellDelegate

- (void)okOfGetVisitCheckInventoryOkTableViewCell:(NSUInteger)row {
    
    [_checkOkProducts removeObjectAtIndex:row];
    [_checkOkTableView reloadData];
}
@end

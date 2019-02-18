//
//  EditPartyViewController.m
//  Order
//
//  Created by wenwang wang on 2019/2/15.
//  Copyright © 2019 凯东源. All rights reserved.
//

#import "EditPartyViewController.h"
#import <MBProgressHUD.h>
#import "GetVisitEnterShopService.h"
#import "AppDelegate.h"
#import "Tools.h"

@interface EditPartyViewController ()<GetVisitEnterShopServiceDelegate>

// 客户名称
@property (weak, nonatomic) IBOutlet UITextField *PARTY_NAME;

// 联系人
@property (weak, nonatomic) IBOutlet UITextField *CONTACT_PERSON;

// 联系电话
@property (weak, nonatomic) IBOutlet UITextField *CONTACT_TEL;

// 详细地址
@property (weak, nonatomic) IBOutlet UITextField *ADDRESS_INFO;

// 保存按钮
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

// 网络层
@property (strong, nonatomic) GetVisitEnterShopService *service;

@property (strong, nonatomic) AppDelegate *app;

@end

@implementation EditPartyViewController

- (instancetype)init {
    
    if(self = [super init]) {
        
        _service = [[GetVisitEnterShopService alloc] init];
        _service.delegate = self;
        
        _app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.title = @"编辑客户资料";
    
    _saveBtn.layer.cornerRadius = 20;
    _saveBtn.layer.shadowOffset =  CGSizeMake(0, 3);
    _saveBtn.layer.shadowOpacity = 0.5;
    _saveBtn.layer.shadowColor =  [UIColor redColor].CGColor;
    
    [self initUI];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)initUI {
    
    _PARTY_NAME.text = _partyM.PARTY_NAME;
    _CONTACT_PERSON.text = _partyM.CONTACT_PERSON;
    _CONTACT_TEL.text = _partyM.CONTACT_TEL;
    _ADDRESS_INFO.text = _partyM.ADDRESS_INFO;
}

- (IBAction)saveOnclick {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_service GetVisitConfirmCustomer:@"" andStrUserIDX:_app.user.IDX andStrPartyName:_PARTY_NAME.text andStrAddress:_ADDRESS_INFO.text andStrContacts:_CONTACT_PERSON.text andStrContactsTel:_CONTACT_TEL.text andStrChange:@"false" andStrBussenIdx:_app.business.BUSINESS_IDX andStrPartyCode:_partyM.PARTY_CODE];
}


- (void)successOfGetVisitConfirmCustomer:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    [Tools showAlert:self.view.window andTitle:msg andTime:3.5];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kGetPartyListViewController_receiveMsg object:nil userInfo:@{@"msg" : msg}];
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)failureOfGetVisitConfirmCustomer:(NSString *)msg {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [Tools showAlert:self.view andTitle:msg];
}


- (IBAction)cyclekeyBoard {
    
    [self.view endEditing:YES];
}

@end

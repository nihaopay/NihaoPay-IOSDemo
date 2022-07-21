//
//  ViewController.m
//  IOSDemo
//
//  Created by Sherry on 21/03/2017.
//  Copyright © 2017 Sherry. All rights reserved.
//

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>


#import "ViewController.h"

#import <AlipaySDK/AlipaySDK.h>
#import "NihaoPay.h"
#import "NihaoPayResult.h"
#import "UPPaymentControl/UPPaymentControl.h"
#import "WeChatSDK/WXApi.h"
#import "WeChatSDK/WechatAuthSDK.h"


//#import "UPPaymentControl.h"



#define kCellHeight_Normal  60
#define kCellHeight_Manual  145

#define kVCTitle          @"NihaoPay IOS Demo"
#define kWaiting          @"Loading"
#define kNote             @"Note"
#define kConfirm          @"Confirm"
#define kErrorNet         @"Network error"
#define kResult           @"Payment result: %@"


@interface ViewController ()
{
    UIAlertView* _alertView;
    NSMutableData* _responseData;
    CGFloat _maxWidth;
    CGFloat _maxHeight;
    
    UITextField *_urlField;
    UITextField *_modeField;
    UITextField *_curField;
}

@property(nonatomic, copy)NSString *tnMode;

- (void)extendedLayout;

- (void)showAlertWait;
- (void)showAlertMessage:(NSString*)msg;
- (void)hideAlert;

- (void)nhpAlipayButtonAction;
- (void)nhpUnionpayButtonAction;
- (void)nhpWechatpayButtonAction;
- (void)nhpApsButtonAction;


@end

@implementation ViewController
@synthesize contentTableView;
@synthesize tnMode;

- (void)dealloc
{
    self.contentTableView = nil;
    self.tnMode = nil;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = kVCTitle;
    
    [self extendedLayout];
    
    self.contentTableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _maxWidth, _maxHeight) style:UITableViewStyleGrouped] ;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView;
    });
    
    [self.view addSubview:self.contentTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)extendedLayout
{
    BOOL iOS7 = [UIDevice currentDevice].systemVersion.floatValue >= 7.0;
    if (iOS7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    CGFloat offset = iOS7 ? 64 : 44;
    _maxWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    _maxHeight = CGRectGetHeight([UIScreen mainScreen].bounds)-offset;
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)showAlertWait
{
    [self hideAlert];
    _alertView = [[UIAlertView alloc] initWithTitle:kWaiting message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [_alertView show];
    UIActivityIndicatorView* aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    aiv.center = CGPointMake(_alertView.frame.size.width / 2.0f - 15, _alertView.frame.size.height / 2.0f + 10 );
    [aiv startAnimating];
    [_alertView addSubview:aiv];
    
}

- (void)showAlertMessage:(NSString*)msg
{
    [self hideAlert];
    _alertView = [[UIAlertView alloc] initWithTitle:kNote message:msg delegate:self cancelButtonTitle:kConfirm otherButtonTitles:nil, nil];
    [_alertView show];
    
}
- (void)hideAlert
{
    if (_alertView != nil)
    {
        [_alertView dismissWithClickedButtonIndex:0 animated:NO];
        _alertView = nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _alertView = nil;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0:
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
        case 1:
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
        case 2:
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
        case 3:
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == 4) ? kCellHeight_Manual : kCellHeight_Normal;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 5;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    switch (indexPath.row) {
        case 0:
        {
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"Order Amount:";
            cell.detailTextLabel.text = @"0.01";
        }
            break;
        case 1:
        {
            CGRect alipayFrame = CGRectMake(50, 10, CGRectGetWidth(tableView.frame)-100, 40);
            
            UIButton *alipayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            alipayButton.frame = alipayFrame;
            [alipayButton addTarget:self action:@selector(nhpAlipayButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [alipayButton setTitle:@"Pay with AliPay" forState:UIControlStateNormal];
            [cell.contentView addSubview:alipayButton];
            
        }
            break;
        case 2:
        {
            CGRect upFrame = CGRectMake(50, 10, CGRectGetWidth(tableView.frame)-100, 40);
            
            UIButton *upButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            upButton.frame = upFrame;
            [upButton addTarget:self action:@selector(nhpUnionpayButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [upButton setTitle:@"Pay with UnionPay" forState:UIControlStateNormal];
            [cell.contentView addSubview:upButton];
        }
            break;
        case 3:
        {
            CGRect upFrame = CGRectMake(50, 10, CGRectGetWidth(tableView.frame)-100, 40);
            
            UIButton *wechatpayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            wechatpayButton.frame = upFrame;
            [wechatpayButton addTarget:self action:@selector(nhpWechatpayButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [wechatpayButton setTitle:@"Pay with WeChatPay" forState:UIControlStateNormal];
            [cell.contentView addSubview:wechatpayButton];
        }
            break;
        case 4:
        {
            CGRect upFrame = CGRectMake(50, 10, CGRectGetWidth(tableView.frame)-100, 40);
            
            UIButton *apsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            apsButton.frame = upFrame;
            [apsButton addTarget:self action:@selector(nhpApsButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [apsButton setTitle:@"Pay with APlus(A+)" forState:UIControlStateNormal];
            [cell.contentView addSubview:apsButton];
        }
            break;
        default:
            break;
    }
    return cell;
}

- (NSString *)generateReference //generate reference to NihaoPay (only Demo), merchant can use their orderid
{
    static int kNumber = 6;
    NSDate *date= [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    NSString *sourceStr = @"abcdefghijklmnopqrstuvwxyz";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return [dateString stringByAppendingString: resultStr];
}

- (void)nhpAlipayButtonAction //alipay button action
{
    NSLog(@"action:%@", @"Choose AliPay Checkout");
    
    NSString *token = @"4847fed22494dc22b1b1a478b34e374e0b429608f31adf289704b4ea093e60a8";
    if(token == nil){
        NSString* msg = @"Please add NihaoPay API token";
        [self showAlertMessage:msg];
        return;
    }
    //Init Nihaopay object
    // NihaoPay API Token should be stored on the server side
    NihaoPay *nhpOrder = [[NihaoPay alloc] initWithAPIinfo:@"https://apitest.nihaopay.com/v1.2/transactions/" addToken:token];
    
    //order info
    nhpOrder.amount=@"1";
    nhpOrder.currency=@"USD";
    nhpOrder.vendor=@"alipay";
    nhpOrder.reference=[self generateReference];
    nhpOrder.ipnUrl=@"https://demo.nihaopay.com/ipn";
    nhpOrder.note=@"note for merchant";
    nhpOrder.desc=@"Product Description";
    nhpOrder.ostype=@"IOS";
    
    //get order info to alipay
    NSDictionary * resultDict = [nhpOrder appPay];
    if ([resultDict[@"orderInfo"] length]) {
        NSString *orderInfo = resultDict[@"orderInfo"];
        
        // APP scheme, defined in "info.plist" URL Types, for back to
        NSString *appScheme = @"nihaopay";
        
        [[AlipaySDK defaultService] payOrder:orderInfo fromScheme:appScheme callback:^(NSDictionary *resultDic) {
             NSLog(@"result = %@",resultDic);
            NihaoPayResult *nhpResult = [[NihaoPayResult alloc] initWithAlipayReturn:resultDic];
            NSLog(@"result = %@",resultDic);
            
            
            NSLog(@"result = %@",nhpResult.clientStatus);
        }];
    } else if ([resultDict[@"redirectUrl"] length]) {
        NSString *redirectUrl = resultDict[@"redirectUrl"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:redirectUrl]];
    }
    
}


- (void)nhpUnionpayButtonAction //UnionPay button action, coming soon...
{
    NSLog(@"action:%@", @"Choose UnionPay Checkout");
    NSString *token = @"4847fed22494dc22b1b1a478b34e374e0b429608f31adf289704b4ea093e60a8";
    if(token == nil){
        NSString* msg = @"Please add NihaoPay API token";
        [self showAlertMessage:msg];
        return;
    }
    //Init Nihaopay object
    //NihaoPay API Token should be stored on the server side
    NihaoPay *nhpOrder = [[NihaoPay alloc] initWithAPIinfo:@"https://apitest.nihaopay.com/v1.2/transactions/" addToken:token];
    
    //order info
    nhpOrder.amount=@"1";
    nhpOrder.currency=@"USD";
    nhpOrder.vendor=@"unionpay";
    nhpOrder.reference=[self generateReference];
    nhpOrder.ipnUrl=@"https://demo.nihaopay.com/ipn";
    nhpOrder.note=@"note for merchant";
    nhpOrder.desc=@"Product Description";
    nhpOrder.ostype=@"IOS";
    
    //get order info to alipay
    NSDictionary * resultDict = [nhpOrder appPay];
    if ([resultDict[@"orderInfo"] length]) {
        NSString *tn = resultDict[@"orderInfo"];
        
        NSString *appScheme = @"nihaopay";
        NSLog(@"tn = %@",tn);
        if (tn != nil && tn.length > 0){
            //unionpay
            [[UPPaymentControl defaultControl] startPay:tn
                                             fromScheme:appScheme
                                                   mode:@"00"
                                         viewController:self];
        }
    } else if ([resultDict[@"redirectUrl"] length]) {
        NSString *redirectUrl = resultDict[@"redirectUrl"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:redirectUrl]];
    }
    
}

- (void)nhpWechatpayButtonAction //wechatpay button action, coming soon...
{
    NSLog(@"action:%@", @"Choose wechatpay Checkout");
    NSString *token = @"4847fed22494dc22b1b1a478b34e374e0b429608f31adf289704b4ea093e60a8";
    if(token == nil){
        NSString* msg = @"Please add NihaoPay API token";
        [self showAlertMessage:msg];
        return;
    }
    
    //Init Nihaopay object
    //NihaoPay API Token should be stored on the server side
    NihaoPay *nhpOrder = [[NihaoPay alloc] initWithAPIinfo:@"https://apitest.nihaopay.com/v1.2/transactions/" addToken:token];
    
    //order info
    nhpOrder.amount=@"1";
    nhpOrder.currency=@"USD";
    nhpOrder.vendor=@"wechatpay";
    nhpOrder.reference=[self generateReference];
    nhpOrder.ipnUrl=@"https://demo.nihaopay.com/ipn";
    nhpOrder.wechatAppID=@"wxad55355d75667501";
    nhpOrder.note=@"note for merchant";
    nhpOrder.desc=@"Product Description";
    nhpOrder.ostype=@"IOS";
    
    //get order info to alipay
    NSDictionary * resultDict = [nhpOrder appPay];
    if ([resultDict[@"orderInfo"] length]) {
        NSDictionary *orderInfo = [NSJSONSerialization JSONObjectWithData:[resultDict[@"orderInfo"] dataUsingEncoding:NSUTF8StringEncoding]
                                                                  options:0
                                                                    error:nil];
        
        //向微信注册,发起支付必须注册
        NSString* UNIVERSAL_LINK=@"https://help.wechat.com/IOSDemo/";
        [WXApi registerApp:@"wxad55355d75667501" universalLink:UNIVERSAL_LINK];
        
        //调起微信支付
        PayReq *req         = [[PayReq alloc] init];
        req.partnerId           = [orderInfo objectForKey:@"partnerid"];
        req.prepayId            = [orderInfo objectForKey:@"prepayid"];
        req.nonceStr            = [orderInfo objectForKey:@"noncestr"];
        req.timeStamp           = (UInt32)[orderInfo objectForKey:@"timestamp"];
        req.package             = [orderInfo objectForKey:@"package"];
        req.sign                = [orderInfo objectForKey:@"sign"];
        [WXApi sendReq:req completion:^(BOOL success) {
            NSLog(@"Call WeChatPay: %@",success ? @"success" :@"failed");
        }];
    } else if ([resultDict[@"redirectUrl"] length]) {
        NSString *redirectUrl = resultDict[@"redirectUrl"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:redirectUrl]];
    }
    
}

- (void)nhpApsButtonAction {
    
    NSLog(@"action:%@", @"Choose Alipay Aps Checkout");
    
    NSString *token = @"4847fed22494dc22b1b1a478b34e374e0b429608f31adf289704b4ea093e60a8";
    if(token == nil){
        NSString* msg = @"Please add NihaoPay API token";
        [self showAlertMessage:msg];
        return;
    }
    //Init Nihaopay object
    // NihaoPay API Token should be stored on the server side
    NihaoPay *nhpOrder = [[NihaoPay alloc] initWithAPIinfo:@"https://apitest.nihaopay.com/v1.2/transactions/" addToken:token];
    
    //order info
    nhpOrder.amount=@"1";
    nhpOrder.currency=@"USD";
    nhpOrder.reference=[self generateReference];
    nhpOrder.ipnUrl=@"https://demo.nihaopay.com/ipn";
    nhpOrder.note=@"note for merchant";
    nhpOrder.desc=@"Product Description";
    nhpOrder.ostype=@"IOS";
    
    //get order info to alipay
    NSDictionary * resultDict = [nhpOrder apsPay];
    if ([resultDict[@"orderInfo"] length]) {
        NSString *orderInfo = resultDict[@"orderInfo"];
        
        // APP scheme, defined in "info.plist" URL Types, for back to
        NSString *appScheme = @"nihaopay";
        
        [[AlipaySDK defaultService] payOrder:orderInfo fromScheme:appScheme callback:^(NSDictionary *resultDic) {
             NSLog(@"result = %@",resultDic);
            NihaoPayResult *nhpResult = [[NihaoPayResult alloc] initWithAlipayReturn:resultDic];
            NSLog(@"result = %@",resultDic);
            
            
            NSLog(@"result = %@",nhpResult.clientStatus);
        }];
    } else if ([resultDict[@"redirectUrl"] length]) {
        NSString *redirectUrl = resultDict[@"redirectUrl"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:redirectUrl]];
    }
}


#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _curField = textField;
}

@end

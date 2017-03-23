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
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row == 3) ? kCellHeight_Manual : kCellHeight_Normal;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 4;
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
    
    //Init Nihaopay object
    // NihaoPay API Token should be stored on the server side
    NihaoPay *nhpOrder = [[NihaoPay alloc] initWithAPIinfo:@"https://apitest.nihaopay.com/v1.2/transactions/" addToken:@"4847fed22494dc22b1b1a478b34e374e0b429608f31adf289704b4ea093e60a8"];
    
    //order info
    nhpOrder.amount=@"1";
    nhpOrder.currency=@"EUR";
    nhpOrder.vender=@"alipay";
    nhpOrder.reference=[self generateReference];
    nhpOrder.ipnUrl=@"https://demo.nihaopay.com/ipn";
    nhpOrder.note=@"note for merchant";
    nhpOrder.desc=@"Product Description";
    
    //get order info to alipay
    NSString *orderInfo = [nhpOrder getOrderInfo];
    
    // APP scheme, defined in "info.plist" URL Types, for back to
    NSString *appScheme = @"nihaopay";
    
    [[AlipaySDK defaultService] payOrder:orderInfo fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        
        NihaoPayResult *nhpResult = [[NihaoPayResult alloc] initWithAlipayReturn:resultDic];
        
        if([nhpResult.needQuery isEqualToString:@"true"]){
            
            NSDictionary *jsonResult=[nhpOrder getPayResult];
            
            NSLog(@"NihaoPay Result: %@",jsonResult);
            
            NSString *status=[jsonResult valueForKey:@"status"];
            
            if([status isEqualToString:@"success"])
            {
                [self showAlertMessage:@"payment success"];
            }
            else{
                [self showAlertMessage:status];
            }
        }
        else{
            [self showAlertMessage:nhpResult.clientStatus];
        }
    }];
}



- (void)nhpUnionpayButtonAction //UnionPay button action, coming soon...
{
    NSString* msg = @"Choose UnionPay Checkout, will coming soon...";
    NSLog(@"action:%@", msg);
    [self showAlertMessage:msg];
}


#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    _curField = textField;
}

@end

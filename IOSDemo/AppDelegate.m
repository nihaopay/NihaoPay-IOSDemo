//
//  AppDelegate.m
//  IOSDemo
//
//  Created by Sherry on 21/03/2017.
//  Copyright © 2017 Sherry. All rights reserved.
//

#import "AppDelegate.h"
#import "NihaoPayResult.h"
#import <AlipaySDK/AlipaySDK.h>
#import "UPPaymentControl/UPPaymentControl.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    //跳转支付宝钱包进行支付，处理支付结果
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result = %@",resultDic);
        
        NihaoPayResult *nhpResult = [[NihaoPayResult alloc] initWithAlipayReturn:resultDic];
        
         NSLog(@"result = %@",nhpResult.clientStatus);
        
    }];
    
    return YES;
}

// NOTE:9.0以后使用该新接口，新旧接口同时存在会调用新接口
- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
         NSLog(@"code = %@",code);
        NSLog(@"data = %@",data);
        //结果code为成功时，先校验签名，校验成功后做后续处理
        if([code isEqualToString:@"success"]) {
            
            //判断签名数据是否存在
//            if(data == nil){
//                //如果没有签名数据，建议商户app后台查询交易结果
//                return;
//            }
//            
//            //数据从NSDictionary转换为NSString
//            NSData *signData = [NSJSONSerialization dataWithJSONObject:data
//                                                               options:0
//                                                                 error:nil];
//            NSString *sign = [[NSString alloc] initWithData:signData encoding:NSUTF8StringEncoding];
            
            
            
//            //验签证书同后台验签证书
//            //此处的verify，商户需送去商户后台做验签
//            if([self verify:sign]) {
//                //支付成功且验签成功，展示支付成功提示
//            }
//            else {
//                //验签失败，交易结果数据被篡改，商户app后台查询交易结果
//            }
        }
        else if([code isEqualToString:@"fail"]) {
            //交易失败
        }
        else if([code isEqualToString:@"cancel"]) {
            //交易取消
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:code message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [alertView show];
        //过三秒消失
        [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:4.0f];
//        [alertView dismissWithClickedButtonIndex:0 animated:NO];
        
    }];
    
    return YES;
}

-(void)dismissAlert:(UIAlertView *)aAlertView
{
    if(aAlertView)
    {
        //警告框消失
        [aAlertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}


@end

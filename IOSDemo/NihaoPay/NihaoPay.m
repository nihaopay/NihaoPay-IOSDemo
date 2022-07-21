//
//  NihaoPay.m
//  IOSDemo
//
//  Created by Sherry on 21/03/2017.
//  Copyright © 2017 Sherry. All rights reserved.
//

#import "NihaoPay.h"

@implementation NihaoPay

-(id) initWithAPIinfo:(NSString *)apiUrl addToken:(NSString *)apiToken{
    self=[super init];
    if(apiUrl==nil || apiToken==nil){
        NSException* exception = [NSException exceptionWithName:@"NihaoPay Exception" reason:@"apiUrl or apiToken is null" userInfo:nil];
        @throw exception;
    }
    self.nhpApiUrl=apiUrl;
    self.nhpApiToken=apiToken;
    return self;
}


-(NSDictionary *) appPay
{
    //Request NihaoPay API, get orderinfo which submit to Alipay.
    
    NSString *params=[self requestParams];
    NSString *response=[self doPost:[self.nhpApiUrl stringByAppendingString:@"/apppay"] params:params];
    //NSLog(@"NihaoPay Response: %@",response);
    NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    return jsonObject;
}

-(NSDictionary *) apsPay
{
    //Request NihaoPay API, get orderinfo which submit to Alipay.
    
    NSString *params=[self requestParams];
    NSString *response=[self doPost:[self.nhpApiUrl stringByAppendingString:@"/aplus"] params:params];
    //NSLog(@"NihaoPay Response: %@",response);
    NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    
    return jsonObject;
}

//inquery payment result from nihaopay
-(NSDictionary *) getPayResult
{
    //Call NihaoPay retrieve api, get payment result
    //Only success means payment successful
    
    NSString *response=[self doRetrive:self.reference];
    //NSLog(@"NihaoPay Response: %@",response);
    NSData *jsonData = [response dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *jsonDictionary = (NSDictionary*)jsonObject;
    
    NSLog(@"status: %@",[jsonDictionary valueForKey:@"status"]);
    return jsonDictionary;
}


- (NSString *)requestParams {
    NSMutableString * params = [NSMutableString string];
    
    if(self.amount){
        [params appendFormat:@"amount=%@", self.amount];
    }
    
    if(self.currency){
        [params appendFormat:@"&currency=%@", self.currency];
    }
    
    if(self.ipnUrl){
        [params appendFormat:@"&ipn_url=%@", self.ipnUrl];
    }
    
    if(self.reference){
        [params appendFormat:@"&reference=%@", self.reference];
    }
    
    if(self.note){
        [params appendFormat:@"&note=%@", self.note];
    }
    
    if(self.desc){
        [params appendFormat:@"&description=%@", self.desc];
    }
    if(self.vendor){
        [params appendFormat:@"&vendor=%@", self.vendor];
    }
    if(self.wechatAppID){
        [params appendFormat:@"&appid=%@", self.wechatAppID];
    }
    if(self.ostype){
        [params appendFormat:@"&ostype=%@", self.ostype];
    }
    
    NSLog(@"request NihaoPay params: %@",params);
    
    return params;
}

//post param to nihaopay
-(NSString *) doPost:(NSString *)url params:(NSString *) params{
    
    NSString *token=[NSString stringWithFormat:@"%@ %@", @"Bearer", self.nhpApiToken ];
    
    NSDictionary *headers=@{@"authorization":token,
                            @"content-type": @"application/x-www-form-urlencoded"};
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    [request setAllHTTPHeaderFields:headers];
    
    [request setHTTPMethod:@"POST"];
    
    NSData *data = [params dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody:data];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    return str1;
}


-(NSString *) doRetrive:(NSString *) param{
    
    NSString *queryUrl=[NSString stringWithFormat:@"%@%@%@",self.nhpApiUrl,@"merchant/",param];
    
    NSURL *url = [NSURL URLWithString:queryUrl];
    
    NSString *token=[NSString stringWithFormat:@"%@ %@", @"Bearer", self.nhpApiToken ];
    
    NSDictionary *headers=@{@"authorization":token};
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    [request setAllHTTPHeaderFields:headers];
    
    [request setHTTPMethod:@"GET"];
    
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    NSString *str1 = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    return str1;
}


@end


//
//  ViewController.h
//  IOSDemo
//
//  Created by Sherry on 21/03/2017.
//  Copyright © 2017 Sherry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController< UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

@property(nonatomic, retain)UITableView *contentTableView;

@end

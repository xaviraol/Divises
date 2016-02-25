//
//  ListViewController.h
//  Monedes
//
//  Created by Xavier Ramos on 6/1/16.
//  Copyright © 2016 Xavier Ramos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, weak) IBOutlet UIView *mainCurrencyView;
@property (nonatomic, weak) IBOutlet UILabel *moneyLabel;
@property (nonatomic, weak) IBOutlet UITextField *valueTextField;

@property (nonatomic, weak) IBOutlet UITableView *currenciesTableView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *mainCurrencyViewHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topMainValue;

-(IBAction)addCurrencyAction;
-(IBAction)toInfoAction:(id)sender;

@end
